{ options, config, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.holynix.sops;
in
{
  options.holynix.sops = {
    enableHostKey = mkOption {
      type = bool;
      default = false;
      description = "Enable the host ssh_key for sops";
    };
    defaultSopsFile = mkOption {
      type = path;
      default = ./secrets/secret.yaml;
      description = "Default secret file";
    };
    sshKeyPaths = mkOption {
      type = nullOr (listOf (str));
      default = null;
      description = "Path of the private ssh key to encrypt";
    };
    initSecrets = mkOption {
      type = nullOr (listOf (str));
      default = null;
      description = "List of secrets to initial";
    };
  };

  config = mkIf cfg.enableHostKey {
    sops = {
      defaultSopsFile = cfg.defaultSopsFile;
      age.sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ] ++ optionals (cfg.sshKeyPaths != null) cfg.sshKeyPaths;
      age.keyFile = "/var/lib/sops-nix/key.txt";
      age.generateKey = true;
    };
  };
}
