{
  pkgs,
  config,
  ...
}:

let
  inherit (config.boot.kernelPackages) kernel;
  usb-kernel-module = pkgs.stdenv.mkDerivation {
    pname = "usb-kernel-module";
    inherit (kernel)
      src
      version
      postPatch
      nativeBuildInputs
      ;

    kernel_dev = kernel.dev;
    kernelVersion = kernel.modDirVersion;

    modulePath = "sound/usb";

    buildPhase = ''
      BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

      cp $BUILT_KERNEL/Module.symvers .
      cp $BUILT_KERNEL/.config        .
      cp $kernel_dev/vmlinux          .

      make "-j$NIX_BUILD_CORES" modules_prepare
      make "-j$NIX_BUILD_CORES" M=$modulePath modules
    '';

    installPhase = ''
      make \
        INSTALL_MOD_PATH="$out" \
        XZ="xz -T$NIX_BUILD_CORES" \
        M="$modulePath" \
        modules_install
    '';
  };
in
{
  boot.extraModulePackages = [
    (usb-kernel-module.overrideAttrs (_: {
      patches = [
        (pkgs.fetchpatch {
          url = "https://github.com/torvalds/linux/commit/435ed8045aa6fb8d7dbef16b618d5341d88aa6e3.patch";
          hash = "sha256-T1eMOoVHXFt9uS7QYR116NfIi7ev64PVC2qrdLvWts8=";
        })
      ];
    }))
  ];
}
