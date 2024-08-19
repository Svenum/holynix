{ ... }:

final: prev: {
  linuxPackages_latest = prev.linuxPackages_latest.extend (kfinal: kprev: {
    kvmfr = prev.linuxPackages_latest.kvmfr.overrideAttrs (old: {
      patches = [
        (prev.fetchpatch {
          url = "https://github.com/gnif/LookingGlass/commit/7305ce36af211220419eeab302ff28793d515df2.patch";
          hash = "sha256-97nZsIH+jKCvSIPf1XPf3i8Wbr24almFZzMOhjhLOYk=";
          stripLen = 1;
        })
      ];
    });
  });

  looking-glass-client = prev.looking-glass-client.overrideAttrs (old: {
    patches = [
      (prev.fetchpatch {
        url = "https://github.com/gnif/LookingGlass/commit/20972cfd9b940fddf9e7f3d2887a271d16398979.patch";
        hash = "sha256-CqB8AmOZ4YxnEsQkyu/ZEaun6ywpSh4B7PM+MFJF0qU=";
        stripLen = 1;
      })
    ];
  });
}
