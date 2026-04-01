{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.boot) kernelPackages;
  module = "sound/usb";
  snd-usb-audio = kernelPackages.stdenv.mkDerivation {
    pname = baseNameOf module;
    inherit (kernelPackages.kernel) version src;

    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/torvalds/linux/commit/435ed8045aa6fb8d7dbef16b618d5341d88aa6e3.patch";
        hash = "sha256-T1eMOoVHXFt9uS7QYR116NfIi7ev64PVC2qrdLvWts8=";
      })
    ];

    nativeBuildInputs = kernelPackages.kernel.moduleBuildDependencies;

    enableParallelBuilding = true;

    makeFlags = kernelPackages.kernelModuleMakeFlags ++ [
      "INSTALL_MOD_PATH=$(out)"
      "INSTALL_MOD_DIR=kernel/${module}"
      "M=$(PWD)/${module}"
    ];

    buildFlags = [ "modules" ];

    installFlags = [ "modules_install" ];
  };
in
{
  boot.extraModulePackages = [
    (lib.hiPrio snd-usb-audio)
  ];
}
