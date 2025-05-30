# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  aosc-scriptlets = {
    pname = "aosc-scriptlets";
    version = "ec2a6ce198b38ebe065c500a959c24acad8ba263";
    src = fetchgit {
      url = "https://github.com/AOSC-Dev/scriptlets";
      rev = "ec2a6ce198b38ebe065c500a959c24acad8ba263";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-aaMLEwKfveaPvrLgZFeMQSdOVNTdEjXy2Z6CoI9rKck=";
    };
    date = "2025-05-28";
  };
  fcitx5-pinyin-moegirl = {
    pname = "fcitx5-pinyin-moegirl";
    version = "20250509";
    src = fetchurl {
      url = "https://github.com/outloudvi/mw2fcitx/releases/download/20250509/moegirl.dict";
      sha256 = "sha256-M0oquFoR44IRY3dvTjpZ48tRTi+OP+GqMfb5sdUcurY=";
    };
  };
  fcitx5-pinyin-zhwiki = {
    pname = "fcitx5-pinyin-zhwiki";
    version = "20250526";
    src = fetchurl {
      url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.5/zhwiki-20250526.dict";
      sha256 = "sha256-znHic2/mP0HWJgO1v7sqF2W4Xv2ZhhC8xufaUu87ZzE=";
    };
  };
  moviepilot-core = {
    pname = "moviepilot-core";
    version = "v2.5.1";
    src = fetchFromGitHub {
      owner = "jxxghp";
      repo = "MoviePilot";
      rev = "v2.5.1";
      fetchSubmodules = false;
      sha256 = "sha256-rrfYXDzTpA8vUvy/y+e9Ff2LBbJrc5OSuGcibjFxi+E=";
    };
  };
  moviepilot-frontend = {
    pname = "moviepilot-frontend";
    version = "v2.5.1";
    src = fetchFromGitHub {
      owner = "jxxghp";
      repo = "MoviePilot-Frontend";
      rev = "v2.5.1";
      fetchSubmodules = false;
      sha256 = "sha256-k0yXRva3b0/EO1KVFm5e4fkQZdfOkhqGe0fWmhgoMag=";
    };
  };
  moviepilot-plugins = {
    pname = "moviepilot-plugins";
    version = "637cf9e83a20d714e9caac2268690dfe7e570eff";
    src = fetchFromGitHub {
      owner = "jxxghp";
      repo = "MoviePilot-Plugins";
      rev = "637cf9e83a20d714e9caac2268690dfe7e570eff";
      fetchSubmodules = false;
      sha256 = "sha256-BB3pPv7eHIW4R8iYDITBNyARWxCxhSAgrulUXgD31Ck=";
    };
    date = "2025-05-28";
  };
  moviepilot-resources = {
    pname = "moviepilot-resources";
    version = "d2fba4700c90e0b667ebaaef381e86aa95d2d058";
    src = fetchFromGitHub {
      owner = "jxxghp";
      repo = "MoviePilot-Resources";
      rev = "d2fba4700c90e0b667ebaaef381e86aa95d2d058";
      fetchSubmodules = false;
      sha256 = "sha256-7yXUCYxGR7Jgf4D6IhSvOiUfyC7glZQyEcicitpNf7A=";
    };
    date = "2025-05-26";
  };
  sierra-breeze-enhanced-git = {
    pname = "sierra-breeze-enhanced-git";
    version = "V.2.1.0";
    src = fetchFromGitHub {
      owner = "kupiqu";
      repo = "SierraBreezeEnhanced";
      rev = "V.2.1.0";
      fetchSubmodules = false;
      sha256 = "sha256-Dzsl06FdCRGuBv2K5BmowCdaWQpYhe/U7aeQ0Q1T5Z4=";
    };
  };
  sillytavern-nightly = {
    pname = "sillytavern-nightly";
    version = "87df4db1a4217bf51e1c9bc31b21938c29bee71f";
    src = fetchFromGitHub {
      owner = "SillyTavern";
      repo = "SillyTavern";
      rev = "87df4db1a4217bf51e1c9bc31b21938c29bee71f";
      fetchSubmodules = false;
      sha256 = "sha256-199dAb1SMjZZ8fcEnwBy0IXpRyGJ4vrVEDKhFUO1xrA=";
    };
    date = "2025-05-29";
  };
}
