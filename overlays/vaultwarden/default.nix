{ lib, ... }:
final: prev: {
  vaultwarden = prev.vaultwarden.overrideAttrs (old: rec {
    version = "1.37.1";
    src = prev.fetchFromGitHub {
      owner = "dani-garcia";
      repo = "vaultwarden";
      tag = version;
      hash = "sha256-QS9dUOlId4LT6rNgLwVxShX3xpnykpbiFsc0x88Bojc=";
    };
    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "vaultwarden-${version}";
      hash = "sha256-sza4ZQz2+QJJJ03Upt6sGXAv+1VPImN2qZHXaTSALFQ=";
    };
  });
}
