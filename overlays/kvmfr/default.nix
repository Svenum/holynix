{ channels, ...}:

final: prev: {
  inherit (channels.nixpkgs) kvmfr;
  holynix = (prev.holynix or {}) // {
    kvmfr = prev.kvmfr.overrideAttrs (old: {
      patches = [];
    }); 
  };
}
