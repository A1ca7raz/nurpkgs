{ config, lib, pkgs, ... }:
# https://github.com/LEXUGE/flake/blob/main/modules/clash/default.nix
# https://github.com/oluceps/nixos-config/blob/main/modules/clash-m/default.nix
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

    listen = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Override clash external controller address";
    };

    configFile = mkOption {
      type = types.str;
      description = "Clash config file";
    };

    extraArgs = mkOption {
      type = types.str;
      default = "";
      description = "Extra arguments";
    };

    webUI = {
      enable = mkEnableOption "Enable Clash WebUI";
      port = mkOption {
        type = types.int;
        default = 6789;
        description = "Clash WebUI Listen Port.";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.clash-webui-yacd;
        description = "Clash WebUI package to use. Default to clash-webui-yacd";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      users.users.clash = {
        description = "Clash deamon user";
        isSystemUser = true;
        group = "clash";
      };
      users.groups.clash = {};

      systemd.services.clash =
      let
        listenArg = optionalString (builtins.isString cfg.listen) "-ext-ctl ${cfg.listen}";

        startScript = pkgs.writeShellScriptBin "clash-service-start" ''
          CONF_DIR=${"\$\{STATE_DIRECTORY:-/var/lib/clash}"}
          CONF=$1
          echo "Config Path: $CONF"
          mkdir -p $CONF_DIR
          ln -sf ${pkgs.clash-rules-dat-geoip}/share/clash/GeoIP.dat $CONF_DIR/GeoIP.dat
          ln -sf ${pkgs.clash-rules-dat-geosite}/share/clash/GeoSite.dat $CONF_DIR/GeoSite.dat
          ln -sf ${pkgs.clash-rules-dat-country}/share/clash/Country.mmdb $CONF_DIR/Country.mmdb

          ${getExe cfg.package} -d $CONF_DIR -f $CONF ${listenArg} ${cfg.extraArgs}
        '';

        caps = [
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];
      in {
        description = "Clash networking service";
        path = with pkgs; [ coreutils ];
        # Don't start if the config file doesn't exist.
        unitConfig = {
          # NOTE: configPath is for the original config which is linked to the following path.
          ConditionPathExists = cfg.configFile;
        };

        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          LoadCredential = "config:${cfg.configFile}";
          ExecStart = "${getExe startScript} %d/config";
          Restart = "on-failure";
          StateDirectory = "clash";
          CapabilityBoundingSet = caps;
          AmbientCapabilities = caps;
          User = "clash";
        };
      };
    })
    (mkIf cfg.webUI.enable {
      # WebUI
      services.lighttpd = {
        enable = true;
        port = cfg.webUI.port;
        document-root = "${cfg.webUI.package}/share/clash/ui";
      };
    })
  ];
}