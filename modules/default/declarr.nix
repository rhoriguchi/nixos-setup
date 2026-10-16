{
  config,
  lib,
  ...
}:
let
  arrServices = [
    "prowlarr"
    "radarr"
    "sonarr"
  ];

  declarrEnabled =
    !config.boot.isContainer && lib.any (name: config.services.${name}.enable) arrServices;
in
{
  config = {
    assertions = map (
      name:
      let
        apiKeyFile = config.services.prometheus.exporters."exportarr-${name}".apiKeyFile;
      in
      {
        assertion = !config.services.${name}.enable || apiKeyFile != null;
        message = "services.prometheus.exporters.exportarr-${name}.apiKeyFile must be set, the arr profile reuses it for services.${name}.apiKeyFile";
      }
    ) arrServices;

    services =
      lib.genAttrs arrServices (name: {
        apiKeyFile = lib.mkIf config.services.${name}.enable "$CREDENTIALS_DIRECTORY/apiKey";
      })
      // {
        declarr = {
          enable = lib.mkDefault declarrEnabled;

          config = lib.mkIf config.services.declarr.enable {
            declarr = {
              stateDir = "/var/lib/declarr";

              globalResolvePaths = [
                "$.*.config.host.apiKey"
                "$.*.applications.*.fields.apiKey"
              ];
            };
          };
        };
      };

    systemd.services =
      lib.genAttrs arrServices (
        name:
        lib.mkIf config.services.${name}.enable {
          serviceConfig.LoadCredential = [
            "apiKey:${toString config.services.prometheus.exporters."exportarr-${name}".apiKeyFile}"
          ];
        }
      )
      // {
        declarr = lib.mkIf config.services.declarr.enable {
          serviceConfig.RestartSec = 30;
        };
      };
  };
}
