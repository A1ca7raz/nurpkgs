{
  tela-icon-theme,
  fetchFromGitHub,
  nix-update-script,
}:
tela-icon-theme.overrideAttrs (p: {
  # <latest upstream tag>-unstable-<commit date>; nix-update's
  # --version=branch keeps both parts current.
  version = "2026-07-07-unstable-2026-08-10";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "tela-icon-theme";
    rev = "a1fffc5bfab716bd022dd228ee96fe3965cdb33d";
    hash = "sha256-e4Ysu9YE2jAib9+q9eYL0E3w1BBXbu/QYNTmSjk0CRY=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" "--version=branch" ];
  };
})
