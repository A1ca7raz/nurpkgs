{ inputs, lib, ... }:
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
        inherit (llm-agents.packages.${pkgs.stdenv.hostPlatform.system})
          cli-proxy-api
          codex
          hermes-agent
          kimi-code
          opencode
          omp
          pi
          skills
          dsh
        ;

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
