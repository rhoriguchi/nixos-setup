{ pkgs, lib, config, ... }:
let
  baseDir = "/var/lib/virt";
  poolDir = "${baseDir}/images";
  nvramDir = "${baseDir}/nvram";

  snapshotsDir = "/mnt/Data/Snapshots";

  getShellScriptToWaitForWindowsShutdown = command: timeout:
    pkgs.writeShellScript "wait-for-windows-shutdown.sh" ''
      let "timeout = $(date +%s) + ${toString timeout}"

      while [ "$(virsh list --name | grep --count "^windows$")" -gt 0 ]; do
        if [ "$(date +%s)" -ge "$timeout" ]; then
          ${command}
        else
          sleep 0.5
        fi
      done
    '';

  baseService = rec {
    after = [ "libvirtd.service" ];
    requires = after;
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.coreutils-full pkgs.gnugrep pkgs.gnused pkgs.libvirt ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
  };

  libvirtd-network = baseService // {
    script = let
      xmlConfig = pkgs.writeText "libvirtd-network.xml" ''
        <network>
          <name>default</name>

          <uuid>UUID</uuid>

          <bridge name='virbr0'/>

          <forward mode='nat'/>

          <mac address="52:54:00:2d:33:8f"/>

          <port isolated='yes'/>

          <ip address='172.16.1.1' netmask='255.255.255.0'>
            <dhcp>
              <range start='172.16.1.2' end='172.16.1.254'/>
            </dhcp>
          </ip>

          <ip family='ipv6' address='2001:db8:ca2:2::1' prefix='64'>
            <dhcp>
              <range start='2001:db8:ca2:2::2' end='2001:db8:ca2:2::ff'/>
            </dhcp>
          </ip>
        </network>
      '';

      # TODO improve virsh net-start "${network}" || virsh net-update "${network}" modify SECTION <(sed "s/UUID/$uuid/" ${xmlFile}) --live
    in ''
      uuid="$(virsh net-uuid "default" || true)"
      virsh net-define <(sed "s/UUID/$uuid/" ${xmlConfig})

      virsh net-destroy "default" || true
      virsh net-start "default"
      virsh net-autostart --disable "default"
    '';

    preStop = "${getShellScriptToWaitForWindowsShutdown ''virsh net-destroy "default"'' (5 * 60)}";
  };

  libvirtd-pool = baseService // {
    script = let
      xmlConfig = pkgs.writeText "libvirtd-pool.xml" ''
        <pool type='dir'>
          <name>default</name>

          <uuid>UUID</uuid>

          <target>
            <path>${poolDir}</path>
          </target>
        </pool>
      '';
    in ''
      uuid="$(virsh pool-uuid "default" || true)"
      virsh pool-define <(sed "s/UUID/$uuid/" ${xmlConfig})

      virsh pool-destroy "default" || true
      virsh pool-start "default"
      virsh pool-autostart --disable "default"
    '';

    preStop = "${getShellScriptToWaitForWindowsShutdown ''virsh pool-destroy "default"'' (5 * 60)}";
  };

  libvirtd-volume-windows = baseService // rec {
    after = baseService.after ++ [ "libvirtd-pool.service" ];
    requires = after;

    script = let
      xmlConfig = pkgs.writeText "libvirtd-volume-windows.xml" ''
        <volume type='file'>
          <name>windows</name>

          <key>KEY</key>

          <allocation unit='GB'>1</allocation>
          <capacity unit='TB'>1</capacity>

          <target>
            <format type='qcow2'/>
          </target>
        </volume>
      '';
    in ''
      volumeKey="$(virsh vol-key --pool "default" "windows" || true)"
      virsh vol-create --pool "default" <(sed "s=KEY=$volumeKey=" ${xmlConfig}) || true
    '';
  };

  libvirtd-guest-windows = baseService // rec {
    after = baseService.after ++ [ "libvirtd-network.service" "libvirtd-volume-windows.service" ];
    requires = after;

    script = let
      xmlConfig = pkgs.writeText "libvirtd-guest-windows.xml" ''
        <domain type='kvm'>
          <name>windows</name>

          <uuid>UUID</uuid>

          <os>
            ${
              "" # qemu-kvm -machine help
            }
            <type machine='q35'>hvm</type>

            ${
              "" # TODO secure boot not detected by "PC Health Check"
            }
            <loader readonly='yes' secure='yes' type='pflash'>${pkgs.OVMF.fd}/FV/OVMF_CODE.fd</loader>
            <nvram template='${pkgs.OVMF.fd}/FV/OVMF_VARS.fd'>${nvramDir}/windows_VARS.fd</nvram>
          </os>

          <on_poweroff>restart</on_poweroff>
          <on_reboot>restart</on_reboot>
          <on_crash>restart</on_crash>

          ${
            let
              cores = 9;
              threads = 2;

              vcpupins = map (count: "<vcpupin vcpu='${toString count}' cpuset='0-${toString (cores * threads - 1)}'/>")
                (lib.range 0 (cores * threads - 1));
            in ''
              <vcpu placement='static'>${toString (cores * threads)}</vcpu>

              <cputune>
                ${lib.concatStringsSep "\n" vcpupins}
              </cputune>

              <cpu mode='host-passthrough' migratable='off'>
                <topology sockets='1' cores='${toString cores}' threads='${toString threads}'/>
              </cpu>
            ''
          }

          <memory unit='GB'>32</memory>

          <memoryBacking>
            ${
              "" # TODO use hugepages https://access.redhat.com/solutions/36741
            }
            <source type='memfd'/>
            <access mode='shared'/>
          </memoryBacking>

          <features>
            <acpi/>
            <apic/>
            <pae/>
            <smm state='on'/>

            <kvm>
              <hidden state='on'/>
            </kvm>

            <hyperv>
              <relaxed state='on'/>
              <vapic state='on'/>
              <spinlocks state='on' retries='8191'/>

              ${
                "" # https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Video_card_driver_virtualisation_detection
              }
              <vendor_id state='on' value='randomid'/>
            </hyperv>
          </features>

          <pm>
            <suspend-to-disk enabled='no'/>
            <suspend-to-mem enabled='no'/>
          </pm>

          ${
            "" # TODO correct?
          }
          <clock offset='localtime'>
            <timer name='hpet' present='no'/>
            <timer name='hypervclock' present='yes'/>
            <timer name='pit' tickpolicy='delay'/>
            <timer name='rtc' tickpolicy='catchup' track='guest'/>
            <timer name='tsc' present='yes' mode='native'/>
          </clock>

          <devices>
            <channel type='unix'>
              <target type='virtio' name='org.qemu.guest_agent.0'/>
            </channel>

            <interface type='network'>
              <source network='default'/>
              <mac type='static'/>
            </interface>

            <rng model='virtio'>
              <backend model='random'>/dev/urandom</backend>
            </rng>

            ${
              "" # TODO tpm not detected by "PC Health Check"
            }
            <tpm model='tpm-tis'>
              <backend type='emulator' version='2.0' persistent_state='yes'>
                <active_pcr_banks>
                    <sha512/>
                </active_pcr_banks>
              </backend>
            </tpm>

            ${
              "" # TODO switch to https://looking-glass.io/docs
            }
            <graphics type='spice' autoport='yes' keymap='de-ch'>
              <listen type='address' address='127.0.0.1'/>
            </graphics>

            <channel type="spicevmc">
              <target type="virtio" name="com.redhat.spice.0"/>
              <address type="virtio-serial"/>
            </channel>

            <channel type='spiceport'>
              <source channel='org.spice-space.webdav.0'/>
              <target type='virtio' name='org.spice-space.webdav.0'/>
            </channel>

            <video>
              <model type='virtio' heads='1'/>
            </video>

            <disk type='volume' device='disk'>
              <driver name='qemu' type='qcow2' discard='unmap'/>
              <source pool='default' volume='windows'/>
              <target dev='vdb' bus='sata' rotation_rate='1'/>
              <boot order='2'/>
            </disk>

            ${
              ""

              # INITIAL SETUP

              # <disk type='file' device='cdrom'>
              #   <driver name='qemu' type='raw' cache='none'/>
              #   <source file='PATH_TO_ISO'/>
              #   <target dev='vda' bus='sata'/>
              #   <boot order='1'/>
              #   <readonly/>
              # </disk>
            }

            ${
              "" # TODO once supported add '<readonly/>'
            }
            <filesystem type='mount' accessmode='passthrough'>
              <driver type='virtiofs' queue='1024'/>
              <source dir='${config.services.resilio.syncPath}'/>
              <target dir='Resilio'/>

              <binary path='${pkgs.qemu}/bin/virtiofsd' xattr='on'>
                <cache mode='always'/>
                <lock posix='on' flock='on'/>
              </binary>
            </filesystem>

            <!-- Physical hardware -->

            <!-- PNY Quadro RTX 5000 - VGA compatible controller -->
            <hostdev mode='subsystem' type='pci' managed='yes'>
              <source>
                <address domain='0x0000' bus='0x0b' slot='0x00' function='0'/>
              </source>

              ${
                "" # Dumped with https://github.com/SpaceinvaderOne/Dump_GPU_vBIOS
              }
              <rom file='${./PNY_Quadro_RTX_5000.rom}'/>
            </hostdev>

            <!-- PNY Quadro RTX 5000 - Audio device -->
            <hostdev mode='subsystem' type='pci' managed='yes'>
              <source>
                <address domain='0x0000' bus='0x0b' slot='0x00' function='1'/>
              </source>
            </hostdev>

            <!-- PNY Quadro RTX 5000 - USB controller -->
            <hostdev mode='subsystem' type='pci' managed='yes'>
              <source>
                <address domain='0x0000' bus='0x0b' slot='0x00' function='2'/>
              </source>
            </hostdev>

            <!-- PNY Quadro RTX 5000 - Serial bus controller -->
            <hostdev mode='subsystem' type='pci' managed='yes'>
              <source>
                <address domain='0x0000' bus='0x0b' slot='0x00' function='3'/>
              </source>
            </hostdev>

            ${
              "" # TODO update bus addresses

              # <!-- Delock PCI Express x4 Card to 1 x USB Type-C™ + 4 x USB Type-A - SuperSpeed USB 10 Gbps - 89026 -->
              # <hostdev mode='subsystem' type='pci' managed='yes'>
              #   <source>
              #     <address domain='0x0000' bus='0x0d' slot='0x00' function='3'/>
              #   </source>
              # </hostdev>
            }
          </devices>
        </domain>
      '';
    in ''
      uuid="$(virsh domuuid "windows" || true)"
      virsh define <(sed "s/UUID/$uuid/" ${xmlConfig})

      virsh destroy "windows" || true
      virsh start "windows"
      virsh autostart --disable "windows"
    '';

    preStop = ''
      virsh shutdown "windows"

      ${getShellScriptToWaitForWindowsShutdown ''virsh destroy "windows"'' 60}
    '';
  };

  backup-windows-guest = rec {
    after = [ "libvirtd.service" "libvirtd-guest-windows.service" ];
    requires = after;
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.coreutils-full pkgs.libvirt ];

    preStart = "mkdir -p ${snapshotsDir}/windows";

    script = ''
      volumePath="$(virsh vol-path --pool "default" "windows")"

      virsh snapshot-create-as "windows" --no-metadata --disk-only --quiesce --atomic --diskspec vdb,file="$volumePath.temp"

      cp "$volumePath" "${snapshotsDir}/windows/$(date +"%Y%m%dT%H%M%S")"

      virsh blockcommit "windows" vdb --wait --active --pivot --delete
    '';

    preStop = let
      script = pkgs.writeText "cleanup_windows_snapshots.py" ''
        from datetime import datetime
        from pathlib import Path

        files_to_delete = sorted(
            Path('${snapshotsDir}/windows').iterdir(),
            key=lambda file: datetime.fromtimestamp(file.lstat().st_mtime)
        )[:-7]

        for file in files_to_delete:
            file.unlink()
      '';
    in "${pkgs.python3}/bin/python ${script}";

    startAt = "Sun *-*-* 05:00:00";

    serviceConfig = {
      Restart = "on-abort";
      # TODO get this to work with qemu-libvirtd:qemu-libvirtd
      User = "root";
      Group = "root";
    };
  };
in {
  # TODO pass through audio http://www.draeath.net/blog/it/2021/08/18/libvirt-spice-audio

  # TODO pass through bluetooth

  security.polkit.enable = true;

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      # TODO this option seems to not work, since it's not automatically picked up (remove pkgs.OVMF.fd)
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/libvirtd.nix#L306-L309
      # https://libvirt.org/formatdomain.html#bios-bootloader
      ovmf.enable = true;
      swtpm.enable = true;

      runAsRoot = false;
    };
  };

  system.activationScripts.libvirtd = ''
    mkdir -p ${poolDir} ${nvramDir}
    chown -R qemu-libvirtd:qemu-libvirtd ${poolDir} ${nvramDir}
  '';

  systemd.services = { inherit backup-windows-guest libvirtd-network libvirtd-pool libvirtd-volume-windows libvirtd-guest-windows; };
}
