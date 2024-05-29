{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "phantun";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "dndx";
    repo = "phantun";
    rev = "v${version}";
    hash = "sha256-HjYdUB4vtulonWbFasMAkSJk5/atsRW59B5IDHOivoQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  postInstall = ''
    mv $out/bin/client $out/bin/phantun-client
    mv $out/bin/server $out/bin/phantun-server
  '';

  meta = with lib; {
    description = "Transforms UDP stream into (fake) TCP streams that can go through Layer 3 & Layer 4 (NAPT) firewalls/NATs";
    homepage = "https://github.com/dndx/phantun";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ A1ca7raz ];
    mainProgram = "phantun";
  };
}
