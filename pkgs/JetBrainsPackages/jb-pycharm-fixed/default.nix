{
  jetbrains,
  jb-jdk-fixed
}:
jetbrains.pycharm-professional.override {
  jdk = jb-jdk-fixed;
  vmopts = "-Dawt.useSystemAAFontSettings=lcd";
}