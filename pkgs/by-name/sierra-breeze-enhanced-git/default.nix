{
  kdePackages,
  source
}:
kdePackages.sierra-breeze-enhanced.overrideAttrs (p: {
  inherit (source) src version;

  cmakeFlags = p.cmakeFlags ++ [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];
})
