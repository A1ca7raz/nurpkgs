# https://github.com/nix-community/home-manager/blob/master/modules/files.nix
{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkIf
    types
    mkOption
    foldlAttrs
    foldAttrs
    mapAttrsToList
    flatten
    strings
    filterAttrs
  ;

  inherit (builtins)
    attrNames
    attrValues
    concatStringsSep
  ;

  cfg_ = config.environment.overlay;
  cfg = cfg_.users;

  fileType = types.submoduleWith {
    modules = [ (import ./file-type.nix) ];
    shorthandOnlyDefinesConfig = true;
    specialArgs = { inherit pkgs; };
  };
in {
  imports = [
    ./pack.nix
  ];

  options.environment.overlay = {
    users = mkOption {
      type = with types; attrsOf (attrsOf fileType);
      default = {};
      description = "Attribute set of files to link into the user home.";
    };

    _filepacks = mkOption {
      type = with types; attrsOf (package);
      visible = false;
    };
  };

  config = mkIf (cfg != {}) (
    let
      upper_dir = "/tmp/overlay_files_upper";
      work_dir = "/tmp/overlay_files_work";

      folder = func: foldlAttrs func {} cfg;
    in {
      assertions = [
        (let
          dups = attrNames
            (filterAttrs (n: v: v > 1)
              (foldAttrs (acc: v: acc + v) 0
                (builtins.map (v: { ${v.target} = 1; })
                  (flatten (mapAttrsToList (n: v: attrValues v) cfg))
                )
              )
            );
          dupsStr = concatStringsSep ", " dups;
        in {
          assertion = dups == [];
          message = ''
            Conflicting managed target files: ${dupsStr}
            This may happen, for example, if you have a configuration similar to
              environment.overlay.users.<name> = {
                conflict1 = { source = ./foo.nix; target = "baz"; };
                conflict2 = { source = ./bar.nix; target = "baz"; };
              }
          '';
        })
      ];

      fileSystems = folder (acc: user: files: {
        "/run/overlay_files/${user}" = {
          device = "overlay";
          fsType = "overlay";
          options = [
            "rw" "nosuid"
            "lowerdir=/run/overlay_base/${user}"
            "upperdir=${upper_dir}/${user}"
            "workdir=${work_dir}/${user}"
            "x-systemd.after=run-overlay_base-${strings.escapeC ["-"] user}.mount"
            "x-systemd.requires=run-overlay_base-${strings.escapeC ["-"] user}.mount"
          ];
          noCheck = true;
          depends = [
            "/nix" "/run"
            "${upper_dir}/${user}"
            "${work_dir}/${user}"
          ];
        };
        "/run/overlay_base/${user}" = {
          device = cfg_._filepacks.${user};
          fsType = "overlay";
          noCheck = true;
          depends = [
            "/nix" "/run"
          ];
        };
      } // acc);

      systemd.services = (folder (sum: user: files:
        let
          group = config.users.users.${user}.group;
        in {
          # 1. Remove old files and copy new files' symlinks
          # "overlayfile-${user}-copy-check" =
          #   let
          #     _store = "${storePath}/${user}";
          #     storeHash = baseNameOf overlayPkg;
          #     storeLock = "${_store}-lock-${storeHash}";

          #     next = "overlayfile-${user}-pre-mount.service";
          #   in {
          #     description = "Check availablity of overlay files for ${user} and copy them";
          #     before = [ next ];
          #     requiredBy = [ next ];
          #     wantedBy = [ "local-fs.target" ];
          #     # bindsTo = "overlayfile-${user}-pre-mount.service";

          #     environment = {
          #       OUT = _store;
          #     };

          #     unitConfig = {
          #       DefaultDependencies = "no";
          #       # ConditionPathExists = "!${storeLock}";
          #     };

          #     serviceConfig = {
          #       Type = "oneshot";
          #       RemainAfterExit = "yes";
          #     };

          #     script = ''
          #       [[ -f ${storeLock} ]] && exit 0
          #       sou="$(realpath -m "${overlayPkg}")"

          #       mkdir -p "$OUT"
          #       rm -vf "$OUT-lock-"*
          #       rm -vrf "$OUT"/*
          #       rm -vrf "$OUT"/.*

          #       cp -vrfHL "$sou"/. "$OUT"
          #       echo "$sou" > "${storeLock}"
          #       chown -cR ${user}:${group} "$OUT"
          #       chmod -cR 1700 "$OUT"
          #     '';

          #     preStop = ''
          #       rm -r "${storeLock}"
          #     '';
          #   };

          # 2. Prepare for mounting overlayfs
          "overlayfile-${user}-pre-mount" =
            let
              # prev = "overlayfile-${user}-copy-check.service";
              next = "run-overlay_files-${strings.escapeC ["-"] user}.mount";
            in {
              description = "Create Upperdir and Workdir for overlay files of ${user}";
              before = [ next ];
              requiredBy = [ next ];
              after = [ "tmp.mount" ];
              # bindsTo = [ prev ];
              requires = [ "tmp.mount" ];
              # partOf = [ prev ];
              wantedBy = [ "local-fs.target" ];

              unitConfig.DefaultDependencies = "no";

              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = "yes";
              };

              script = ''
                mkdir -p ${upper_dir}/${user}
                mkdir -p ${work_dir}/${user}
                chown ${user}:${group} ${upper_dir}/${user}
              '';

              preStop = ''
                rm -rf ${upper_dir}/${user}/*
                rm -rf ${upper_dir}/${user}/.*
                rm -rf ${work_dir}/${user}/*
                rm -rf ${work_dir}/${user}/.*
              '';
            };

          # 3. Mount overlayfs

          # 4. Make symlink to HOME
          "overlayfile-${user}-link-file" =
            let
              prev = "run-overlay_files-${strings.escapeC ["-"] user}.mount";
            in {
              description = "Link overlay files for ${user}";
              after = [ prev ];
              partOf = [ prev ];
              bindsTo = [ prev ];
              wantedBy = [ "local-fs.target" ];

              unitConfig.DefaultDependencies = "no";

              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = "yes";
              };

              script = ''
                cp -vsrfp "/run/overlay_files/${user}"/. "${config.users.users.${user}.home}"
              '';
            };
        } // sum
      ));
    });
}
