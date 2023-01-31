{ pkgs, ... }:
let
  poolDir = "/var/lib/virt/images";
  # TODO commented, use rsync instead of cp so if it get's canceled it can continue
  # snapshotsDir = "/mnt/Data/Snapshots";
in {
  system.activationScripts.libvirtd-pool = ''
    mkdir -p ${poolDir}
    chown -R qemu-libvirtd:qemu-libvirtd ${poolDir}
  '';

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
            <pool type='dir'>
              <name>default</name>

              <uuid>UUID</uuid>

              <target>
                <path>${poolDir}</path>
              </target>
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
            <volume type='file'>
              <name>windows</name>

              <key>KEY</key>

              <allocation unit='GiB'>1</allocation>
              <capacity unit='TiB'>1</capacity>

              <target>
                <format type='qcow2'/>
              </target>
            </volume>
          '';
          checkPhase = ''
            ${pkgs.gnused}/bin/sed "s/KEY//" $out > xmlConfig
            ${pkgs.libvirt}/bin/virt-xml-validate xmlConfig storagevol
          '';
        };
      in ''
        volumeKey="$(virsh vol-key --pool "default" "windows" || true)"
        virsh vol-create --pool "default" <(sed "s|KEY|$volumeKey|" ${xmlConfig}) || true
      '';
    };

    # TODO commented, use rsync instead of cp so if it get's canceled it can continue
    # backup-windows-guest = rec {
    #   after = [ "libvirtd.service" "libvirtd-guest-windows.service" ];
    #   requires = after;
    #   wantedBy = [ "multi-user.target" ];

    #   path = [ pkgs.coreutils-full pkgs.libvirt ];

    #   startAt = "Sun *-*-* 05:00:00";

    #   serviceConfig = {
    #     Restart = "on-abort";
    #     # TODO get this to work with qemu-libvirtd:qemu-libvirtd
    #     User = "root";
    #     Group = "root";
    #   };

    #   preStart = "mkdir -p ${snapshotsDir}/windows";

    #   script = ''
    #     volumePath="$(virsh vol-path --pool "default" "windows")"

    #     virsh snapshot-create-as "windows" --no-metadata --disk-only --quiesce --atomic --diskspec vda,file="$volumePath.temp"

    #     cp "$volumePath" "${snapshotsDir}/windows/$(date +"%Y%m%dT%H%M%S")"

    #     virsh blockcommit "windows" vda --wait --active --pivot --delete
    #   '';

    #   preStop = let
    #     script = pkgs.writeText "cleanup_windows_snapshots.py" ''
    #       from datetime import datetime
    #       from pathlib import Path

    #       files_to_delete = sorted(
    #           Path('${snapshotsDir}/windows').iterdir(),
    #           key=lambda file: datetime.fromtimestamp(file.lstat().st_mtime)
    #       )[:-7]

    #       for file in files_to_delete:
    #           file.unlink()
    #     '';
    #   in "${pkgs.python3}/bin/python ${script}";
    # };
  };
}
