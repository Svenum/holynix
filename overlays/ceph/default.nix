# https://github.com/NixOS/nixpkgs/pull/542348
# horrible formatting is optional, the code will also work if you make it look okay
final: prev: {
  ceph =
    (prev.ceph.overrideScope (
      _: prev: {
        # not sure if needed or effective
        arrow-cpp = null;
        ceph = prev.ceph.overrideAttrs (
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
    )).ceph;
}
