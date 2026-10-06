{ pkgs, ... }:
{
  programs.mcp = {
    enable = true;

    servers = {
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        args = [ "--" ];
      };
    };
  };
}
