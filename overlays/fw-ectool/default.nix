_:

_final: prev: {
  fw-ectool = prev.fw-ectool.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
}
