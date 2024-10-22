{
  services.home-assistant.config.automation = [{
    alias = "Backup Home Assistant every day at 00:00:00 with a random delay of ${toString (60 * 60)} seconds";
    trigger = [{
      trigger = "time";
      at = "00:00:00";
    }];
    action = [ { delay = "{{ range(0, ${toString (60 * 60)}) | random }}"; } { action = "backup.create"; } ];
  }];
}
