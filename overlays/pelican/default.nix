_:

_final: prev: {
  pelican-panel = prev.pelican-panel.overrideAttrs (_old: {
    patches = prev.lib.mkForce [ ];
  });
}
