{ lib, config, ... }:
with lib; {
  imports = lib.importsFiles ./.;

  options.utils.encrypted.enable = mkOption {
    type = types.boolByOr;
    default = false;
    visible = false;
  };

  config = mkIf config.utils.encrypted.enable {
    system.activationScripts.etc.deps = mkAfter [ "setupSecrets" ];
  };
}
