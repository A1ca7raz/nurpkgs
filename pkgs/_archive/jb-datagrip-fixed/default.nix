{
  lib,
  jetbrains,
  jb-jdk-fixed
}:
jetbrains.datagrip.override {
  jdk = jb-jdk-fixed;
  vmopts = "-Dawt.useSystemAAFontSettings=lcd";
}