{ ... }: {
  services.home-assistant.config.person = [
    {
      name = "Giulia";
      id = "giulia";
      # TODO HOME-ASSISTANT add user and add user_id
      # user_id = "";
      device_trackers = [ "device_tracker.giulia_oneplus_nord" ];
    }
    {
      name = "Ryan";
      id = "ryan";
      user_id = "c3f7bed3cdc641bba4f8cd007e68eda9";
      # TODO HOME-ASSISTANT update with pixel
      device_trackers = [ "device_tracker.huawei_p10_1f4aed902ae701" ];
    }
  ];
}
