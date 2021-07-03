{ ... }: {
  services.home-assistant.config.lametric = {
    client_id = (import ../../../../secrets.nix).services.home-assistant.config.lametric.client_id;
    client_secret = (import ../../../../secrets.nix).services.home-assistant.config.lametric.client_secret;
  };
}
