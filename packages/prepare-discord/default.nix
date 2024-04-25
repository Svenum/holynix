{ accent ? "teal", pkgs, ... }:

pkgs.writeShellScriptBin "prepare-discord" ''
  # Install spotify
  flatpak install --user com.discordapp.Discord -y

  echo "Please login and then close discord"
  flatpak kill com.discordapp.Discord > /dev/zero 2>&1
  flatpak run com.discordapp.Discord > /dev/zero 2>&1

  # install betterdiscord 
  echo "install betterdiscord ..."
  betterdiscordctl -i flatpak install

  # Prepare theme
  echo "Do you want to use the light (l), dark (d) or none (n) theme?"
  read theme

  if [ $theme = "d" ]; then
    echo "
  /* @import url("https://catppuccin.github.io/discord/dist/catppuccin-latte-${accent}.theme.css"); */
  @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-${accent}.theme.css");
  " > $HOME/.var/app/com.discordapp.Discord/config/BetterDiscord/data/stable/custom.css
  elif [ $theme = "l" ]; then
    echo "
  @import url("https://catppuccin.github.io/discord/dist/catppuccin-latte-${accent}.theme.css");
  /* @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-${accent}.theme.css"); */
  " > $HOME/.var/app/com.discordapp.Discord/config/BetterDiscord/data/stable/custom.css

  else
    echo "
  /* @import url("https://catppuccin.github.io/discord/dist/catppuccin-latte-${accent}.theme.css"); */
  /* @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-${accent}.theme.css"); */
  " >> $HOME/.var/app/com.discordapp.Discord/config/BetterDiscord/data/stable/custom.css
  fi
''
