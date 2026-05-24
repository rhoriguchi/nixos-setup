{ pkgs, secrets, ... }:
{
  programs.mcp = {
    enable = true;

    servers = {
      github = {
        command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
        args = [ "stdio" ];
        env.GITHUB_PERSONAL_ACCESS_TOKEN = secrets.gemini.mcpServers.github.accessToken;
      };

      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        args = [ "--" ];
      };
    };
  };
}
