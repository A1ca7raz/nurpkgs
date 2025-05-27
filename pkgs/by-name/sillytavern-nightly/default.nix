{
  source,
  lib,
  buildNpmPackage,
  bash,
  nodejs
}:
buildNpmPackage rec {
  pname = "sillytavern";
  inherit (source) version src;
  root = "SillyTavern-staging";

  npmDepsHash = "sha256-IZMwDgazY+6oyuOlE7zdWcDn5D2/8v2mHX9yDBwK+4I=";
  buildPhase = "true";
  installPhase = ''
    mkdir -p $out/{bin,lib}
    mv * $out/lib
    rm $out/lib/node_modules/.package-lock.json
    cat > $out/bin/sillytavern <<- EOF
    #!${bash}/bin/bash

    ${nodejs}/bin/node $out/lib/server.js \$@
    EOF
    chmod +x $out/bin/sillytavern
  '';

  meta = {
    description = "LLM Frontend for Power Users";
    homepage = "https://github.com/SillyTavern/SillyTavern";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sillytavern";
    platforms = lib.platforms.all;
  };
}
