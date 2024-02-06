{ lib, config, pkgs, ... }:
with lib; let
  cfg = config.utils.kconfig;
  inherit (import ./types.nix) fileModule ruleModule;
  fileType = types.submoduleWith {
    modules = [ fileModule ];
    shorthandOnlyDefinesConfig = true;
    specialArgs = { inherit pkgs; };
  };
  ruleType = types.submodule ruleModule;
in {
  options.utils.kconfig = {
    files = mkOption {
      type = types.attrsOf fileType;
      default = {};
      description = "attrset of KDE configuration files";
    };

    rules = mkOption {
      type = types.listOf ruleType;
      default = [];
      description = "extra rules of creating KDE configuration files";
    };
  };

  config = mkIf (cfg.rules != []) {
    utils.kconfig.files = foldl (acc: i: acc // (
      # Merge rules
      if hasAttrByPath [ i.f "items" ] acc
      then {
        ${i.f}.items = acc.${i.f}.items ++ [{ inherit (i) g k v; }];
      } else {
        ${i.f}.items = [{ inherit (i) g k v; }];
      }
    )) {} cfg.rules;
  };
}