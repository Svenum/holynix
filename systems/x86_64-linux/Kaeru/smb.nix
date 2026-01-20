{
  lib,
  ...
}:

let
  # Funktion zum Erstellen eines User-Shares
  mkUserShare = username: {
    "path" = "/mnt/storage/${username}";
    "browseable" = "yes";
    "writable" = "yes";
    "guest ok" = "no";
    "valid users" = username;
    "create mask" = "0664";
    "directory mask" = "0775";
    "force user" = username;
  };

  # Liste der User
  users = [
    "sven"
    "martin"
    "carmen"
    "zoe"
    "rick"
  ];

  # Shares for every user
  userShares = lib.listToAttrs (
    map (user: {
      name = user;
      value = mkUserShare user;
    }) users
  );

  smbUsers = lib.listToAttrs (
    map (user: {
      name = user;
      value = {
        isNormalUser = true;
        home = "/mnt/storage/${user}";
        createHome = true;
      };
    }) users
  );

in
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "Kaeru";
        "map to guest" = "bad user";
        "security" = "user";

        # SMB3 min version
        "server min protocol" = "SMB3";
        "smb encrypt" = "desired";

        # ZFS optimise Performance
        "strict allocate" = "yes";
        "allocation roundup size" = "131072";
        "min receivefile size" = "16384";

        # Performance
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
        "read raw" = "yes";
        "write raw" = "yes";
        "max xmit" = "131072";
        "aio read size" = "16384";
        "aio write size" = "16384";
        "use sendfile" = "yes";

        # Timeouts
        "dead time" = "15";
        "getwd cache" = "yes";

        # Logging
        "log level" = "1";
        "max log size" = "1000";
      };
    }
    // userShares;
  };

  users.users = smbUsers;
}
