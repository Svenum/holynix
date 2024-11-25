{ ... }:

final: prev: {
  kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
    kdeconnect-kde = kprev.kdeconnect-kde.overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or []) ++ ["-DBLUETOOTH_ENABLED=ON"];
    });
  });
}
