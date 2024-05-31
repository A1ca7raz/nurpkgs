{ lib, config, ... }:
with lib; let
  cfg = config.utils.encrypted.hosts;
  cfgr = config.utils.encrypted.reversedHosts;
in {
  options.utils.encrypted = {
    hosts = mkOption {
      type = with types; lazyAttrsOf (coercedTo str (x: [x]) (listOf str));
      default = {};
      example = literalExpression ''
        {
          "127.0.0.1" = [ "foo.bar.baz" ];
          "192.168.0.2" = [ "fileserver.local" "nameserver.local" ];
        };
      '';
      description = ''
        Locally defined maps of hostnames to IP addresses.
      '';
    };

    reversedHosts = mkOption {
      type = with types; lazyAttrsOf (coercedTo str (x: [x]) (listOf str));
      default = {};
      example = literalExpression ''
        {
          "foo.bar.baz" = [ "127.0.0.1" ];
          "fileserver.local" = [ "127.0.0.1" "::1" ];
        };
      '';
      description = ''
        Locally defined maps of hostnames to IP addresses but hostname as the key.
      '';
    };
  };

  config = mkIf (cfg != {} || cfgr != {}) {
    sops.templates.encrypted_hosts.mode = "0444";
    sops.templates.encrypted_hosts.content =
      let
        filterHosts = filterAttrs (_: v: v != []);
        mergeHosts = foldlAttrs
          (acc: n: v:
            if acc ? "${n}"
            then acc // { "${n}" = unique (acc."${n}" ++ v); }
            else acc // { "${n}" = v; }
          );

        localhost = {
          "127.0.0.1" = [ "localhost" ];
          "::1" = [ "localhost" ];
        };
        oldhosts = filterHosts config.networking.hosts;
        hosts = filterHosts cfg;
        hostsr = filterHosts cfgr;

        finalHosts = mergeHosts (mergeHosts hosts localhost) oldhosts;

        finalHostsStr =
          let
            oneToString = set: ip: ip + " " + concatStringsSep " " set.${ip} + "\n";
          in
            concatMapStrings (oneToString finalHosts) (attrNames finalHosts);

        reversedHostsStr =
          let
            oneToString = set: host:
              builtins.foldl'
                (acc: ip:
                  ip + " " + host + "\n" + acc
                )
                ""
                set."${host}";
          in
            concatMapStrings (oneToString hostsr) (attrNames hostsr);
      in
        finalHostsStr + reversedHostsStr + config.networking.extraHosts;

    environment.etc."hosts".source = mkForce config.sops.templates.encrypted_hosts.path;

    utils.encrypted.enable = true;
  };
}
