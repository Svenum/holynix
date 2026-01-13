{
  pkgs,
  lib,
  dgpuPCI ? [ ],
}:

pkgs.writeShellScriptBin "toggle-amd-gpu" ''
  if [[ $(id -u) -ne 0 ]]; then
    sudo $0 $@
    exit 0
  fi

  DEVICES="${lib.strings.concatMapStrings (x: " " + x) dgpuPCI}"
  for DEVICE in $DEVICES; do
    MODULE=$(${pkgs.pciutils}/bin/lspci -d $DEVICE -k | grep "Kernel modules:" | ${pkgs.busybox}/bin/awk '{print $NF}')
    if [[ $MODULE == "amdgpu" ]]; then
      DGPU=$(${pkgs.pciutils}/bin/lspci -d $DEVICE -kD | ${pkgs.busybox}/bin/cut -d "." -f 1 | ${pkgs.busybox}/bin/head -n1)
      break
    fi
  done
  GPU=''${DGPU}.0
  AUDIO=''${DGPU}.1
  GPU_VD="$(cat /sys/bus/pci/devices/''${GPU}/vendor) $(cat /sys/bus/pci/devices/''${GPU}/device)"
  AUDIO_VD="$(cat /sys/bus/pci/devices/''${AUDIO}/vendor) $(cat /sys/bus/pci/devices/''${AUDIO}/device)"

  function List {
      lspci -nnk | rg -A 3 ''${DGPU#*:}
  }

  function Switch {

    # amdgpu gets corrupted if you just remove it
    # removing and rescanning the device seems
    # to get around the problem
    echo "removing and re-attaching dgpu"
    echo 1 > /sys/bus/pci/devices/''${GPU}/remove
    echo 1 > /sys/bus/pci/devices/''${AUDIO}/remove
    echo 1 > /sys/bus/pci/rescan

    echo "updating gpu driver"
    echo ''${GPU} > /sys/bus/pci/devices/''${GPU}/driver/unbind
    echo ''${AUDIO} > /sys/bus/pci/devices/''${AUDIO}/driver/unbind
      
    echo ''${_gpu_driver} > /sys/bus/pci/devices/''${GPU}/driver_override
    echo ''${_audio_driver} > /sys/bus/pci/devices/''${AUDIO}/driver_override

    echo ''${GPU} > /sys/bus/pci/drivers_probe
    echo ''${AUDIO} > /sys/bus/pci/drivers_probe

    echo "''${_gpu_driver} now in use"

  }

  case $1 in
  amd)
    _gpu_driver=amdgpu _audio_driver=snd_hda_intel Switch
    ;;
  vfio)
    _gpu_driver=vfio-pci _audio_driver=vfio-pci Switch
    ;;
  *)
    echo "$1 == (amd || vfio)"
    ;;
  esac

''
