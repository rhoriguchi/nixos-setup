{ pkgs, lib, ... }:
let
  usbDevices = {
    "Antlion Audio USB Sound Card" = {
      vendorId = "0d8c";
      productId = "002b";
    };
    "HP Keyboard" = {
      vendorId = "0461";
      productId = "4d8a";
    };
    "Logitech HD Webcam C510" = {
      vendorId = "046d";
      productId = "081d";
    };
    "Razer BlackShark V2 Pro" = {
      vendorId = "1532";
      productId = "0528";
    };
    # TODO remove?
    "Razer BlackWidow Ultimate 2013" = {
      vendorId = "1532";
      productId = "011a";
    };
    "Razer Ouroboros 2012" = {
      vendorId = "1532";
      productId = "0032";
    };
    "Samsung Duo Plus - 64 GB" = {
      vendorId = "090c";
      productId = "1000";
    };
  };

  baseDir = "/var/lib/virt";
  poolDir = "${baseDir}/images";
  nvramDir = "${baseDir}/nvram";

  getUsbHostdev = name: vendorId: productId: ''
    <!-- ${name} -->
    <hostdev mode='subsystem' type='usb' managed='yes'>
      <source startupPolicy='optional'>
        <vendor id='0x${vendorId}'/>
        <product id='0x${productId}'/>
      </source>
    </hostdev>
  '';

  setPath = "export PATH=${lib.makeBinPath [ pkgs.coreutils-full pkgs.gnugrep pkgs.gnused pkgs.libvirt ]}";

  baseService = rec {
    after = [ "libvirtd.service" ];
    requires = after;
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
  };

  libvirtd-network = (baseService // {
    script = let
      config = pkgs.writeText "libvirtd-network.xml" ''
        <network>
          <name>default</name>

          <uuid>UUID</uuid>

          <bridge name='virbr0'/>

          <forward mode='nat'/>

          <ip address='172.16.1.1' netmask='255.255.255.0'>
            <dhcp>
              <range start='172.16.1.2' end='172.16.1.254'/>
            </dhcp>
          </ip>

          <ip family='ipv6' address='2001:db8:ca2:2::1' prefix='64'/>
        </network>
      '';

      # TODO improve virsh net-start "${network}" || virsh net-update "${network}" modify SECTION <(sed "s/UUID/$uuid/" ${xmlFile}) --live
    in ''
      ${setPath}

      uuid="$(virsh net-uuid 'default' || true)"
      virsh net-define <(sed "s/UUID/$uuid/" ${config})

      virsh net-destroy "default" || true
      virsh net-start "default"
      virsh net-autostart --disable "default"
    '';

    # TODO wait till all guests are stopped
    preStop = ''
      ${setPath}

      virsh net-destroy "default"
    '';
  });

  libvirtd-pool = (baseService // {
    script = let
      config = pkgs.writeText "libvirtd-pool.xml" ''
        <pool type='dir'>
          <name>default</name>

          <uuid>UUID</uuid>

          <target>
            <path>${poolDir}</path>
          </target>
        </pool>
      '';
    in ''
      ${setPath}

      uuid="$(virsh pool-uuid 'default' || true)"
      virsh pool-define <(sed "s/UUID/$uuid/" ${config})

      virsh pool-destroy "default" || true
      virsh pool-start "default"
      virsh pool-autostart --disable "default"
    '';

    # TODO wait till all guests are stopped
    preStop = ''
      ${setPath}

      virsh pool-destroy "default"
    '';
  });

  libvirtd-volume-windows = (baseService // rec {
    after = baseService.after ++ [ "libvirtd-pool.service" ];
    requires = after;

    script = let
      config = pkgs.writeText "libvirtd-volume-windows.xml" ''
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
      ${setPath}

      volumeKey="$(virsh vol-key --pool default 'windows' || true)"
      virsh vol-create --pool default <(sed "s=KEY=$volumeKey=" ${config}) || true
    '';
  });

  libvirtd-guest-windows = (baseService // rec {
    after = baseService.after ++ [ "libvirtd-network.service" "libvirtd-volume-windows.service" ];
    requires = after;

    script = let
      config = pkgs.writeText "libvirtd-guest-windows.xml" ''
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
              cores = 6;
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

          ${
            ""

            # TODO "internal error: unable to map backing store for guest RAM: Cannot allocate memory"
            # https://wiki.archlinux.org/title/KVM#Enabling_huge_pages
            # <memoryBacking>
            #   <hugepages/>
            # </memoryBacking>
          }

          <features>
            <acpi/>
            <apic/>
            <hyperv>
              <relaxed state='on'/>
              <vapic state='on'/>
              <spinlocks state='on' retries='8191'/>
            </hyperv>
            <kvm>
              <hidden state='on'/>
            </kvm>
            <pae/>
            <smm state='on'/>
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

            <controller type='pci' model='pcie-root'/>
            ${
              let controllers = map (_: "<controller type='pci' model='pcie-root-port'/>") (lib.range 0 9);
              in lib.concatStringsSep "\n" controllers
            }

            <graphics type='spice' autoport='yes' keymap='de-ch'>
              <listen type='address' address='127.0.0.1'/>
            </graphics>

            <video>
              <model type='virtio' heads='1'/>
            </video>

            ${
              "" # TODO marks disk as SSD https://serverfault.com/a/924717
            }
            <disk type='volume' device='disk'>
              <driver name='qemu' type='qcow2' discard='unmap'/>
              <source pool='default' volume='windows'/>
              <target dev='vda' bus='virtio'/>
              <boot order='10'/>
            </disk>

            ${
              ""

              # INITIAL SETUP

              # <!-- https://www.microsoft.com/software-download/windows10 -->
              # <!-- https://www.microsoft.com/software-download/windows11 -->
              # <disk type='file' device='cdrom'>
              #   <driver name='qemu' type='raw' cache='none'/>
              #   <source file='PATH_TO_ISO'/>
              #   <target dev='sda' bus='sata'/>
              #   <boot order='1'/>
              #   <readonly/>
              # </disk>

              # <!-- https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -->
              # <disk type='file' device='cdrom'>
              #   <driver name='qemu' type='raw' cache='none'/>
              #   <source file='PATH_TO_ISO'/>
              #   <target dev='sdb' bus='sata'/>
              #   <readonly/>
              # </disk>
            }

            <!-- Physical hardware -->

            ${
              let usbHostdevs = lib.attrValues (lib.mapAttrs (key: value: getUsbHostdev key value.vendorId value.productId) usbDevices);
              in lib.concatStringsSep "\n" usbHostdevs
            }
          </devices>
        </domain>
      '';
    in ''
      ${setPath}

      uuid="$(virsh domuuid 'windows' || true)"
      virsh define <(sed "s/UUID/$uuid/" ${config})

      virsh destroy "windows" || true
      virsh start "windows"
      virsh autostart --disable "windows"
    '';

    preStop = ''
      ${setPath}

      virsh shutdown "windows"
      let "timeout = $(date +%s) + ${toString (2 * 60)}"
      while [ "$(virsh list --name | grep --count '^windows$')" -gt 0 ]; do
        if [ "$(date +%s)" -ge "$timeout" ]; then
          virsh destroy "windows"
        else
          # The machine is still running, let's give it some time to shut down
          sleep 0.5
        fi
      done
    '';
  });
in {
  # TODO share resilio dir with guest
  # https://unix.stackexchange.com/questions/86071/use-virt-manager-to-share-files-between-linux-host-and-windows-guest/86083#86083

  boot = {
    kernelModules = [ "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" "vfio" ];

    # GPU > nix-shell -p pciutils --run "lspci -nnk | grep 'NVIDIA\|Radeon'"
    kernelParams = [
      "vfio-pci.disable_vga=1"

      # ZOTAC GTX 680 AMP!
      "vfio-pci.ids=10de:1180,10de:0e0a"

      # Sapphire Radeon HD 6870
      "vfio-pci.ids=1002:6738,1002:aa88"
    ];
  };

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      # TODO this option seems to not work, since it's not automatically picked up
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/libvirtd.nix#L306-L309
      # https://libvirt.org/formatdomain.html#bios-bootloader
      ovmf.enable = true;
      swtpm.enable = true;

      runAsRoot = false;
    };
  };

  services.udev.extraRules = let
    getUsbHotplugRule = action: name: vendorId: productId:
      let hostdev = pkgs.writeText "hostdev-${vendorId}-${productId}.xml" (getUsbHostdev name vendorId productId);
      in ''
        ACTION=="${action}", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="${vendorId}", ENV{ID_MODEL_ID}=="${productId}", RUN+="${pkgs.libvirt}/bin/virsh attach-device 'windows' ${hostdev}"'';

    usbHotplugRules = lib.attrValues (lib.mapAttrs (key: value: [
      (getUsbHotplugRule "add" key value.vendorId value.productId)
      (getUsbHotplugRule "remove" key value.vendorId value.productId)
    ]) usbDevices);
  in lib.concatStringsSep "\n" (lib.flatten usbHotplugRules);

  system.activationScripts.libvirtd = ''
    mkdir -p ${poolDir} ${nvramDir}
    chown -R qemu-libvirtd:qemu-libvirtd ${baseDir}
  '';

  systemd.services = { inherit libvirtd-network libvirtd-pool libvirtd-volume-windows libvirtd-guest-windows; };
}