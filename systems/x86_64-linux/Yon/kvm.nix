{ pkgs, nixVirt, ... }:

let
  nixvirt.lib = nixVirt.lib;
  toggle_gpu = pkgs.writeShellScriptBin "toggle_gpu" ''
    if [[ $1 == "Windows GPU Nix" ]]; then
      if [[ $2 == "prepare" ]]; then
        /run/current-system/sw/bin/toggle_gpu vfio
      elif [[ $2 == "release" ]]; then
        ${pkgs.busybox}/bin/sleep 10
        /run/current-system/sw/bin/toggle_gpu amd
      fi
    fi
  '';

  nvram_path = "/home/sven/.local/share/libvirt/qemu";
  disk_path = "/home/sven/.local/share/libvirt/images";
  win10_config = import ./vms/win10.nix { inherit nvram_path; inherit pkgs; uuid = "c08333dc-33f9-4117-969a-ac46e19ba81f"; };
  win10gpu_config = import ./vms/win10gpu.nix { inherit nvram_path; inherit pkgs; uuid = "3af8cded-1545-4ff2-87d6-d647119aa0e3"; };
in
{
  virtualisation.libvirtd.hooks.qemu = {
    "toggle_gpu" = "${toggle_gpu}/bin/toggle_gpu";
  };

  virtualisation.libvirt.enable = true;
  virtualisation.libvirt.connections."qemu:///system" = {
    # Add pools
    pools = [
      {
        definition = nixvirt.lib.pool.writeXML {
          name = "default";
          uuid = "689ba4f2-da57-43e4-9723-a0551e871c8a";
          type = "dir";
          target = {
            path = "/var/lib/libvirt/images";
          };
        };
      }
      {
        definition = nixvirt.lib.pool.writeXML {
          name = "images";
          uuid = "464a4f52-bbf4-479e-9b2b-ed27116aab7b";
          type = "dir";
          target = {
            path = "${disk_path}";
          };
        };
        volumes = [
          {
            definition = nixvirt.lib.volume.writeXML {
              name = "win10gpu.qcow2";
              capacity = { count = 250; unit = "GiB"; };
              target = {
                format = { type = "qcow2"; };
              };
            };
          }
        ];
        active = true;
      }
      {
        definition = nixvirt.lib.pool.writeXML {
          name = "isos";
          uuid = "5217ddb8-29c2-4a4d-b976-73b9dde59e43";
          type = "dir";
          target = {
            path = "/home/sven/.local/share/libvirt/isos";
          };
        };
        active = true;
      }
    ];

    # Add windows Domain
    domains = [
      { definition = nixvirt.lib.domain.writeXML win10gpu_config; }
      { definition = nixvirt.lib.domain.writeXML win10_config; }
    ];
  };
}
