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

  ctx = pkgs.writeTextDir "Containerfile" ''
    FROM docker.io/cschranz/gpu-jupyter:v1.9_cuda-12.6_ubuntu-24.04_python-only

    RUN pip config set global.extra-index-url "" \
      && pip install --no-cache-dir -U \
      jupyterlab notebook \
      jupyter-collaboration jupyter-docprovider jupyter-server-nbmodel \
      jupyterlab-git jupyterlab-spellchecker jupyterlab_execute_time \
      jupyterlab_widgets ipywidgets ipyleaflet ipympl \
      nbdime plotly jupyterlab_pygments \
      && pip check

    RUN --mount=type=bind,from=docker.io/library/node:22-slim,source=/usr/local,target=/opt/node \
      PATH="/opt/node/bin:$PATH" \
      jupyter lab build --dev-build=False --minimize=False
  '';

  tag = "localhost/gpu-jupyter-custom:${
    builtins.substring 0 12 (builtins.hashString "sha256" (builtins.readFile "${ctx}/Containerfile"))
  }";
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
      "d /var/lib/${config.services.jupyterhub.stateDirectory}/workdirs 0755 1000 100 -"
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


          def create_dir_hook(spawner):
            username = spawner.user.name
            volume_path = f"/var/lib/${config.services.jupyterhub.stateDirectory}/{username}"
            work_path = f"{volume_path}/work"

            for path in (volume_path, work_path):
              if not os.path.exists(path):
                os.makedirs(path, mode=0o755)
                os.chown(path, 1000, 100)
          c.Spawner.pre_spawn_hook = create_dir_hook

          c.DockerSpawner.hub_connect_url = "http://10.88.0.1:${toString config.services.jupyterhub.port}/"

          c.DockerSpawner.image = "${tag}"
          c.DockerSpawner.environment = {
            "JUPYTER_ENABLE_LAB": "yes"
          }
          c.DockerSpawner.remove = False
          c.DockerSpawner.volumes = {
            "/var/lib/${config.services.jupyterhub.stateDirectory}/workdirs/{username}": "/home/jovyan"
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

    systemd.services = {
      gpu-jupyter-build = {
        description = "Build gpu-jupyter derived image";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        path = [ pkgs.podman ];
        # buildah/podman need these helpers when run from a unit
        environment.PATH = pkgs.lib.mkForce (
          pkgs.lib.makeBinPath [
            pkgs.podman
            pkgs.conmon
            pkgs.crun
            pkgs.runc
            pkgs.netavark
            pkgs.shadow
            pkgs.util-linux
            pkgs.coreutils
            pkgs.iptables
            pkgs.fuse-overlayfs
          ]
          + ":/run/wrappers/bin"
        );

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          TimeoutStartSec = "1h";
        };

        script = ''
          if ! podman image exists ${tag}; then
            podman build -f ${ctx}/Containerfile -t ${tag} ${ctx}
          fi
          podman tag ${tag} localhost/gpu-jupyter-custom:latest
        '';
      };

      jupyterhub = {
        after = [ "gpu-jupyter-build.service" ];
        requires = [ "gpu-jupyter-build.service" ];
      };
    };
  };
}
