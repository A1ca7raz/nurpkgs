{
  source,
  lib,
  buildNpmPackage,
  bash,
  nodejs,
  fetchFromGitHub
}:
buildNpmPackage rec {
  pname = "sillytavern";
  inherit (source) version src;
  root = "SillyTavern-staging";

  npmDepsHash = "sha256-OkvNSO4yoyic2HhHsPjWdS6I00yypqEGcHXegd6kOkM=";
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
