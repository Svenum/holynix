{ ... }:

final: prev: {
  linuxPackages = prev.linuxPackages.extend (lfinal: lprev: {
    kvmfr = prev.linuxPackages.kvmfr.overrideAttrs (old: {
      patches = [
        #(prev.fetchpatch {
        #  url = "https://github.com/gnif/LookingGlass/commit/cf985536a6f80fe985e3eac3fd0396da12f41ad3.patch";
        #  hash = "sha256-4vlUkIg8Na70WzyaZATELFEVMbATh6RTBziwontzybE=";
        #  stripLen = 1;
        #})
        (prev.fetchpatch {
          url = "https://github.com/gnif/LookingGlass/commit/7740692e3000c2019e21b9861585960174dd5ddc.patch";
          hash = "sha256-QRg92WttsROFT8ZxUp9JeGPEZOhdZfznFBkAL8EQr+k=";
          stripLen = 1;
        })
      ];
    });
  });

  looking-glass-client = prev.looking-glass-client.overrideAttrs (old: {
    version = "unstable";
    src = prev.fetchFromGitHub {
      owner = "gnif";
      repo = "LookingGlass";
      hash = "sha256-efAO7KLdm7G4myUv6cS1gUSI85LtTwmIm+HGZ52arj8=";
      rev = "master";
    };
  });
}
