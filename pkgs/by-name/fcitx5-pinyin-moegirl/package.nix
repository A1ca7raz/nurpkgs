{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fcitx5-pinyin-moegirl";
  version = "20260911";

  src = fetchurl {
    url = "https://github.com/outloudvi/mw2fcitx/releases/download/${finalAttrs.version}/moegirl.dict";
    hash = "sha256-FZGi1+t6RLQ7B068IFLsSkkvyyfrYy8hXBmP7MuYFtA=";
  };

  dontUnpack = true;
  installPhase = ''
    install -Dm644 $src $out/share/fcitx5/pinyin/dictionaries/moegirl.dict
  '';

  # nix-update-args holds extra args, one or more whitespace-separated
  # args per line; lines starting with # are comments.
  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ] ++ lib.concatMap
      (l: lib.filter (s: s != "") (lib.splitString " " l))
      (lib.filter (s: s != "" && !(lib.hasPrefix "#" s))
        (map lib.trim (lib.splitString "\n" (builtins.readFile ./nix-update-args))));
  };

  meta = with lib; {
    description = "Fcitx 5 Pinyin Dictionary from moegirl.org wiki";
    homepage = "https://github.com/outloudvi/mw2fcitx";
    license = licenses.unlicense;
  };
})
