{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.jupyterhub;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
  jupyterhubUrl = "https://jupyter.${cfgS.publicDomain}";
in
{

  options.holynix.services.jupyterhub = {
    enable = mkEnableOption "Enable JupyterHub.";

    oauth = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable oauth for JupyterHub.";
      };
      issuerBaseUrl = mkOption {
        type = str;
        default = "";
        description = "Issuere URL for JupyterHub oauth";
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "services/jupyterhub/crypt_key".restartUnits = [ "jupyterhub.service" ];
    }
    // optionalAttrs cfg.oauth.enable {
      "services/jupyterhub/client_id".restartUnits = [ "jupyterhub.service" ];
      "services/jupyterhub/client_secret".restartUnits = [ "jupyterhub.service" ];
    };

    systemd.tmpfiles.rules = [
      "d ${config.systemd.services.jupyterhub.serviceConfig.WorkingDirectory}/workdirs 0755 1000 100 -"
    ];

    hardware.nvidia-container-toolkit.enable = true;

    networking.firewall.interfaces = mkIf config.services.postgresql.enable {
      "podman0".allowedTCPPorts = [ config.services.jupyterhub.port ];
    };

    services = {
      jupyterhub = {
        enable = true;
        port = 8442;
        spawner = "dockerspawner.DockerSpawner";
        jupyterhubEnv = pkgs.python3.withPackages (
          ps: with ps; [
            jupyterhub
            oauthenticator
            dockerspawner
          ]
        );
        extraConfig = ''
          import os

          ${optionalString cfg.oauth.enable ''
            # --- Authentik OIDC (secrets read from /run/secrets at runtime) ---
            c.GenericOAuthenticator.client_id = \
                open("${config.sops.secrets."services/jupyterhub/client_id".path}").read().strip()
            c.GenericOAuthenticator.client_secret = \
                open("${config.sops.secrets."services/jupyterhub/client_secret".path}").read().strip()
            c.GenericOAuthenticator.oauth_callback_url = "${jupyterhubUrl}/hub/oauth_callback"
            c.GenericOAuthenticator.authorize_url = "${cfg.oauth.issuerBaseUrl}/application/o/authorize/"
            c.GenericOAuthenticator.token_url = "${cfg.oauth.issuerBaseUrl}/application/o/token/"
            c.GenericOAuthenticator.userdata_url = "${cfg.oauth.issuerBaseUrl}/application/o/userinfo/"
            c.GenericOAuthenticator.scope = ["openid", "profile", "email"]
            c.GenericOAuthenticator.username_claim = "preferred_username"
            c.GenericOAuthenticator.logout_redirect_url = "${cfg.oauth.issuerBaseUrl}/application/o/jupyterhub/end-session/"
            c.GenericOAuthenticator.allow_all = True
            c.GenericOAuthenticator.enable_auth_state = True
            c.GenericOAuthenticator.login_service = "Authentik"
          ''}

          c.CryptKeeper.keys = [
              open("${config.sops.secrets."services/jupyterhub/crypt_key".path}").read().strip()
          ]

          c.ServerApp.jpserver_extensions = {
              "jupyter_server_nbmodel": True
          }

          # --- Podman spawner (via Docker socket) ---
          c.JupyterHub.hub_ip = "0.0.0.0"
          c.JupyterHub.hub_connect_ip = "127.0.0.1"

          c.DockerSpawner.hub_connect_url = "http://10.88.0.1:${toString config.services.jupyterhub.port}/"

          c.DockerSpawner.image = "docker.io/cschranz/gpu-jupyter:v1.9_cuda-12.6_ubuntu-24.04_python-only"
          c.DockerSpawner.environment = {
            "JUPYTER_ENABLE_LAB": "yes"
          }
          c.DockerSpawner.remove = False
          c.DockerSpawner.start_timeout = 120
          c.DockerSpawner.volumes = {
            "/var/lib/jupyterhub/workdirs/{username}": "/home/jovyan/work",
            "${pkgs.writeText "20-pip-setup.sh" ''
              #!/bin/bash
              # Place in /usr/local/bin/before-notebook.d/ (runs as NB_USER, sourced, so no exit/set -e at top level)

              _pip_setup() (
                  set -euo pipefail

                  pip config set global.extra-index-url ""
                  pip install --no-cache-dir "jupyter_server_nbmodel[lab]"
                  pip install --upgrade --no-cache-dir "jupyterlab>=4.4.5"
              )

              _pip_setup || echo "[hook] pip setup failed" >&2
              unset -f _pip_setup
            ''}": {
              "bind": "/usr/local/bin/before-notebook.d/20-pip-setup.sh",
              "mode": "ro"
            }
          }
          c.DockerSpawner.notebook_dir = "/home/jovyan/work"

          import docker
          c.DockerSpawner.extra_host_config = {
              "devices": ["nvidia.com/gpu=all"],
              "device_requests": [
                  docker.types.DeviceRequest(
                      driver="nvidia",
                      count=-1,  # -1 = all
                      capabilities=[["gpu"]],
                  )
              ],
          }
        '';
        authentication = mkIf cfg.oauth.enable "oauthenticator.generic.GenericOAuthenticator";
      };

      cloudflared.tunnels."${cfgC.tunnelId}".ingress."jupyter.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://jupyter.${cfgS.privateDomain}";
      caddy = {
        enable = true;
        virtualHosts."jupyter.${cfgS.publicDomain}" = {
          serverAliases = [ "jupyter.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy http://localhost:${toString config.services.jupyterhub.port}
          '';
        };
      };
    };
  };
}
