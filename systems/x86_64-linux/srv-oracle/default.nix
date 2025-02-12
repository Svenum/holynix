{ pkgs, lib, config, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware.nix
  ];

  holynix = {
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType = {
      vm.enable = true;
      server.enable = true;
    };
    users = {
      "sudouser" = {
        isGuiUser = true;
        isSudoUser = true;
        uid = 1000;
        initialPassword = "test123";
        authorizedKeys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
    };
    tools = {
      nvim.enable = true;
      tmux.enable = true;
      cliTools.enable = true;
    };
    network.enable = true;
    virtualisation.docker.enable = true;
  };
}
