{ config, lib, pkgs, ... }:
with lib; let
  cfg = config.modules.clash;
in {
  options.modules.clash = {
    enable = mkEnableOption "Enable Clash Service";
    package = mkOption {
      type = types.package;
      default = pkgs.clash-meta;
      description = "Clash package to use. Default to clash-meta";
    };

    configFile = mkOption {
      type = types.str;
      description = "Clash config file";
    };

    enableUI = mkEnableOption "Enable Clash WebUI";
    uiListen = mkOption {
      type = types.str;
      default = "127.0.0.1:9090";
      description = "Override external controller address";
    };
    uiPackage = mkOption {
      type = types.package;
      default = pkgs.clash-webui-yacd;
      description = "Clash WebUI package to use. Default to clash-webui-yacd";
    };

    extraArgs = mkOption {
      type = types.str;
      default = "";
      description = "Extra arguments";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = with builtins; pathExists (toPath cfg.configFile);
      message = "Config file does not exist.";
    }];
    # security.wrappers.clash = {
    #   owner = "root";
    #   group = "root";
    #   capabilities = "cap_net_bind_service,cap_net_admin=+ep";
    #   source = "${getExe cfg.package}";
    # };

    systemd.services.clash =
    let
      uiScript = optionalString (cfg.enableUI)
        "-ext-ctl ${cfg.uiListen} -ext-ui $CONF_DIR/ui";

      # pkgs.runCommand
      serviceScript = pkgs.writeShellScriptBin "clash-service" ''
        CONF_DIR=/var/lib/clash
        CONF=$1
        echo "Config Path: $CONF"
        ${pkgs.coreutils}/bin/mkdir -p $CONF_DIR
        ln -sf ${cfg.uiPackage}/share/clash/ui $CONF_DIR/ui
        ln -sf ${pkgs.clash-rules-dat-geoip}/share/clash/GeoIP.dat $CONF_DIR/GeoIP.dat
        ln -sf ${pkgs.clash-rules-dat-geosite}/share/clash/GeoSite.dat $CONF_DIR/GeoSite.dat
        ln -sf ${pkgs.clash-rules-dat-country}/share/clash/Country.mmdb $CONF_DIR/Country.mmdb

        ${getExe cfg.package} -d $CONF_DIR -f $CONF ${uiScript} ${cfg.extraArgs}
      '';
    in {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        LoadCredential = "config:${cfg.configFile}";
        ExecStart = "${getExe serviceScript} %d/config";
        Restart = "on-failure";
      };
    };
  };
}