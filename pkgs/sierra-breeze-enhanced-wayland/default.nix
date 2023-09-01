{
  sierra-breeze-enhanced,
  fetchpatch
}:
sierra-breeze-enhanced.overrideAttrs (p: {
  patches = [
    (fetchpatch {
      url = "https://github.com/kupiqu/SierraBreezeEnhanced/compare/master...A1ca7raz:SierraBreezeEnhanced:3baa96c638dfdf44d3cf2d40fec9fabfc6031ed2.patch";
      hash = "sha256-5eNUD5ayzB0ZNQRT786KN97F+Ct1icUq+tBMScelT+0=";
    })
  ];
})
