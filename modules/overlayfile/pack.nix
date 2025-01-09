{ pkgs, config, lib, ... }:
let
  inherit (lib)
    mkIf
    concatStrings
    mapAttrsToList
    escapeShellArgs
  ;

  inherit (builtins)
    mapAttrs
    map
    attrNames
    readFile
  ;

  cfg_ = config.environment.overlay;
  cfg = cfg_.users;

  inherit (import ./lib.nix { inherit lib; }) sourceStorePath;
in {
  config = mkIf (cfg != {}) (
    let
      mapper = f: mapAttrs f cfg;
    in {
      assertions =
        map (u: {
          assertion =
            let
              user = config.users.users."${u}";
              uid = user.uid;
              group = user."${u}";
              gid = config.users.groups."${group}".gid;
            in
              uid != null && gid != null;
          message = ''
            UID and GID of User ${u} should be set when overlay files is enabled.
          '';
        }) (attrNames cfg);

      environment.overlay._filepacks = mapper (
        user: files:
          pkgs.runCommand "overlay-${user}-pack" (
            let
              scripts = concatStrings (mapAttrsToList (n: v: ''
                insertFile ${escapeShellArgs [
                  (sourceStorePath v)           # Source
                  v.target                      # relTarget
                ]}
              '') files );

              uid = config.users.users."${user}".uid;
              gid = config.users.groups."${config.users.users."${user}".group}".gid;
            in
            (readFile ./scripts/insert_file.sh) +
            scripts + ''
              chown -cR ${uid}:${gid} ./build
              chmod -cR 1700 ./build
              ${pkgs.erofs-utils}/bin/mkfs.erofs -zlz4 "$out" ./build/
            ''
          )
      );
    }
  );
}
