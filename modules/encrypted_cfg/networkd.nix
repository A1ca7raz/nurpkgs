{ lib, config, ... }:
with lib; let
  cfg = config.utils.encrypted.networkd;
in {
  options.utils.encrypted.networkd = mkOption {
    type = with types; attrsOf (attrsOf (attrsOf (coercedTo (either int str) (x: [(toString x)]) (listOf str))));
    default = {};
    description = ''
      Definition of systemd networks.
    '';
  };

  config = mkIf (cfg != {}) {
    assertions = foldlAttrs
      (acc: n: v:
        acc ++ [{
          assertion = ! config.systemd.network.networks ? "${n}";
          message = ''
            Encrypted Networkd Module takes over the network configuration of ${n}.
            Please check out `systemd.network.networks.${n}` and migrate it to Encrypted Networkd Module.
          '';
        }]
      )
      []
      cfg;

    sops.templates = foldlAttrs
      (acc: n: v:
        recursiveUpdate acc (
          let
            tplName = "encrypted_networkd_${n}";
          in {
            "${tplName}" = {
              content = foldlAttrs
                (acc: n: v:
                  acc + "[${n}]\n"
                    + foldlAttrs
                      (acc: n: v:
                        acc + (concatMapStringsSep "\n" (x: "${n}=${x}") v) + "\n"
                      )
                      ""
                      v
                    + "\n"
                )
                ""
                v;
              mode = "0444";
            };
          }
        )
      )
      {}
      cfg;
    
    environment.etc = foldlAttrs
      (acc: n: v:
        recursiveUpdate acc (
          let
            tplName = "encrypted_networkd_${n}";
            fileName = "systemd/network/${n}.network";
          in {
            "${fileName}".source = mkForce config.sops.templates."${tplName}".path;
          }
        )
      )
      {}
      cfg;

    utils.encrypted.enable = true;

    systemd.services.systemd-networkd.restartTriggers = mapAttrsToList
      (n: v: v.content)
      (filterAttrs
        (n: v: hasPrefix "encrypted_networkd_" n)
        config.sops.templates
      );
  };
}
