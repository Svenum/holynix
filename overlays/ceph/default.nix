# https://github.com/NixOS/nixpkgs/pull/542348
_: final: prev: {
  ceph = builtins.getAttr "ceph" (
    prev.ceph.overrideScope (
      _: scopePrev: {
        arrow-cpp = null;

        ceph-python-common = scopePrev.ceph-python-common.overrideAttrs (old: {
          dontCheckPythonMetadata = true;
        });

        ceph = scopePrev.ceph.overrideAttrs (
          {
            cmakeFlags ? [ ],
            ...
          }:
          {
            cmakeFlags = cmakeFlags ++ [
              (final.lib.cmakeBool "WITH_RADOSGW_SELECT_PARQUET" false)
              (final.lib.cmakeBool "WITH_RADOSGW_ARROW_FLIGHT" false)
            ];
          }
        );
      }
    )
  );
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      cython_0 = pyprev.cython_0.overrideAttrs (old: {
        dontCheckPythonMetadata = true;
      });
    })
    (
      _: pythonPrev:
      prev.lib.optionalAttrs pythonPrev.python.isPy312 {
        scipy = pythonPrev.scipy.overrideAttrs (old: {
          disabledTests = old.disabledTests ++ [ "test_support_moments_sample" ];
        });
      }
    )
  ];
}
