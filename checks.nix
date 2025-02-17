{ self, inputs, system, ... }:
{
  pre-commit = inputs.git-hooks.lib.${system}.run {
    src = ./.;

    default_stages = [ "pre-commit" ];

    addGcRoot = true;

    hooks = {
      actionlint.enable = true;
      check-case-conflicts.enable = true;
      check-executables-have-shebangs.enable = true;
      check-merge-conflicts.enable = true;
      check-shebang-scripts-are-executable.enable = true;
      check-symlinks.enable = true;
      deadnix = {
        enable = true;
        excludes = [ "hardware-configuration\\.nix$" ];
      };
      end-of-file-fixer = {
        enable = true;
        excludes = [ "secrets\\.nix$" ];
      };
      fix-byte-order-marker.enable = true;
      markdownlint = {
        enable = true;

        settings.configuration.MD013 = false;
      };
      mixed-line-endings = {
        enable = true;
        excludes = [ "secrets\\.nix$" ];
      };
      nixfmt-classic = {
        enable = true;
        excludes = [ "secrets\\.nix$" ];

        settings.width = 140;
      };
      trim-trailing-whitespace = {
        enable = true;
        excludes = [ "secrets\\.nix$" ];
      };
    };
  };
} // (inputs.deploy-rs.lib.${system}.deployChecks self.deploy)
