{
  disko.devices.disk.main = {
    type = "disk";
    # TODO change
    device = "/dev/nvme0n1";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        luks = {
          size = "100%";

          content = {
            type = "luks";
            name = "cryptroot";
            askPassword = true;
            settings.allowDiscards = true;

            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/mnt/boot";
            };
          };
        };
      };
    };
  };
}
