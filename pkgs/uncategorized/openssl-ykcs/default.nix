{
  openssl,
  yubico-piv-tool,
  libp11,
  writeText
}:
openssl.override {
  conf = writeText "openssl.cnf" ''
    openssl_conf = openssl_init

    [openssl_init]
    engines = engine_section
    ssl_conf = ssl_module

    [engine_section]
    pkcs11 = pkcs11_section

    [pkcs11_section]
    engine_id = pkcs11
    dynamic_path = ${libp11}/lib/engines/libpkcs11.so
    MODULE_PATH = ${yubico-piv-tool}/lib/libykcs11.so
    init = 0
  '';
}
