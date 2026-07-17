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
      "directory mask" = "0755";
    };
    jellyfin = {
      path = "/srv/media/jellyfin";
      browseable = "no";
      writable = "yes";
      "valid users" = "martin sven";
      "force user" = "jellyfin";
      "force group" = "jellyfin";
      "create mask" = "0644";
      "directory mask" = "0755";
    };
  };
}
