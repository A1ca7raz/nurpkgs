final: prev:
let
  inherit (final) resolveBuildSystem;
  inherit (builtins)
    foldl'
    mapAttrs
  ;

  overrideSetuptools = foldl' (acc: p: acc // { "${p}".setuptools = []; }) {};

  # Build system dependencies specified in the shape expected by resolveBuildSystem
  # The empty lists below are lists of optional dependencies.
  #
  # A package `foo` with specification written as:
  # `setuptools-scm[toml]` in pyproject.toml would be written as
  # `foo.setuptools-scm = [ "toml" ]` in Nix
  buildSystemOverrides = overrideSetuptools [
    "anitopy"
    "aliyun-python-sdk-core"
    "crcmod"
    "func-timeout"
    "http-ece"
    "iso639"
    "jieba"
    "oss2"
    "paho-mqtt"
    "pinyin2hanzi"
    "pytelegrambotapi"
    "regex"
    "srt"
    "zhconv"
  ];
in
mapAttrs (
  name: spec:
  prev.${name}.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ resolveBuildSystem spec;
  })
) buildSystemOverrides
