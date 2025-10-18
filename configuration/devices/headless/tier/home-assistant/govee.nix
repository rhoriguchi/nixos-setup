{
  networking.firewall.allowedUDPPorts = [ 4002 ];

  services.home-assistant.config.automation = [
    {
      alias = "Reset bedroom nightstand lamp left when turned on";
      triggers = [
        {
          trigger = "state";
          entity_id = "light.bedroom_nightstand_lamp_left";
          from = "off";
          to = "on";
        }
      ];
      actions = [
        {
          action = "light.turn_on";
          target.entity_id = "light.bedroom_nightstand_lamp_left";
          data.rgb_color = [
            255
            157
            0
          ];
        }
      ];
    }
    {
      alias = "Reset bedroom nightstand lamp right when turned on";
      triggers = [
        {
          trigger = "state";
          entity_id = "light.bedroom_nightstand_lamp_right";
          from = "off";
          to = "on";
        }
      ];
      actions = [
        {
          action = "light.turn_on";
          target.entity_id = "light.bedroom_nightstand_lamp_right";
          data.rgb_color = [
            255
            157
            0
          ];
        }
      ];
    }
  ];
}
