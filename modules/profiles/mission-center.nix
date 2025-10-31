{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.mission-center
  ];

  programs.dconf = {
    enable = true;

    profiles.user.databases = [
      {
        settings."io/missioncenter/MissionCenter" = {
          performance-page-cpu-graph = lib.gvariant.mkInt32 2;
          performance-page-network-use-bytes = false;
        };
      }
    ];
  };
}
