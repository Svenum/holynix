{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.restic;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{

  options.holynix.services.restic = {
    enable = mkEnableOption "Enable restic";
    proxyAuth = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable proxyAuth for restic";
      };
      proxyAuthUsername = mkOption {
        type = str;
        default = "X-Authentik-Username";
        description = "Field in which the username stands";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      restic.server = {
        enable = true;
        listenAddress = "8180";
        extraFlags = lists.optionals cfg.proxyAuth.enable [
          "--no-auth"
          "--proxy-auth-username=${cfg.proxyAuth.proxyAuthUsername}"
        ];
        privateRepos = true;
        htpasswd-file = mkIf cfg.proxyAuth.enable "/dev/null";
      };
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."restic.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://restic.${cfgS.privateDomain}";
      caddy = {
        enable = true;
        virtualHosts."restic.${cfgS.publicDomain}" = {
          serverAliases = [ "restic.${cfgS.privateDomain}" ];
          extraConfig = ''
            route {
              import authentik
              reverse_proxy http://localhost:${toString config.services.restic.server.listenAddress}
            }
          '';
        };
      };
    };
  };
}
