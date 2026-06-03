{ inputs, pkgs, system }:
let
  inherit (builtins) attrValues filter isAttrs foldl';

  mkBundle = name: apps: {
    "bundle_${name}" = pkgs.stdenv.mkDerivation {
      name = "${name}-bundle";
      srcs = filter isAttrs (attrValues apps);

      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out
        for _src in $srcs; do
          [[ -e "$out/$(basename $_src)" ]] || ln -s "$_src"  "$out/$(basename $_src)"
        done
      '';
    };
  };
in
{
  externalPackages = with inputs; {
    hermes-agent = hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
    kimi-code-unstable = kimi-code.packages.${pkgs.stdenv.hostPlatform.system}.default;
    noctalia-nighty = noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.override { calendarSupport = true; };
    dms-nighty = dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

    inherit (niri-flake.packages.${pkgs.stdenv.hostPlatform.system})
      niri-unstable
      xwayland-satellite-unstable
    ;
  };

  externalBundles = with inputs; [
    (mkBundle "lanzaboote" lanzaboote.packages.${system})
    (mkBundle "sops-nix" sops-nix.packages.${system})
  ];

  cachePackages = with pkgs; {
    inherit obsidian unrar veracrypt wpsoffice teamspeak_server;
  };
}
