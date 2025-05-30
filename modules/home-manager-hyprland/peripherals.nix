{
  wayland.windowManager.hyprland.settings = {
    monitor = [ ", highres, auto, 1" ];

    input = {
      kb_layout = "ch";
      kb_variant = "de_nodeadkeys";
      kb_model = "pc105";

      resolve_binds_by_sym = true;

      touchpad = {
        clickfinger_behavior = true;
        natural_scroll = true;
      };
    };

    device = [
      {
        name = "keychron-k8-keychron-k8";
        kb_layout = "us";
        kb_variant = "en_US";
        kb_model = "pc104";
      }
      {
        name = "dygma-defy-keyboard";
        kb_layout = "us";
        kb_variant = "en_US";
        kb_model = "pc104";
      }
    ];

    gestures.workspace_swipe = true;
  };
}
