{
  source,
  lib,
  buildGoModule
}:
buildGoModule {
  inherit (source) pname version src;
  vendorHash = "sha256-QtZrpqzDoMEydrLV7NIArA8tziogUd+JoIerKMvCHto=";
  doCheck = true;

  CGO_ENABLED = 0;

  tags = [ "kqueue" ];
  
  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Key Managament Server [not just] for Object Storage";
    homepage = "https://github.com/minio/kes";
    license = licenses.agpl3;
  };
}
