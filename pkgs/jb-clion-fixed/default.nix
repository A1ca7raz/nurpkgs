{
  lib,
  jetbrains,
  jb-jdk-fixed
}:
jetbrains.clion.override {
  jdk = jb-jdk-fixed;
  vmopts = "-Dawt.useSystemAAFontSettings=lcd";
}