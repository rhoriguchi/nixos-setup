{ secrets, ... }: {
  networking.wireless = {
    enable = true;

    extraConfig = ''
      p2p_disabled=1
    '';

    networks."47555974" = secrets.wifis."47555974";
  };
}
