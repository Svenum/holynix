{
  kernel,
  fetchpatch,
}:

let
  module = "sound/usb";
in
kernel.stdenv.mkDerivation {
  pname = baseNameOf module;
  inherit (kernel) version src;

  patches = [
    (fetchpatch {
      url = "https://github.com/torvalds/linux/commit/435ed8045aa6fb8d7dbef16b618d5341d88aa6e3.patch";
      hash = "sha256-T1eMOoVHXFt9uS7QYR116NfIi7ev64PVC2qrdLvWts8=";
    })
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  enableParallelBuilding = true;

  buildPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd)/${module} \
      modules
  '';

  installPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd)/${module} \
      INSTALL_MOD_PATH=$out \
      INSTALL_MOD_DIR=kernel/${module} \
      modules_install
  '';
}
