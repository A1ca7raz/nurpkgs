{ options, config, lib, pkgs, ... }:
with lib; let
  cfg = config.services.clash;
in
{
  options.services.clash = {
    enable = mkEnableOption "Enable Clash Service";
    package = mkOption {
      type = types.package;
      default = pkgs.clash-meta;
      description = "Clash package to use. Default to clash-meta";
    };

    configFile = mkOption {
      type = types.string;
      description = "Clash config file";
    };

    enableWebUi = mkEnableOption "Enable Clash WebUI";
    webUiListen = mkOption {
      type = with types; nullOr string;
      default = "127.0.0.1:2023";
      description = "Override external controller address";
    };
    webUiPackage = mkOption {
      type = types.package;
      default = pkgs.clash-webui-yacd;
      description = "Clash WebUI package to use. Default to clash-webui-yacd";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
      clash-rules-dat-country
      clash-rules-dat-geoip
      clash-rules-dat-geosite
    ];

    # security.wrappers.clash = {
    #   owner = "root";
    #   group = "root";
    #   capabilities = "cap_net_bind_service,cap_net_admin=+ep";
    #   source = "${getExe cfg.package}";
    # };

    systemd.services.clash = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        LoadCredential = "config:${cfg.configFile}";
        ExecStart = "${getExe cfg.package} -d /etc/clash/ -f %d/config"
          + optionalString (cfg.enableWebUi && ! isNull cfg.webUiListen)
            " -ext-ctl ${cfg.webUiListen} -ext-ui ${cfg.webUiPackage}/share/clash-webui";
        Restart = "on-failure";
      };
    };
  };
}