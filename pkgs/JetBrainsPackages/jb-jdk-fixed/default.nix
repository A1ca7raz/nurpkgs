{
  jetbrains,
  fetchpatch
}:
jetbrains.jdk.overrideAttrs (p: {
  patches = p.patches ++ [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/RikudouPatrickstar/JetBrainsRuntime-for-Linux-x64/master/idea.patch";
      hash = "sha256-IycRpChsnZVMUAEFYMxfoVRQX+ue8Bcac+kURN/rBiw=";
    })
  ];
})