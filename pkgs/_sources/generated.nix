# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  aosc-scriptlets = {
    pname = "aosc-scriptlets";
    version = "35d9d949fb04bc62597c49821a52d1a3d908e7d5";
    src = fetchgit {
      url = "https://github.com/AOSC-Dev/scriptlets";
      rev = "35d9d949fb04bc62597c49821a52d1a3d908e7d5";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-+fcqNxgsiAs/YytBdGlwfDTOm4n+pXh0GTjP6doyRV0=";
    };
    date = "2024-10-08";
  };
  applet-panel-colorizer = {
    pname = "applet-panel-colorizer";
    version = "c25c6c422ecc3b8599f1247df1333bb504f43c09";
    src = fetchgit {
      url = "https://github.com/luisbocanegra/plasma-panel-colorizer";
      rev = "c25c6c422ecc3b8599f1247df1333bb504f43c09";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-2GBGxN0nkvHftnGXrSuwCnnRBkzKQTx6fFGQ05Rrit8=";
    };
    date = "2024-10-06";
  };
  baidupcs-go = {
    pname = "baidupcs-go";
    version = "5612fc337b9556ed330274987a2f876961639cff";
    src = fetchgit {
      url = "https://github.com/qjfoidnh/BaiduPCS-Go";
      rev = "5612fc337b9556ed330274987a2f876961639cff";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-4mCJ5gVHjjvR6HNo47NTJvQEu7cdZZMfO8qQA7Kqzqo=";
    };
    date = "2024-06-23";
  };
  clash-webui-yacd-meta = {
    pname = "clash-webui-yacd-meta";
    version = "8753c22b66388f07b64d72c60e5c479b63d15c5a";
    src = fetchurl {
      url = "https://github.com/MetaCubeX/Yacd-meta/archive/8753c22b66388f07b64d72c60e5c479b63d15c5a.zip";
      sha256 = "sha256-3Mvl6KNXNxEWfAnznsWonEUSS5Okq0ChXhECsBAqcUU=";
    };
    date = "2024-08-11";
  };
  double-entry-generator = {
    pname = "double-entry-generator";
    version = "v2.7.1";
    src = fetchFromGitHub {
      owner = "deb-sig";
      repo = "double-entry-generator";
      rev = "v2.7.1";
      fetchSubmodules = false;
      sha256 = "sha256-2Y8Spj1LAVZsUgChDYDCZ63pTH+nqs2ff9xcmC+gr0c=";
    };
  };
  fcitx5-pinyin-moegirl = {
    pname = "fcitx5-pinyin-moegirl";
    version = "20240909";
    src = fetchurl {
      url = "https://github.com/outloudvi/mw2fcitx/releases/download/20240909/moegirl.dict";
      sha256 = "sha256-+e4azEWHYSh3Gy9Xa+Y8E7f7rAA8YlWlbvbva9kNXCI=";
    };
  };
  fcitx5-pinyin-zhwiki = {
    pname = "fcitx5-pinyin-zhwiki";
    version = "20240909";
    src = fetchurl {
      url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.5/zhwiki-20240909.dict";
      sha256 = "sha256-djXrwl1MmiAf0U5Xvm4S7Fk2fKNRm5jtc94KUYIrcm8=";
    };
  };
  plasma-panel-spacer-extended = {
    pname = "plasma-panel-spacer-extended";
    version = "v1.9.0";
    src = fetchFromGitHub {
      owner = "luisbocanegra";
      repo = "plasma-panel-spacer-extended";
      rev = "v1.9.0";
      fetchSubmodules = false;
      sha256 = "sha256-3ediynClboG6/dBQTih6jJPGjsTBZhZKOPQAjGLRNmk=";
    };
  };
}
