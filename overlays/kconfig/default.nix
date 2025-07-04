_:

_final: prev: {
  kdePackages = prev.kdePackages.overrideScope (_kfinal: kprev: {
    kconfig = kprev.kconfig.overrideAttrs (_old: {
      patches = [
        (prev.fetchpatch {
          url = "https://invent.kde.org/frameworks/kconfig/-/commit/da889c31e088902723f089673f3be0a70b4560a5.diff";
          hash = "sha256-sui1A9I9NIP9APcJw0TkxtC81gubhSshEgRi+m+Wgng=
";
        })
      ];
    });
  });
}
