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
    concatStrings
    escapeShellArgs
    flatten
    strings
    filterAttrs
  ;

  inherit (builtins)
    attrNames
    attrValues
    concatStringsSep
    readFile
  ;

  cfg = config.environment.overlay.users;

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

        "/run/overlay_base/${user}" =
        let
          pak = pkgs.runCommand "overlay-${user}-pack" {} (
            let
              scripts = concatStrings (mapAttrsToList (n: v: ''
                insertFile ${escapeShellArgs [
                  (sourceStorePath v)           # Source
                  v.target                      # relTarget
                ]}
              '') files);
              # NOTE: not chown here due to infrec when accessing config.users
            in
            (readFile ./scripts/insert_file.sh) +
            scripts + ''
              chmod -cR +w ./build
              ${pkgs.erofs-utils}/bin/mkfs.erofs -zlz4 "$out" ./build/
            ''
          );
        in {
          device = pak.outPath;
          fsType = "erofs";
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
          # 1. Prepare for mounting overlayfs
          "overlayfile-${user}-pre-mount" =
            let
              next = "run-overlay_files-${strings.escapeC ["-"] user}.mount";
            in {
              description = "Create Upperdir and Workdir for overlay files of ${user}";
              before = [ next ];
              requiredBy = [ next ];
              after = [ "tmp.mount" ];
              requires = [ "tmp.mount" ];
              wantedBy = [ "local-fs.target" ];

              unitConfig.DefaultDependencies = "no";

              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = "yes";
              };

              # NOTE: use idmapped bind mount alternatively
              script = ''
                user=`id -u ${user}`
                group=`id -g ${user}`
                mkdir -p ${upper_dir}/${user}
                mkdir -p ${work_dir}/${user}
                chown ${user}:${group} ${upper_dir}/${user}
                [[ $user = '1000' && $group = '100' ]] || \
                  mount --bind -o X-mount.idmap="u:1000:$user:1 g:100:$group:1" \
                    /run/overlay_base/${user}/ /run/overlay_base/${user}/
              '';

              preStop = ''
                rm -rf ${upper_dir}/${user}/*
                rm -rf ${upper_dir}/${user}/.*
                rm -rf ${work_dir}/${user}/*
                rm -rf ${work_dir}/${user}/.*
                umount /run/overlay_base/${user}/
              '';
            };

          # 2. Mount overlayfs

          # 3. Make symlink to HOME
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
