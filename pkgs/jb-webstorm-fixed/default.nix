{
  lib,
  jetbrains,
  jb-jdk-fixed
}:
jetbrains.webstorm.override {
  jdk = jb-jdk-fixed;
  vmopts = "-Dawt.useSystemAAFontSettings=lcd";
}
