{
  self,
  inputs,
  system,
  ...
}:
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
        excludes = [ ''hardware-configuration\.nix$'' ];
      };
      end-of-file-fixer = {
        enable = true;
        excludes = [
          ''secrets\.nix$''
          ''configuration\/devices\/nnoitra\/iex\.json''
        ];
      };
      fix-byte-order-marker.enable = true;
      lychee = {
        enable = true;
        types = [ "markdown" ];

        settings.flags = "--cache --offline --verbose";
      };
      markdownlint = {
        enable = true;

        settings.configuration.MD013 = false;
      };
      mixed-line-endings = {
        enable = true;
        excludes = [
          ''secrets\.nix$''
          ''configuration\/devices\/nnoitra\/iex\.json''
        ];
      };
      nixfmt = {
        enable = true;
        excludes = [ ''secrets\.nix$'' ];
      };
      trim-trailing-whitespace = {
        enable = true;
        excludes = [ ''secrets\.nix$'' ];
      };
    };
  };
}
// (inputs.deploy-rs.lib.${system}.deployChecks self.deploy)
