_:

_final: prev: {
  kdePackages = prev.kdePackages.overrideScope (_kfinal: kprev: {
    extra-cmake-modules = kprev.extra-cmake-modules.overrideAttrs (_old: rec {
      version = "6.16.0-rc1";
      src = prev.fetchFromGitLab {
        domain = "invent.kde.org";
        owner = "frameworks";
        repo = "extra-cmake-modules";
        tag = "v${version}";
        hash = "sha256-pXiTJ+YRz+Q2B55w0BQyEpPixNsyJMyxy3jICrJR0NM=";
      };
      patches = [ ];
    });
    kconfig = kprev.kconfig.overrideAttrs (_old: rec {
      version = "6.16.0-rc1";
      src = prev.fetchFromGitLab {
        domain = "invent.kde.org";
        owner = "frameworks";
        repo = "kconfig";
        tag = "v${version}";
        hash = "sha256-XSeaXP86y8yX3nSHiRe5l8Ai/R1sMG2bC8uUKHbGCnw=";
      };
    });
  });
}
