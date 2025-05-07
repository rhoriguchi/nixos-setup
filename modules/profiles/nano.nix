{ pkgs, ... }: {
  environment = {
    systemPackages = [ pkgs.nano ];

    variables.EDITOR = "nano";
  };
}
