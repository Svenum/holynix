_:

{
  virtualisation.quadlet = {
    networks = {
      "proxy" = {
        autoStart = true;
        networkConfig = {
          driver = "bridge";
        };
      };
      "br0" = {
        autoStart = true;
        networkConfig = {
          driver = "ipvlan";
          gateways = [ "172.16.0.1" ];
          subnets = [ "172.16.0.0/24" ];
          options.parent = "br0";
        };
      };
    };
  };
}
