_:

_final: prev: {
  kdePackages = prev.kdePackages.overrideScope (_kfinal: kprev: {
    kdeconnect-kde = kprev.kdeconnect-kde.overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DBLUETOOTH_ENABLED=ON" ];
    });
    plasma-workspace = kprev.plasma-workspace.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (prev.fetchpatch {
          url = "https://invent.kde.org/plasma/plasma-workspace/-/commit/30273fb2afcc6e304951c8895bb17d38255fed39.patch";
          hash = "sha256-1p1CjxRioCDm5ugoI8l6kDlOse5FbDJ71tTAY9LPvRc=";
        })
      ];
    });
  });
}
