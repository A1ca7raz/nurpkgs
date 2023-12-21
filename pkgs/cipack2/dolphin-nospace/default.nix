{
  lib,
  dolphin,
}:
dolphin.overrideAttrs (p: {
  patches = [ ./00-dolphin-return-space.patch ];
})