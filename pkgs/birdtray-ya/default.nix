{
  fetchFromGitHub,
  birdtray
}:
birdtray.overrideAttrs (p: rec {
  version = "1.11.2";

  src = fetchFromGitHub {
    owner = "gyunaev";
    repo = p.pname;
    rev = "v${version}";
    sha256 = "sha256-LjFWCVbVzyX5340PF7f8aBc3EoBn1xMBkZYQZqBXlLA=";
  };
})
