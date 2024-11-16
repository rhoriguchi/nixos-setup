{
  dconf = {
    enable = true;

    settings = {
      "org/virt-manager/virt-manager" = {
        system-tray = true;
        xmleditor-enabled = true;
      };
      "org/virt-manager/virt-manager/confirm" = {
        delete-storage = true;
        forcepoweroff = true;
        pause = true;
        poweroff = false;
        removedev = false;
        unapplied-dev = true;
      };
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu+ssh://xxlpitu-server/system" ];
        uris = [ "qemu+ssh://xxlpitu-server/system" ];
      };
      "org/virt-manager/virt-manager/details".show-toolbar = true;
      "org/virt-manager/virt-manager/new-vm" = {
        cpu-default = "default";
        graphics-type = "vnc";
        storage-format = "default";
      };
      "org/virt-manager/virt-manager/stats" = {
        enable-cpu-poll = true;
        enable-disk-poll = true;
        enable-memory-poll = true;
        enable-net-poll = true;
        update-interval = 5;
      };
      "org/virt-manager/virt-manager/vmlist-fields" = {
        cpu-usage = true;
        disk-usage = false;
        host-cpu-usage = false;
        network-traffic = false;
      };
    };
  };
}
