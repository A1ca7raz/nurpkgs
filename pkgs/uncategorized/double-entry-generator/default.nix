{
  source,
  lib,
  buildGoModule
}:
buildGoModule {
  inherit (source) pname version src;
  vendorHash = "sha256-Xedva9oGteOnv3rP4Wo3sOHIPyuy2TYwkZV2BAuxY4M=";

  meta = with lib; {
    description = "Rule-based double-entry bookkeeping importer (from Alipay/WeChat/Huobi etc. to Beancount/Ledger).";
    homepage = "https://github.com/deb-sig/double-entry-generator";
    license = licenses.asl20;
  };
}
