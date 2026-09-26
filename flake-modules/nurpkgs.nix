{ inputs, lib, flake-parts-lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    mapAttrs
    filterAttrs
    attrNames
    intersectAttrs
    ;
  inherit (builtins)
    readDir
    pathExists
    ;

  byName = ../pkgs/by-name;

  # Every by-name directory's default.nix is a flake-parts module.
  isModuleDir = name: type:
    type == "directory"
    && pathExists (byName + "/${name}/default.nix");

  moduleDirs = attrNames (filterAttrs isModuleDir (readDir byName));

  # Top-level (system-agnostic) declarations.
  nurpkgsCfg = config.nurpkgs;

  updaterOutputType = types.submodule {
    options = {
      script = mkOption {
        type = types.package;
        description = "Runnable update script derivation.";
      };
      packages = mkOption {
        type = types.listOf types.str;
        description = "涉及包：更新后内容可能变化的软件包集合。";
      };
    };
  };
in
{
  imports = [
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "updater";
      file = ./nurpkgs.nix;
      option = mkOption {
        type = types.lazyAttrsOf updaterOutputType;
        default = { };
        description = ''
          Per-system updater units, exposed as flake output
          `updater.<system>.<name>`. Run with
          `nix run .#updater.<system>.<name>.script`.
        '';
      };
    })
  ] ++ map (n: byName + "/${n}/default.nix") moduleDirs;

  options.nurpkgs = {
    packages = mkOption {
      type = types.attrsOf (types.oneOf [
        types.path
        (types.functionTo types.raw)
      ]);
      default = { };
      description = "Package files (paths preferred) contributed by per-package modules.";
    };
    updater = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          packages = mkOption {
            type = types.listOf types.str;
            default = [ name ];
            description = "涉及包；缺省只含与 Updater 同名的包。";
          };
          script = mkOption {
            type = types.nullOr (types.functionTo types.package);
            default = null;
            description = ''
              更新脚本构造函数（pkgs: derivation），按原样作为
              updater.<system>.<name>.script 输出，不做额外包装。
              缺省取唯一涉及包的 passthru.updateScript，并注入
              UPDATE_NIX_ATTR_PATH；涉及包不止一个时必须显式声明。
            '';
          };
        };
      }));
      default = { };
      description = "Updater（更新单元）声明。";
    };
  };

  config.flake.nurpkgs = nurpkgsCfg;

  config.perSystem =
    { config, system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        config.allowUnfree = true;
        inherit system;
      };
      specialArgs = { inherit inputs; };

      # Call a package file (path or function) with pkgs and specialArgs
      # available for argument intersection.  Only declared arguments are
      # passed, and everything is lazy.  Note: functions passing through the
      # module system may arrive as functor sets ({ __functor, __functionArgs }),
      # so use lib.isFunction/lib.functionArgs rather than the builtins.
      callPackage = f:
        let
          package = if lib.isFunction f then f else import f;
          args = intersectAttrs
            (lib.functionArgs package)
            (specialArgs // { inherit pkgs; });
        in
          pkgs.callPackage package args;
    in
    {
      _module.args.pkgs = pkgs;

      packages = mapAttrs (_: callPackage) nurpkgsCfg.packages;

      updater = mapAttrs
        (
          name: ucfg:
            let
              # Drop declared names that have no package on this system.
              packages = builtins.filter (p: config.packages ? ${p}) ucfg.packages;
            in
            {
              inherit packages;
              script =
                if ucfg.script != null then
                  ucfg.script pkgs
                else
                  let
                    mainName =
                      if builtins.length packages == 1 then
                        builtins.head packages
                      else
                        throw "nurpkgs.updater.${name}: no explicit script declared and 'packages' does not resolve to exactly one valid package on this system";
                    updateScript =
                      config.packages.${mainName}.passthru.updateScript
                        or (throw "nurpkgs.updater.${name}: package '${mainName}' has no passthru.updateScript");
                  in
                    pkgs.writeShellScriptBin "update-${name}" ''
                      export UPDATE_NIX_ATTR_PATH=${lib.escapeShellArg mainName}
                      exec ${
                        if lib.isDerivation updateScript then lib.getExe updateScript else lib.escapeShellArgs updateScript
                      } "$@"
                    '';
            }
        )
        nurpkgsCfg.updater;
    };
}
