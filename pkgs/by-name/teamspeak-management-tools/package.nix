{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "teamspeak-management-tools";
  version = "6.2.2";

  src = fetchFromGitHub {
    owner = "KunoiSayami";
    repo = "teamspeak-management-tools.rs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BL4xfeXsJjtK8skcB0Td4dW4dWSpNwWj3hJxEmRytMs=";
  };

  cargoHash = "sha256-oue/6jxZM4mP1lG6uqdWxYC04OY6DMzVBeOQsYUPPi4=";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    maintainers = with lib.maintainers; [ A1ca7raz ];
    description = "A teamspeak tools that help you manage your server.";
    homepage = "https://github.com/KunoiSayami/teamspeak-management-tools.rs";
    license = lib.licenses.agpl3Only;
  };
})
