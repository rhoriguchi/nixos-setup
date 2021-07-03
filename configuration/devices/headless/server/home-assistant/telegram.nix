{ ... }: {
  services.home-assistant.config = {
    telegram_bot = [{
      platform = "polling";
      api_key = (import ../../../../secrets.nix).services.home-assistant.config.telegram_bot.api_key;
      allowed_chat_ids = [ (import ../../../../secrets.nix).services.home-assistant.config.notify.telegram.ryan.chat_id ];
    }];

    notify = [{
      platform = "telegram";
      name = "Ryan";
      chat_id = (import ../../../../secrets.nix).services.home-assistant.config.notify.telegram.ryan.chat_id;
    }];
  };
}
