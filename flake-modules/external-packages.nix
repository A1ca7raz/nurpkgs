{ inputs, ... }:
{
  perSystem = { pkgs, system, self', ... }:
    let
      mkBundle = name: apps: {
        "bundle_${name}" = pkgs.stdenv.mkDerivation {
          name = "${name}-bundle";
          srcs = with builtins; filter isAttrs (attrValues apps);

          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out
            for _src in $srcs; do
              [[ -e "$out/$(basename $_src)" ]] || ln -s "$_src"  "$out/$(basename $_src)"
            done
          '';
        };
      };

      externalPackages = with inputs; {
        hermes-agent = hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
        kimi-code-unstable = kimi-code.packages.${pkgs.stdenv.hostPlatform.system}.default;
        noctalia-nighty = noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.override { calendarSupport = true; };
        dms-nighty = dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

        inherit (niri-nix.packages.${pkgs.stdenv.hostPlatform.system})
          niri-unstable
          xwayland-satellite-unstable
        ;
      };

      cachedPackages = {
        inherit (pkgs)
          obsidian
          unrar
          veracrypt
          wpsoffice
          teamspeak_server
        ;
      };
    in {
      legacyPackages = externalPackages;
      checks = cachedPackages //
        mkBundle "lanzaboote" inputs.lanzaboote.packages.${system} //
        mkBundle "sops-nix" inputs.lanzaboote.packages.${system} //
        mkBundle "dms-plugins" inputs.dms-plugin-registry.packages.${system}
      ;
    };
}
