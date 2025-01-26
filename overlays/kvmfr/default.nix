{ ... }:

final: prev: {
  linuxPackages = prev.linuxPackages_6_13.extend (lfinal: lprev: {
    kvmfr = prev.linuxPackages_6_13.kvmfr.overrideAttrs (old: {
      patches = ( old.patches or [] ) ++ [
        (prev.fetchpatch {
          url = "https://github.com/gnif/LookingGlass/commit/7740692e3000c2019e21b9861585960174dd5ddc.patch";
          hash = "05h2z3xh3qmhaifhanl59ns3xk5di1ark9ibbkmhnj6416hs7lwa";
        })

        (prev.fetchpatch {
          url = "https://github.com/gnif/LookingGlass/commit/cf985536a6f80fe985e3eac3fd0396da12f41ad3.patch";
          hash = "0cbil1ak9qpg3rs65a6azxz6dffhgq4yqrmnldfgada0rsaac2j3";
        })
      ];
    });
  });
}
