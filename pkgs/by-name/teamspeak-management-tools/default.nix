{
  source,
  lib,
  rustPlatform
}:
rustPlatform.buildRustPackage (final: {
  inherit (source) pname version src;

  cargoHash = "sha256-oue/6jxZM4mP1lG6uqdWxYC04OY6DMzVBeOQsYUPPi4=";

  meta = {
    maintainers = with lib.maintainers; [ A1ca7raz ];
    description = "A teamspeak tools that help you manage your server.";
    homepage = "https://github.com/KunoiSayami/teamspeak-management-tools.rs";
    license = lib.licenses.agpl3Only;
  };
})
