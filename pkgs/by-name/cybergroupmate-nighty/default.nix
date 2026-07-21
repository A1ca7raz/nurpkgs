{
  source,
  lib,
  callPackage,
  makeWrapper,
  pnpm_11,
  nodejs,
  stdenv,

  python3Packages,
  uv,
  jq,
  yq,
  ffmpeg,
  unzip,
  zip,
  wget,
  curl,
  imagemagick,
  git,
  cacert,
  pandoc,
  poppler-utils,
  dnsutils,
  ruff,
  gnumake,
  sqlite,

  runtimeDependencies ? [
    python3Packages.python
    python3Packages.pip
    ruff
    uv
    jq
    yq
    ffmpeg
    unzip
    zip
    wget
    curl
    imagemagick
    git
    cacert
    pandoc
    poppler-utils
    dnsutils
    gnumake
    sqlite
  ],
  extraRuntimeDependencies ? []
}:
let
  pnpm = pnpm_11;

  frontend = callPackage ./frontend.nix {
    inherit source pnpm nodejs;
  };
  unwrapped = callPackage ./unwrapped.nix {
    inherit source pnpm nodejs;
  };

  inherit (builtins)
    concatStringsSep
    map
  ;
in
stdenv.mkDerivation rec {
  inherit (source) src;
  pname = "cybergroupmate-nighty";
  version = "${source.date}-unstable";

  buildInputs = runtimeDependencies ++ extraRuntimeDependencies;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    makeWrapper ${nodejs}/bin/node $out/bin/cybergroupmate \
      --add-flags ${unwrapped}/node_modules/tsx/dist/cli.mjs \
      --add-flags ${unwrapped}/src/main.ts \
      --prefix PATH : ${nodejs}/bin \
      ${concatStringsSep "\n" (
        map (bin: "--prefix PATH : ${bin}/bin \\") buildInputs
      )}
      --set NODE_ENV production \
      --set LOG_LEVEL info
    ln -s $out/bin/cybergroupmate $out/bin/cgm

    runHook postInstall
  '';

  passthru = {
    inherit frontend unwrapped;
  };
}
