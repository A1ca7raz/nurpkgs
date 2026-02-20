{
  fetchFromGitHub,
  lib,
  stdenv
}:
# https://github.com/taj-ny/nix-config/blob/main/pkgs/kwin-effects-geometry-change/default.nix
stdenv.mkDerivation rec {
  pname = "kwin-effects-geometry-change";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "peterfajdiga";
    repo = "kwin4_effect_geometry_change";
    rev = "v${version}";
    hash = "sha256-p4FpqagR8Dxi+r9A8W5rGM5ybaBXP0gRKAuzigZ1lyA=";
  };

#   patches = [ ./polonium-virtual-desktop-animation-fix.patch ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/kwin/effects/kwin4_effect_geometry_change
    cp -r package/* $out/share/kwin/effects/kwin4_effect_geometry_change
  '';

#   meta = {
#     description = "A KWin animation for windows moved or resized by programs or scripts ";
#     homepage = "https://github.com/peterfajdiga/kwin4_effect_geometry_change";
#     license = lib.licenses.gpl3Plus;
#   };
}
