{ pkgs, inputs, ... }:

let
  inherit (inputs) nixVirt;
  nixvirt.lib = nixVirt.lib;
  toggle_gpu = pkgs.writeShellScriptBin "toggle_gpu" ''
    if [[ $1 == "${win10gpuConfig.name}" ]]; then
      if [[ $2 == "prepare" ]]; then
        /run/current-system/sw/bin/toggle-amd-gpu vfio
      elif [[ $2 == "release" ]]; then
        ${pkgs.busybox}/bin/sleep 10
        /run/current-system/sw/bin/toggle-amd-gpu amd
      fi
    fi
  '';

  # Path
  nvramPath = "/home/sven/.local/share/libvirt/qemu";
  diskPath = "/home/sven/.local/share/libvirt/images";

  # Windows VMs
  win10Config = import ./vms/win10.nix {
    inherit nvramPath;
    inherit pkgs;
    uuid = "c08333dc-33f9-4117-969a-ac46e19ba81f";
  };
  win10gpuConfig = import ./vms/win10gpu.nix {
    inherit nvramPath;
    inherit pkgs;
    uuid = "3af8cded-1545-4ff2-87d6-d647119aa0e3";
  };

  # Kubernetes Nodes
  node1Config = import ./vms/node.nix {
    inherit pkgs;
    uuid = "7fdb457d-0417-4156-95fa-92b9187219ac";
    nodeID = "1";
    inherit diskPath;
    inherit nvramPath;
  };
  node2Config = import ./vms/node.nix {
    inherit pkgs;
    uuid = "8b302b1d-2055-4d60-8b98-24f375de218f";
    nodeID = "2";
    inherit diskPath;
    inherit nvramPath;
  };
  node3Config = import ./vms/node.nix {
    inherit pkgs;
    uuid = "47847aa8-231c-4e52-9aae-fc7f4178d736";
    nodeID = "3";
    inherit diskPath;
    inherit nvramPath;
  };
in
{
  virtualisation = {
    libvirtd = {
      enable = true;
      hooks.qemu = {
        "toggle_gpu" = "${toggle_gpu}/bin/toggle_gpu";
      };
    };

    libvirt = {
      enable = true;
      connections."qemu:///system" = {
        # Add networks
        networks = [
          {
            definition = nixvirt.lib.network.writeXML {
              name = "default";
              uuid = "5d84e370-c682-4186-ba72-d20dfc85d432";
              forward = {
                mode = "nat";
                nat = {
                  port = {
                    start = 1024;
                    end = 65535;
                  };
                };
              };
              bridge = {
                name = "virbr0";
                stp = true;
                delay = 0;
              };
              mac.address = "52:54:00:2d:98:61";
              ip = {
                address = "192.168.122.1";
                netmask = "255.255.255.0";
                dhcp = {
                  range = {
                    start = "192.168.122.2";
                    end = "192.168.122.254";
                  };
                };
              };
            };
            active = true;
          }
          {
            definition = nixvirt.lib.network.writeXML {
              name = "kube";
              uuid = "23897c1c-b6b3-49a3-8f96-a89765ae1113";
              forward = {
                mode = "nat";
                nat = {
                  port = {
                    start = 1024;
                    end = 65535;
                  };
                };
              };
              bridge = {
                name = "virbr1";
                stp = true;
                delay = 0;
              };
              mac.address = "52:54:00:2d:97:60";
              ip = {
                address = "10.10.0.1";
                netmask = "255.255.255.0";
                dhcp = {
                  host = [
                    {
                      name = "node1";
                      mac = node1Config.devices.interface.mac.address;
                      ip = "10.10.0.11";
                    }
                    {
                      name = "node2";
                      mac = node2Config.devices.interface.mac.address;
                      ip = "10.10.0.12";
                    }
                    {
                      name = "node3";
                      mac = node3Config.devices.interface.mac.address;
                      ip = "10.10.0.13";
                    }
                  ];
                };
              };
            };
            active = true;
          }
          {
            definition = nixvirt.lib.network.writeXML {
              name = "internal";
              uuid = "f34b98c3-38ea-4972-84b4-4b525d0675e5";
              bridge = {
                name = "virbr2";
                stp = true;
                delay = 0;
              };
              mac.address = "52:54:00:de:df:59";
              ip = {
                address = "192.168.100.1";
                netmask = "255.255.255.0";
              };
              dhcp = {
                range = {
                  start = "192.168.100.2";
                  end = "192.168.100.254";
                };
              };
            };
            active = true;
          }
        ];

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
                path = "${diskPath}";
              };
            };
            volumes = [
              {
                definition = nixvirt.lib.volume.writeXML {
                  name = "node1.qcow2";
                  capacity = {
                    count = 150;
                    unit = "GiB";
                  };
                  target = {
                    format = {
                      type = "qcow2";
                    };
                  };
                };
              }
              {
                definition = nixvirt.lib.volume.writeXML {
                  name = "node2.qcow2";
                  capacity = {
                    count = 150;
                    unit = "GiB";
                  };
                  target = {
                    format = {
                      type = "qcow2";
                    };
                  };
                };
              }
              {
                definition = nixvirt.lib.volume.writeXML {
                  name = "node3.qcow2";
                  capacity = {
                    count = 150;
                    unit = "GiB";
                  };
                  target = {
                    format = {
                      type = "qcow2";
                    };
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
          { definition = nixvirt.lib.domain.writeXML win10gpuConfig; }
          { definition = nixvirt.lib.domain.writeXML win10Config; }
          { definition = nixvirt.lib.domain.writeXML node1Config; }
          { definition = nixvirt.lib.domain.writeXML node2Config; }
          { definition = nixvirt.lib.domain.writeXML node3Config; }
        ];
      };
    };
  };
}
