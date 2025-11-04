{ config, ... }:
{
  programs = {
    zoxide = {
      enable = true;

      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;

      options = [ "--cmd cd" ];
    };

    superfile.zoxidePackage = config.programs.zoxide.package;
  };
}
