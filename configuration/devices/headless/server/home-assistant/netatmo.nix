{ ... }: {
  services.home-assistant.config.netatmo = {
    client_id = (import ../../../../secrets.nix).services.home-assistant.config.netatmo.client_id;
    client_secret = (import ../../../../secrets.nix).services.home-assistant.config.netatmo.client_secret;
  };
}
