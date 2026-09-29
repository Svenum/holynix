_:

_final: prev: {
  stirling-pdf = prev.stirling-pdf.overrideAttrs (old: {
    patches = old.patches ++ [
      (prev.fetchpatch {
        url = "https://raw.githubusercontent.com/TomaSajt/nixpkgs/1cbbcddcf76c61e329ae85ccf20ee0c9bcfbac5a/pkgs/by-name/st/stirling-pdf/skip-tests-with-expired-certs.patch";
        hash = "sha256-1vUrGHw71pdpin7tHNwhah22/hjEXv0OFN0kS3Uwhxs=";
      })
    ];
  });
}
