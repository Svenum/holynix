{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.tools.nvim;
in
{
  options.holynix.tools.nvim = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      coc = {
        enable = true;
        settings = {
          "emmet.includeLanguages" = {
            php = "html";
          };
        };
      };
      defaultEditor = true;
      extraConfig = builtins.readFile ./init.vim;
      withNodeJs = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        # Plugins
        vim-plug
        # CoC
        coc-sh
        coc-git
        coc-css
        coc-yaml
        coc-nvim
        coc-json
        coc-html
        coc-eslint
        coc-docker
        coc-tabnine
        coc-tsserver
        coc-prettier
        coc-highlight
        coc-markdownlint
        coc-spell-checker
        coc-vimlsp
        coc-vimtex
        coc-lua
        coc-clangd
        coc-emmet
        coc-pyright
        nvim-lspconfig
        clangd_extensions-nvim
        # nix
        statix
        vim-nix
        # Explorer
        nvim-web-devicons
        nvim-tree-lua
        # Syntax highlighter
        rainbow
        # IDE
        auto-pairs
        surround-nvim
        vim-prettier
        # Terminal
        vim-tmux-navigator
        # Git
        vim-gitgutter
        # Markdown Preview
        markdown-preview-nvim
        # Pets
        holynix.pets-nvim
        hologram-nvim
        nui-nvim
      ];
    };

    catppuccin.nvim.settings = {
      term_colors = true;
      transparent_background = true;
      integrations = {
        coc_nvim = true;
        gitgutter = true;
      };
    };
  };
}
