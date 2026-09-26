{
  lib,
  stdenv,
  scdoc,
  gnumake,
  fetchFromGitHub,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ndrop";
  # 0-unstable-<commit date, UTC as reported by nix-update's atom feed>.
  version = "0-unstable-2026-01-24";

  src = fetchFromGitHub {
    owner = "Schweber";
    repo = "ndrop";
    rev = "f2fb1c611811c48b48cd0f0fecab4f3f935e7405";
    hash = "sha256-/Xco1sr76+F3mAIGq29yp5Y6FPcXS/AVXDpwZ1+rLQk=";
  };

  nativeBuildInputs = [
    scdoc
    gnumake
  ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    export PREFIX=$out
    make install
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" "--version=branch" ];
  };

  meta = {
    description = "Emulate 'tdrop' in niri (run, show and hide programs via keybind)";
    homepage = "https://github.com/Schweber/ndrop";
    license = lib.licenses.agpl3Only;
    mainProgram = "ndrop";
    platforms = lib.platforms.linux;
  };
})
