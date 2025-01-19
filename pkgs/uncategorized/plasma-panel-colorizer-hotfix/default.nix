{
  plasma-panel-colorizer,
  fetchFromGitHub
}:
plasma-panel-colorizer.overrideAttrs (p: {
  version = "1.2.0-unstable_20250108";
  # https://github.com/luisbocanegra/plasma-panel-colorizer/commit/fc94f22eb63791e131a3a023eef4cf0aa8c17fed
  src = fetchFromGitHub {
    owner = "luisbocanegra";
    repo = "plasma-panel-colorizer";
    rev = "fc94f22eb63791e131a3a023eef4cf0aa8c17fed";
    hash = "sha256-5tzhOUH81sCvHuSwKOlaZtVm9gO5VKkZy5ifEKgZjqE=";
  };
})
