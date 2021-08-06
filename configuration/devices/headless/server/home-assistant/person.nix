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
      user_id = "3e1a5aea4f3d424fa7a751e028186923";
      device_trackers = [ "device_tracker.ryan_pixel_4a_5g" ];
    }
  ];
}
