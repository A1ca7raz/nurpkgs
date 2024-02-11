rec {
  itemModule = { config, lib, ... }:
    let
      inherit (lib) mkOption types fold concatStringsSep escapeShellArg;

      groupstr = concatStringsSep " " (fold (x: y: [''--group ${escapeShellArg x}''] ++ y) [] config.groups);
    in {
      options = {
        groups = mkOption {
          type = with types; coercedTo str (x: [x]) (listOf str);
          default = config.g;
          description = "Groups to look in";
        };

        key = mkOption {
          type = types.str;
          default = config.k;
          description = "Key to look for";
        };
        
        value = mkOption {
          type = types.str;
          default = config.v;
          description = "The value to write";
        };

        g = mkOption {
          type = with types; coercedTo str (x: [x]) (listOf str);
          default = [];
          description = "Groups to look in";
        };
        k = mkOption {
          type = types.str;
          default = "";
          description = "Key to look for";
        };
        v = mkOption {
          type = types.str;
          default = "";
          description = "The value to write";
        };

        args = mkOption {
          type = types.str;
          # NOTE: need to escape '\'
          default = "${groupstr} --key ${escapeShellArg config.key} ${escapeShellArg config.value}";
          visible = false;
          readOnly = true;
        };
      };
    };
  
  fileModule = { name, config, lib, pkgs, ... }:
    let
      inherit (lib) mkEnableOption mkOption types concatMapStrings traceVal;
      cmd = args: ''kwriteconfig5 --file "$out" ${args}'';
      mkScript = x: (cmd x.args) + "\n";

      itemType = types.submodule itemModule;
    in {
      options = {
        items = mkOption {
          type = types.listOf itemType;
          default = [];
          description = "list of KDE configuration file item";
        };

        extraScript = mkOption {
          type = types.str;
          default = "";
          description = "extra script run after kwriteconfig";
        };

        extraScriptPre = mkOption {
          type = types.str;
          default = "";
          description = "extra script run before kwriteconfig";
        };

        extraScriptPost = mkOption {
          type = types.str;
          default = config.extraScript;
          description = "extra script run after kwriteconfig";
        };

        script = mkOption {
          type = types.str;
          default = config.extraScriptPre
            + "\n" + (concatMapStrings mkScript config.items)
            + "\n" + config.extraScriptPost;
          visible = false;
          readOnly = true;
        };

        path = mkOption {
          type = types.path;
          visible = false;
          readOnly = true;
        };

        debug = mkEnableOption "enable debug for ${name}";
      };

      config = {
        path = pkgs.runCommand name {
          nativeBuildInputs = [ pkgs.libsForQt5.kconfig ];
        } (
          if config.debug
          then traceVal config.script
          else config.script
        );
      };
    };

  ruleModule = { lib, ... }:
    let
      inherit (lib) mkOption types;
    in {
      options = {
        f = mkOption {
          type = types.str;
          default = "";
          description = "Name of config file";
        };
        g = mkOption {
          type = with types; coercedTo str (x: [x]) (listOf str);
          default = [];
          description = "Groups to look in";
        };
        k = mkOption {
          type = types.str;
          default = "";
          description = "Key to look for";
        };
        v = mkOption {
          type = types.str;
          default = "";
          description = "The value to write";
        };
      };
    };
} 