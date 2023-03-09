{
  lib,
  jetbrains,
  jb-jdk-fixed
}:
jetbrains.idea-ultimate.override {
  jdk = jb-jdk-fixed;
  vmopts = "-Dawt.useSystemAAFontSettings=lcd";
}