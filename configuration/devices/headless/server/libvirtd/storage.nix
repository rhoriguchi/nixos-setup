{ pkgs, ... }:
let zfsPoolName = "data";
in {
  systemd.services = {
    libvirtd-pool = rec {
      after = [ "libvirtd.service" ];
      requires = after;
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.coreutils-full pkgs.gnugrep pkgs.gnused pkgs.libvirt ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };

      script = let
        xmlConfig = pkgs.writeTextFile {
          name = "libvirtd-pool.xml";
          text = ''
            <pool type='zfs'>
              <name>default</name>

              <uuid>UUID</uuid>

              <source>
                <name>${zfsPoolName}</name>
              </source>
            </pool>
          '';
          checkPhase = ''
            ${pkgs.gnused}/bin/sed "s/UUID/$(${pkgs.util-linux}/bin/uuidgen)/" $out > xmlConfig
            ${pkgs.libvirt}/bin/virt-xml-validate xmlConfig storagepool
          '';
        };
      in ''
        uuid="$(virsh pool-uuid "default" || true)"
        virsh pool-define <(sed "s/UUID/$uuid/" ${xmlConfig})

        virsh pool-destroy "default" || true
        virsh pool-start "default"
        virsh pool-autostart --disable "default"
      '';

      preStop = ''
        while true; do
          if [ "$(virsh list --name | wc -l)" -gt 1 ]; then
            virsh pool-destroy "default"
          else
            sleep 0.5
          fi
        done
      '';
    };

    libvirtd-volume-windows = rec {
      after = [ "libvirtd.service" "libvirtd-pool.service" ];
      requires = after;

      path = [ pkgs.coreutils-full pkgs.gnugrep pkgs.gnused pkgs.libvirt ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };

      script = let
        xmlConfig = pkgs.writeTextFile {
          name = "libvirtd-volume-windows.xml";
          text = ''
            <volume>
              <name>disk_windows</name>

              <key>KEY</key>

              <allocation unit='GiB'>1</allocation>
              <capacity unit='GiB'>512</capacity>
            </volume>
          '';
          # TODO this check fails even do file is valid
          # checkPhase = ''
          #   ${pkgs.gnused}/bin/sed "s/KEY//" $out > xmlConfig
          #   ${pkgs.libvirt}/bin/virt-xml-validate xmlConfig storagevol
          # '';
        };
      in ''
        volumeKey="$(virsh vol-key --pool "default" "disk_windows" || true)"
        virsh vol-create --pool "default" <(sed "s|KEY|$volumeKey|" ${xmlConfig}) || true
      '';
    };

    libvirtd-volume-steam = rec {
      after = [ "libvirtd.service" "libvirtd-pool.service" ];
      requires = after;

      path = [ pkgs.coreutils-full pkgs.gnugrep pkgs.gnused pkgs.libvirt ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };

      script = let
        xmlConfig = pkgs.writeTextFile {
          name = "libvirtd-volume-steam.xml";
          text = ''
            <volume>
              <name>disk_steam</name>

              <key>KEY</key>

              <allocation unit='GiB'>1</allocation>
              <capacity unit='GiB'>1024</capacity>
            </volume>
          '';
          # TODO this check fails even do file is valid
          # checkPhase = ''
          #   ${pkgs.gnused}/bin/sed "s/KEY//" $out > xmlConfig
          #   ${pkgs.libvirt}/bin/virt-xml-validate xmlConfig storagevol
          # '';
        };
      in ''
        volumeKey="$(virsh vol-key --pool "default" "disk_steam" || true)"
        virsh vol-create --pool "default" <(sed "s|KEY|$volumeKey|" ${xmlConfig}) || true
      '';
    };
  };
}
