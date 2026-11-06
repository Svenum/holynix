# Workaround until: https://nixpkgs-tracker.ocfox.me/?pr=583626
_:

_final: prev: {
  openssh = prev.openssh.overrideAttrs (_old: {
    version = "10.6p2";
    src = prev.fetchurl {
      url = "mirror://openbsd/OpenSSH/portable/openssh-10.6p2.tar.gz";
      hash = "sha256-muRIcgkM8vBrPPn/FH5/FvMJZxNAdj7S+ZJIOYrinVs=";
    };
  });
}
