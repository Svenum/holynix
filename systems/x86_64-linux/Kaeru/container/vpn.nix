{ config, ... }:

{
  sops.secrets."vpn.env" = {
    sopsFile = ../../../../secrets/kaeru/container/vpn.env;
    format = "dotenv";
    key = "";
  };

  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) networks;
      volumePath = "/mnt/container/vpn";
    in
    {
      containers = {
        "vpn_tailscale" = {
          autoStart = true;
          containerConfig = {
            image = "docker.io/tailscale/tailscale:latest";
            environments = {
              TS_STATE_DIR = "/var/lib/tailscale";
              TS_USERSPACE = "true";
              TS_EXTRA_ARGS = "--hostname=srv-kaeru --reset --advertise-exit-node --advertise-routes=172.16.0.0/24";
              TS_TAILSCALED_EXTRA_ARGS = "--encrypt-state=false";
            };
            volumes = [
              "${volumePath}/tailscale:/var/lib/tailscale"
            ];
            devices = [
              "/dev/net/tun:/dev/net/tun"
              "/dev/tpm0:/dev/tpm0"
            ];
            addCapabilities = [
              "NET_ADMIN"
            ];
            networks = [
              networks.vpn_default.ref
            ];
          };
        };
      };
      networks.vpn_default = {
        autoStart = true;
        networkConfig = {
          driver = "bridge";
          interfaceName = "pod_vpn";
        };
      };
    };
}
