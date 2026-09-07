{
  lib,
  pkgs,
  libCustom,
  ...
}:
let
  format = pkgs.formats.yaml { };
in
{
  imports = libCustom.getImports ./.;

  options.services.authelia.instances = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.settings.identity_providers.oidc.authorization_policies = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, ... }:
              {
                freeformType = format.type;

                config = {
                  default_policy = "deny";

                  rules = [
                    {
                      policy = "one_factor";
                      subject = [
                        "group:admin"
                        "group:${name}"
                      ];
                    }
                  ];
                };
              }
            )
          );
        };
      }
    );
  };
}
