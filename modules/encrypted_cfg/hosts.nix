{ lib, config, ... }:
with lib; let
  cfg = config.utils.encrypted.hosts;
in {
  options.utils.encrypted.hosts = mkOption {
    type = with types; attrsOf (listOf str);
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
    sops.templates.encrypted_hosts.content =
      let
        hosts = filterAttrs (_: v: v != []) cfg;
        oneToString = set: ip: ip + " " + concatStringsSep " " set.${ip} + "\n";
        allToString = set: concatMapStrings (oneToString set) (attrNames set);
      in ''
        127.0.0.1 localhost
        ::1 localhost
      '' + (allToString hosts);

    environment.etc."hosts".source = mkForce config.sops.templates.encrypted_hosts.path;

    system.activationScripts.etc.deps = mkAfter [ "renderSecrets" ];
  };
}
