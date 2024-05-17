{ lib, config, ... }:
with lib; let
  cfg = config.utils.encrypted.hosts;
in {
  options.utils.encrypted.hosts = mkOption {
    type = with types; attrsOf (coercedTo str (x: [x]) (listOf str));
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

  config = mkIf (cfg != {}) {
    sops.templates.encrypted_hosts.mode = "0444";
    sops.templates.encrypted_hosts.content =
      let
        filterHosts = filterAttrs (_: v: v != []);
        oldhosts = filterHosts config.networking.hosts;
        hosts = filterHosts cfg;
        mergedHosts = foldlAttrs
          (acc: n: v:
            if acc ? "${n}"
            then acc // { "${n}" = unique (acc."${n}" ++ v); }
            else acc // { "${n}" = v; }
          )
          hosts
          oldhosts;

        oneToString = set: ip: ip + " " + concatStringsSep " " set.${ip} + "\n";
        allToString = set: concatMapStrings (oneToString set) (attrNames set);
      in ''
        127.0.0.1 localhost
        ::1 localhost
      '' + (allToString mergedHosts) + config.networking.extraHosts;

    environment.etc."hosts".source = mkForce config.sops.templates.encrypted_hosts.path;

    utils.encrypted.enable = true;
  };
}
