{ ... }:

final: prev: {
  linuxPackages_latest = prev.linuxPackages_latest.extend (lfinal: lprev: {
    kvmfr = prev.linuxPackages_latest.kvmfr.overrideAttrs (old: {
      patches = [
        (prev.fetchpatch {
          url = "https://github.com/gnif/LookingGlass/commit/4251a5c5fe7723c5dc068839debd76a5148953b2.patch";
          hash = "sha256-xRg92WttsROFT8ZxUp9JeGPEZOhdZfznFBkAL8EQr+k=";
          stripLen = 1;
        })
      ];
    });
  });

  looking-glass-client = prev.looking-glass-client.overrideAttrs (old: {
    version = "master";
    src = prev.fetchFromGitHub {
      owner = "gnif";
      repo = "LookingGlass";
      hash = "sha256-DBmCJRlB7KzbWXZqKA0X4VTpe+DhhYG5uoxsblPXVzg=";
      rev = "e25492a3a36f7e1fde6e3c3014620525a712a64a";
      fetchSubmodules = true;
    };
    patches = [ ./nanosvg-unvendor.diff ];
  });
}
