rec {
  itemModule = { config, lib, ... }:
    let
      inherit (lib) mkOption types fold concatStringsSep;

      groupstr = concatStringsSep " " (fold (x: y: [''--group "${x}"''] ++ y) [] config.groups);
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
          default = "${groupstr} --key '${config.key}' '${config.value}'";
          visible = false;
          readOnly = true;
        };
      };
    };
  
  fileModule = { name, config, lib, pkgs, ... }:
    let
      inherit (lib) mkOption types concatMapStrings;
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

        script = mkOption {
          type = types.str;
          default = (concatMapStrings mkScript config.items) + "\n" + config.extraScript;
          visible = false;
          readOnly = true;
        };

        path = mkOption {
          type = types.path;
          visible = false;
          readOnly = true;
        };
      };

      config = {
        path = pkgs.runCommand name {
          nativeBuildInputs = [ pkgs.libsForQt5.kconfig ];
        } config.script;
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