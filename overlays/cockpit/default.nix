{ ... }:

final: prev: {
  cockpit = prev.cockpit.overrideAttrs (old:{
    # Remove packagekit from cockpit so that it does not look for updates
    fixupPhase = builtins.replaceStrings [ "runHook postFixup" ] [ "rm -rf $out/share/cockpit/packagekit\nrunHook postFixup" ] old.fixupPhase;
  });
}
