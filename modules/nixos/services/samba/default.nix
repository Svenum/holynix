{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.samba;
in
{

  options.holynix.services.samba = {
    enable = mkEnableOption "Enable samba";
    userShareRoot = mkOption {
      type = str;
      default = "/srv/data";
      description = "Root path of the users default smb share";
    };

    userShares = mkOption {
      type = listOf str;
      default = [ ];
      description = "Users which will get share";
    };
  };

  config = mkIf cfg.enable {
    assertions = map (u: {
      assertion = hasAttr u config.users.users;
      message = "holynix.services.samba.userShares: user '${u}' is not defined in users.users";
    }) cfg.userShares;

    services = {
      samba-wsdd = {
        enable = true;
        openFirewall = true;
      };
      samba = {
        enable = true;
        package = pkgs.samba4Full;
        openFirewall = true;
        usershares.enable = true;
        settings = {
          global = {
            # Default
            "workgroup" = "WORKGROUP";
            "server string" = config.networking.hostName;

            # Security
            "security" = "user";
            "passdb backend" = "tdbsam";
            "map to guest" = "never";
            "restrict anonymous" = 2;
            "server min protocol" = "SMB3";
            "smb encrypt" = "required";
            "server signing" = "mandatory";

            # Performance
            "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536";
            "read raw" = "yes";
            "write raw" = "yes";
            "max xmit" = 65535;
            "use sendfile" = "yes";
            "allocation roundup size" = 4096;
            "aio read size" = 16384;
            "aio write size" = 16384;

            # Logging
            "log level" = 1;
            "logging" = "systemd";
          };
        }
        // listToAttrs (
          map (name: {
            inherit name;
            value = {
              path = "${cfg.userShareRoot}/${name}";
              browseable = "no";
              writable = "yes";
              "valid users" = name;
              "create mask" = "0644";
              "directory mask" = "0755";
            };
          }) cfg.userShares
        );
      };
    };
    systemd.tmpfiles.rules = map (
      name: "d ${cfg.userShareRoot}/${name} 0750 ${name} users -"
    ) cfg.userShares;
  };

}
