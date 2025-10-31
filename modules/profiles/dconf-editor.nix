{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.dconf-editor
  ];

  programs.dconf = {
    enable = true;

    profiles.user.databases = [
      {
        settings."ca/desrt/dconf-editor/Settings".show-warning = false;
      }
    ];
  };
}
