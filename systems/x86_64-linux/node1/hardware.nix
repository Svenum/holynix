{ ... }:

{
  # Filesystems
  fileSystems."/" = {
    label = "NixOS";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    label = "Boot";
    fsType = "vfat";
  };
}
