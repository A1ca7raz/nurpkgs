{
  source,
  lib,
  rustPlatform
}:
rustPlatform.buildRustPackage (final: {
  inherit (source) pname version src;

  cargoHash = "sha256-3W8+gTAEuXVFQw9sFfdJKoliUue+YIsrSyIqflv5rZ0=";

  meta = {
    maintainers = with lib.maintainers; [ A1ca7raz ];
    description = "A teamspeak tools that help you manage your server.";
    homepage = "https://github.com/KunoiSayami/teamspeak-management-tools.rs";
    license = lib.licenses.agpl3Only;
  };
})
