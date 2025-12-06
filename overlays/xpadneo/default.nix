_:
let
  src = {
    owner = "atar-axis";
    repo = "xpadneo";
    rev = "a16acb03e7be191d47ebfbc8ca1d5223422dac3e";
    hash = "sha256-4eOP6qAkD7jGOqaZPOB5/pdoqixl2Jy2iSVvK2caE80=";
  };

  patch = {
    url = "https://github.com/orderedstereographic/xpadneo/commit/233e1768fff838b70b9e942c4a5eee60e57c54d4.patch";
    hash = "sha256-HL+SdL9kv3gBOdtsSyh49fwYgMCTyNkrFrT+Ig0ns7E=";
    stripLen = 2;
  };
in
_final: prev: {
  linuxPackages_6_18 = prev.linuxPackages_6_18.extend (_lfinal: lprev: {
    xpadneo = lprev.xpadneo.overrideAttrs (old: {
      src = prev.fetchFromGitHub src;
      patches = (old.patches or [ ]) ++ [
        (prev.fetchpatch patch)
      ];
    });
  });
  linuxPackages_latest = prev.linuxPackages_latest.extend (_lfinal: lprev: {
    xpadneo = lprev.xpadneo.overrideAttrs (old: {
      src = prev.fetchFromGitHub src;
      patches = (old.patches or [ ]) ++ [
        (prev.fetchpatch patch)
      ];
    });
  });
}
