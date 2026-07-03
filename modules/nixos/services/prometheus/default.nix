{
  lib,
  config,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.prometheus;
  cfgS = config.holynix.services;
  cpe = config.services.prometheus.exporters;

  hasZfs = lib.any (fs: fs.fsType == "zfs") (lib.attrValues config.fileSystems);
in
{
  options.holynix.services.prometheus = {
    enable = mkEnableOption "Enable Prometheus service";
    enableExporters = mkOption {
      type = bool;
      default = true;
      description = "Enable prometheus exporters";
    };
    enableServer = mkOption {
      type = bool;
      default = true;
      description = "Enable prometheus server";
    };
  };

  config = mkIf cfg.enable {

    services = {
      prometheus = {
        enable = cfg.enableServer;
        exporters = mkIf cfg.enableExporters {
          zfs.enable = hasZfs;
          postgres = mkIf config.services.postgresql.enable {
            enable = true;
            runAsLocalSuperUser = true;
          };
          nut = mkIf config.power.ups.enable {
            enable = true;
            nutUser = "exporter";
            passwordPath = config.power.ups.users.exporter.passwordFile;
          };
          systemd.enable = true;
          smartctl.enable = true;
          libvirt.enable = config.virtualisation.libvirtd.enable;
          node.enable = true;
          blackbox = mkIf config.services.caddy.enable {
            enable = true;
            configFile = builtins.toFile "config.yaml" ''
              modules:
                http_2xx:
                  prober: http
                  http:
                    preferred_ip_protocol: "ip4"
                    skip_resolve_phase_with_proxy: true
                http_post_2xx:
                  prober: http
                  http:
                    method: POST
                tcp_connect:
                  prober: tcp
                pop3s_banner:
                  prober: tcp
                  tcp:
                    query_response:
                    - expect: "^+OK"
                    tls: true
                    tls_config:
                      insecure_skip_verify: false
                grpc:
                  prober: grpc
                  grpc:
                    tls: true
                    preferred_ip_protocol: "ip4"
                grpc_plain:
                  prober: grpc
                  grpc:
                    tls: false
                    service: "service1"
                ssh_banner:
                  prober: tcp
                  tcp:
                    query_response:
                    - expect: "^SSH-2.0-"
                    - send: "SSH-2.0-blackbox-ssh-check"
                icmp:
                  prober: icmp
                icmp_ttl5:
                  prober: icmp
                  timeout: 5s
                  icmp:
                    ttl: 5
            '';
          };
        };
        scrapeConfigs =
          lists.optional cpe.zfs.enable {
            job_name = "zfs";
            static_configs = [ { targets = [ "localhost:${toString cpe.zfs.port}" ]; } ];
          }
          ++ lists.optional cpe.postgres.enable {
            job_name = "postgres";
            static_configs = [ { targets = [ "localhost:${toString cpe.postgres.port}" ]; } ];
          }
          ++ lists.optional cpe.systemd.enable {
            job_name = "systemd";
            static_configs = [ { targets = [ "localhost:${toString cpe.systemd.port}" ]; } ];
          }
          ++ lists.optional cpe.smartctl.enable {
            job_name = "smartctl";
            static_configs = [ { targets = [ "localhost:${toString cpe.smartctl.port}" ]; } ];
          }
          ++ lists.optional cpe.nut.enable {
            job_name = "nut";
            metrics_path = "ups_metrics";
            static_configs = [ { targets = [ "localhost:${toString cpe.nut.port}" ]; } ];
          }
          ++ lists.optional cpe.libvirt.enable {
            job_name = "libvirt";
            static_configs = [ { targets = [ "localhost:${toString cpe.libvirt.port}" ]; } ];
          }
          ++ lists.optional cpe.node.enable {
            job_name = "node";
            static_configs = [ { targets = [ "localhost:${toString cpe.node.port}" ]; } ];
          }
          ++ lists.optional cpe.blackbox.enable {
            job_name = "blackbox";
            metrics_path = "/probe";
            static_configs = [
              { targets = builtins.attrNames config.services.caddy.virtualHosts; }
            ];
            params.module = [ "http_2xx" ];
            relabel_configs = [
              {
                source_labels = [ "__address__" ];
                regex = "(.*)";
                replacement = "https://\${1}";
                target_label = "__param_target";
              }
              {
                source_labels = [ "__param_target" ];
                target_label = "instance";
              }
              {
                target_label = "__address__";
                replacement = "localhost:${toString cpe.blackbox.port}";
              }
            ];
          };
      };

      caddy = {
        enable = true;
        virtualHosts."prometheus.${cfgS.publicDomain}" = {
          serverAliases = [ "prometheus.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy localhost:${toString config.services.prometheus.port}
          '';
        };
      };
    };
    users.users.nut-exporter = {
      isSystemUser = true;
      group = "nut-exporter";
    };
    users.groups.nut-exporter = { };
    systemd.services.prometheus-nut-exporter.serviceConfig.DynamicUser = lib.mkForce false;
  };
}
