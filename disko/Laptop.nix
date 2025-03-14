{
  disko.devices.disk.main = {
    type = "disk";
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
            name = "cryptroot";
            type = "luks";

            askPassword = true;
            settings.allowDiscards = true;

            content = {
              type = "filesystem";
              format = "ext4";

              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
