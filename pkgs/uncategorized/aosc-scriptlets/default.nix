{
  source,
  lib,
  stdenv,
  pkg-config,
  installShellFiles,
  python3
}:
stdenv.mkDerivation {
  inherit (source) pname version src;

  nativeBuildInputs = [ installShellFiles pkg-config ];

  buildInputs = [ python3 ];

  installPhase = ''
    install -D $src/pushpkg/pushpkg $out/bin/pushpkg

    # Install completions
    installShellCompletion --cmd pushpkg \
      --bash $src/pushpkg/completions/pushpkg.bash \
      --fish $src/pushpkg/completions/pushpkg.fish
  '';
}
