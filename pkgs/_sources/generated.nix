# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  aosc-scriptlets = {
    pname = "aosc-scriptlets";
    version = "bc6bb85fec30806fe4dc84af4c89d057af50bb3f";
    src = fetchgit {
      url = "https://github.com/AOSC-Dev/scriptlets";
      rev = "bc6bb85fec30806fe4dc84af4c89d057af50bb3f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-06437YjLco2ytoGJGAaUU53Ulp6fTodytF+SET1xSLQ=";
    };
    date = "2025-03-02";
  };
  fcitx5-pinyin-moegirl = {
    pname = "fcitx5-pinyin-moegirl";
    version = "20250209";
    src = fetchurl {
      url = "https://github.com/outloudvi/mw2fcitx/releases/download/20250209/moegirl.dict";
      sha256 = "sha256-+EIXBIu3OE59VpnAWalmiNqD4FsvuSgRr79OQCqrgMA=";
    };
  };
  fcitx5-pinyin-zhwiki = {
    pname = "fcitx5-pinyin-zhwiki";
    version = "20241218";
    src = fetchurl {
      url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.5/zhwiki-20241218.dict";
      sha256 = "sha256-9Z+dgicQQdsySn1/xn6w4Q4hOqMv7Rngol615/JxtRk=";
    };
  };
}
