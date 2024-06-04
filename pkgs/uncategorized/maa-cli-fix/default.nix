{
  lib,
  maa-cli,
  maa-assistant-arknights
}:
maa-cli.override({
  maa-assistant-arknights = maa-assistant-arknights.overrideAttrs(p: {
    cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "INSTALL_FLATTEN" false)
    (lib.cmakeBool "INSTALL_PYTHON" true)
    (lib.cmakeBool "INSTALL_RESOURCE" true)
    (lib.cmakeBool "USE_MAADEPS" false)
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "None")
    (lib.cmakeFeature "MAA_VERSION" "v${p.version}")
    ];
  });
})
