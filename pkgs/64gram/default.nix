{
  source,
  telegram-desktop
}:
telegram-desktop.overrideAttrs (final: prev: {
  inherit (source) pname version src;
  cmakeFlags = [
    "-Ddisable_autoupdate=ON"
    # We're allowed to used the API ID of the Snap package:
    "-DTDESKTOP_API_ID=611335"
    "-DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c"
    # See: https://github.com/NixOS/nixpkgs/pull/130827#issuecomment-885212649
    "-DDESKTOP_APP_USE_PACKAGED_FONTS=OFF"
#     "-DTDESKTOP_API_TEST=ON"
#     "-DDESKTOP_APP_DISABLE_CRASH_REPORTS=OFF"
  ];
})
