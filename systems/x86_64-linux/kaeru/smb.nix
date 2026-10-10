{
  services.samba.settings = {
    photos = {
      path = "/srv/photos";
      browseable = "no";
      writable = "yes";
      "valid users" = "martin";
      "force user" = "nobody";
      "force group" = "users";
      "create mask" = "0644";
      "directory mask" = "0775";
    };
    jellyfin = {
      path = "/srv/media/jellyfin";
      browseable = "no";
      writable = "yes";
      "valid users" = "martin rick sven";
      "force user" = "jellyfin";
      "force group" = "jellyfin";
      "create mask" = "0644";
      "directory mask" = "0775";
    };
    handbrake = {
      path = "/srv/media/handbrake";
      browseable = "no";
      writable = "yes";
      "valid users" = "martin rick sven";
      "force user" = "root";
      "force group" = "root";
      "create mask" = "0644";
      "directory mask" = "0775";
    };
  };
}
