{
  inputs,
  ...
}:

let
  inherit (inputs) nixVirt;
  virtLib = nixVirt.lib;
in
{
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      networks = [
        {
          definition = virtLib.network.writeXML {
            name = "default";
            uuid = "d85b8121-3992-41fa-9e7a-667fa09805de";
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
            mac.address = "52:54:00:dd:06:12";
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
      ];
      pools = [
        {
          definition = virtLib.pool.writeXML {
            name = "default";
            uuid = "c0db12a7-03aa-4b24-a436-4f0f22e939ca";
            type = "zfs";
            source = {
              name = "tank/datadir/libvirt";
            };
          };
        }
        {
          definition = virtLib.pool.writeXML {
            name = "isos";
            uuid = "bf534b7c-610d-496b-8cc4-636278f8cbcc";
            type = "dir";
            target = {
              path = "/var/lib/libvirt/isos";
            };
          };
        }
      ];
      domains = [
        #{ definition = virtLib.domain.writeXML homeassistant; }
      ];
    };
  };
}
