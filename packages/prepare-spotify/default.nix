{ pkgs }:

pkgs.writeShellScriptBin "prepare-spotify" ''
  # Install spotify
  flatpak install --user com.spotify.Client -y
  echo "Please login and then close Spotify"
  flatpak kill com.spotify.Client > /dev/zero 2>&1
  flatpak run com.spotify.Client > /dev/zero 2>&1

  # Prepare backupe
  echo "prepare backup ..."
  spicetify-cli backup apply

  # Prepare config
  echo "prepare config ..."
  mkdir -p $HOME/.config/spicetify
  sed -i 's,spotify_path *=.*,spotify_path = '"$HOME"'/.local/share/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/,g' $HOME/.config/spicetify/config-xpui.ini
  sed -i 's,prefs_path *=.*,prefs_path = '"$HOME"'/.var/app/com.spotify.Client/config/spotify/prefs,g' $HOME/.config/spicetify/config-xpui.ini

  spicetify-cli restart 

  # Install marketplace
  # echo "install marketplace ..."
  curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.sh | sh
''
