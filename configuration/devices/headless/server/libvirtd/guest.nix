{ config, lib, pkgs, ... }:
let nvramDir = "/var/lib/virt/nvram";
in {
  virtualisation.libvirtd.qemu.swtpm.enable = true;

  system.activationScripts.libvirtd-guest = ''
    mkdir -p ${nvramDir}
    chown -R qemu-libvirtd:qemu-libvirtd ${nvramDir}
  '';

  # TODO pass through audio http://www.draeath.net/blog/it/2021/08/18/libvirt-spice-audio
  # TODO pass through bluetooth

  systemd.services.libvirtd-guest-windows = rec {
    after = [ "libvirtd.service" "libvirtd-network.service" "libvirtd-volume-windows.service" ];
    requires = after;
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.coreutils-full pkgs.gnugrep pkgs.gnused pkgs.libvirt ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };

    script = let
      xmlConfig = pkgs.writeTextFile {
        name = "libvirtd-guest-windows.xml";
        text = ''
          <domain type='kvm'>
            <name>windows</name>

            <uuid>UUID</uuid>

            <os>
              <!-- qemu-kvm -machine help -->
              <type machine='q35'>hvm</type>
            </os>

            <on_poweroff>destroy</on_poweroff>
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

                  <feature policy='require' name='topoext'/>
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

                <!-- https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Video_card_driver_virtualisation_detection -->
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

                <!-- Same mac is used in network.nix -->
                <mac address='52:54:00:49:cc:f3'/>
              </interface>

              <rng model='virtio'>
                <backend model='random'>/dev/urandom</backend>
              </rng>

              <tpm model='tpm-tis'>
                <backend type='emulator' version='2.0' persistent_state='yes'>
                  <active_pcr_banks>
                      <sha512/>
                  </active_pcr_banks>
                </backend>
              </tpm>

              <graphics type='spice' autoport='yes' keymap='de-ch'>
                <listen type='address' address='127.0.0.1'/>

                <image compression='auto_glz'/>
                <streaming mode='filter'/>
              </graphics>

              <video>
                <model type='virtio' heads='1'/>
              </video>

              <sound model='ich9'>
                <audio id='1'/>
              </sound>
              <audio id='1' type='spice'/>

              <channel type='spicevmc'>
                <target type='virtio' name='com.redhat.spice.0'/>
              </channel>

              ${
              # INITIAL SETUP
              # Get image from https://www.microsoft.com/en-us/software-download/windows10ISO

              # ''
              #   <disk type='file' device='cdrom'>
              #     <driver name='qemu' type='raw' cache='none'/>
              #     <source file='PATH'/>
              #     <target dev='vda' bus='sata'/>
              #     <boot order='1'/>
              #     <readonly/>
              #   </disk>
              # ''

                ""
              }

              <disk type='volume' device='disk'>
                <driver name='qemu' type='raw'/>
                <source pool='default' volume='disk_windows'/>
                <target dev='vdb' bus='sata' rotation_rate='1'/>
                <boot order='2'/>
              </disk>

              <disk type='volume' device='disk'>
                <driver name='qemu' type='raw'/>
                <source pool='default' volume='disk_steam'/>
                <target dev='vdc' bus='sata' rotation_rate='1'/>
              </disk>

              ${
                "" # TODO once supported add '<readonly/>'
              }
              <filesystem type='mount' accessmode='passthrough'>
                <driver type='virtiofs' queue='1024'/>
                <source dir='${config.services.resilio.syncPath}'/>
                <target dir='Resilio'/>

                <binary path='${pkgs.virtiofsd}/bin/virtiofsd' xattr='on'/>
              </filesystem>

              <!-- Physical hardware -->

              <!-- PNY Quadro RTX 5000 - VGA compatible controller -->
              <hostdev mode='subsystem' type='pci' managed='yes'>
                <source>
                  <address domain='0x0000' bus='0x01' slot='0x00' function='0'/>
                </source>

                <!-- Dumped with https://github.com/rhoriguchi/Dump_GPU_vBIOS -->
                <rom file='${./PNY_Quadro_RTX_5000.rom}'/>
              </hostdev>

              <!-- PNY Quadro RTX 5000 - Audio device -->
              <hostdev mode='subsystem' type='pci' managed='yes'>
                <source>
                  <address domain='0x0000' bus='0x01' slot='0x00' function='1'/>
                </source>
              </hostdev>

              <!-- PNY Quadro RTX 5000 - USB controller -->
              <hostdev mode='subsystem' type='pci' managed='yes'>
                <source>
                  <address domain='0x0000' bus='0x01' slot='0x00' function='2'/>
                </source>
              </hostdev>

              <!-- PNY Quadro RTX 5000 - Serial bus controller -->
              <hostdev mode='subsystem' type='pci' managed='yes'>
                <source>
                  <address domain='0x0000' bus='0x01' slot='0x00' function='3'/>
                </source>
              </hostdev>

              ${
                "" # TODO currently does not work

                # <!-- Delock PCI Express x4 Card to 1 x USB Type-C™ + 4 x USB Type-A - SuperSpeed USB 10 Gbps - 89026 -->
                # <!-- USB controller: ASMedia Technology Inc. ASM2142 USB 3.1 Host Controller -->
                # <hostdev mode='subsystem' type='pci' managed='yes'>
                #   <source>
                #     <address domain='0x0000' bus='0x04' slot='0x00' function='0'/>
                #   </source>
                # </hostdev>
              }
            </devices>
          </domain>
        '';
        checkPhase = ''
          ${pkgs.gnused}/bin/sed "s/UUID/$(${pkgs.util-linux}/bin/uuidgen)/" $out > xmlConfig
          ${pkgs.libvirt}/bin/virt-xml-validate xmlConfig domain
        '';
      };
    in ''
      uuid="$(virsh domuuid "windows" || true)"
      virsh define <(sed "s/UUID/$uuid/" ${xmlConfig})

      virsh destroy "windows" || true
      virsh start "windows"
      virsh autostart --disable "windows"
    '';

    preStop = ''
      virsh shutdown "windows"

      let "timeout = $(date +%s) + ${toString 60}"

      while [ "$(virsh list --name | grep --count "^windows$")" -gt 0 ]; do
        if [ "$(date +%s)" -ge "$timeout" ]; then
          virsh destroy "windows"
        else
          sleep 0.5
        fi
      done
    '';
  };
}
