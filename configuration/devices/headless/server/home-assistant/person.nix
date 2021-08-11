{ ... }: {
  services.home-assistant.config.person = [{
    name = "Ryan";
    id = "ryan";
    user_id = "3e1a5aea4f3d424fa7a751e028186923";
    device_trackers = [ "device_tracker.ryan_pixel_4a_5g" ];
  }];
}
