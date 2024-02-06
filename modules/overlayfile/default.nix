# https://github.com/nix-community/home-manager/blob/master/modules/files.nix
{ config, lib, pkgs, ... }:
with lib; let
  cfg_ = config.environment.overlay;
  cfg = cfg_.users;

  storePath = cfg_.tempStorePath;
  inherit (import ./lib.nix { inherit lib; }) sourceStorePath;

  fileType = types.submoduleWith {
    modules = [ (import ./file-type.nix) ];
    shorthandOnlyDefinesConfig = true;
    specialArgs = { inherit pkgs; };
  };
in {
  options.environment.overlay = {
    users = mkOption {
      type = with types; attrsOf (attrsOf fileType);
      default = {};
      description = "Attribute set of files to link into the user home.";
    };

    tempStorePath = mkOption {
      type = types.str;
      default = "";
      description = "A path to store overlay files which is out of Nix store";
    };

    debug = mkEnableOption "Create .overlay-debug file for debugging";
  };

  config = mkIf (cfg != {}) (
    let
      upper_dir = "/tmp/overlay_files_upper";
      work_dir = "/tmp/overlay_files_work";

      mapper = func: mapAttrs' func cfg;
      folder = func: foldlAttrs func {} cfg;
    in {
      assertions = [
        {
          assertion = cfg_ != "";
          message = ''
            environment.overlay.tempStorePath should be set when overlay files is enabled.
          '';
        }
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

      fileSystems = (mapper (user: files: {
        name = "/run/overlay_files/${user}";
        value = {
          device = "overlay";
          fsType = "overlay";
          options = [
            "rw" "nosuid"
            "lowerdir=${storePath}/${user}"
            "upperdir=${upper_dir}/${user}"
            "workdir=${work_dir}/${user}"
          ];
          noCheck = true;
          depends = [
            "/nix" "/run"
            "${upper_dir}/${user}"
            "${work_dir}/${user}"
          ];
        };
      }));

      systemd.services = (folder (sum: user: files:
        let
          group = config.users.users.${user}.group;

          overlayPkg = pkgs.runCommand "overlay-packfile-${user}" {} (
            let
              scripts = concatStrings (mapAttrsToList (n: v: ''
                insertFile ${escapeShellArgs [
                  (sourceStorePath v)           # Source
                  v.target                      # relTarget
                ]}
              '') files );
            in 
            (builtins.readFile ./scripts/insert_file.sh) +
            (if cfg_.debug then traceVal scripts else scripts)
          );
        in {
          # 1. Remove old files and copy new files' symlinks
          "overlayfile-${user}-copy-check" =
            let
              _store = "${storePath}/${user}";
              storeHash = baseNameOf overlayPkg;
              storeLock = "${_store}-lock-${storeHash}";

              next = "overlayfile-${user}-pre-mount.service";
            in {
              description = "Check availablity of overlay files for ${user} and copy them";
              before = [ next ];
              requiredBy = [ next ];
              wantedBy = [ "local-fs.target" ];
              # bindsTo = "overlayfile-${user}-pre-mount.service";

              environment = {
                OUT = _store;
              };

              unitConfig = {
                DefaultDependencies = "no";
                # ConditionPathExists = "!${storeLock}";
              };

              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = "yes";
              };

              script = ''
                [[ -f ${storeLock} ]] && exit 0
                sou="$(realpath -m "${overlayPkg}")"

                mkdir -p "$OUT"
                rm -vf "$OUT-lock-"*
                rm -vrf "$OUT"/*
                rm -vrf "$OUT"/.*

                cp -vrfHL "$sou"/. "$OUT"
                echo "$sou" > "${storeLock}"
                chown -cR ${user}:${group} "$OUT"
                chmod -cR 1700 "$OUT"
              '';

              preStop = ''
                rm -r "${storeLock}"
              '';
            };

          # 2. Prepare for mounting overlayfs
          "overlayfile-${user}-pre-mount" =
            let
              prev = "overlayfile-${user}-copy-check.service";
              next = "run-overlay_files-${strings.escapeC ["-"] user}.mount";
            in {
              description = "Create Upperdir and Workdir for overlay files of ${user}";
              before = [ next ];
              requiredBy = [ next ];
              after = [ prev ];
              bindsTo = [ prev ];
              partOf = [ prev ];
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