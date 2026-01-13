{
  config,
  lib,
  pkgs,
  ...
}:

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
    home.packages = with pkgs; [
      nixfmt
      vale
      shellcheck
      eslint
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # Global settings
      opts = {
        number = true;
        relativenumber = true;
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        termguicolors = true;
        laststatus = 2;
        backup = false;
        writebackup = false;
        signcolumn = "yes";
        completeopt = [
          "menu"
          "menuone"
          "noselect"
        ];
      };

      # Global variables
      globals = {
        loaded_netrw = 1;
        loaded_netrwPlugin = 1;
      };

      # Clipboard
      clipboard.providers.pbcopy.enable = true;

      # Colorscheme
      colorschemes.catppuccin = {
        enable = true;
        settings = {
          term_colors = true;
          transparent_background = true;
          integrations = {
            native_lsp = {
              enabled = true;
              virtual_text = {
                errors = [ "italic" ];
                hints = [ "italic" ];
                warnings = [ "italic" ];
                information = [ "italic" ];
              };
              underlines = {
                errors = [ "underline" ];
                hints = [ "underline" ];
                warnings = [ "underline" ];
                information = [ "underline" ];
              };
            };
            cmp = true;
            treesitter = true;
            nvimtree = true;
          };
        };
      };

      # Plugins
      plugins = {
        # File explorer
        nvim-tree = {
          enable = true;
          openOnSetup = true;
          settings = {
            filters = {
              dotfiles = true;
              custom = [ "^.git$" ];
            };
          };
        };

        # LSP
        lsp = {
          enable = true;

          keymaps = {
            diagnostic = {
              "[d" = "goto_prev";
              "]d" = "goto_next";
              "<leader>e" = "open_float";
              "<leader>q" = "setloclist";
            };
            lspBuf = {
              "gD" = "declaration";
              "gd" = "definition";
              "K" = "hover";
              "gi" = "implementation";
              "<C-k>" = "signature_help";
              "<leader>wa" = "add_workspace_folder";
              "<leader>wr" = "remove_workspace_folder";
              "<leader>D" = "type_definition";
              "<leader>rn" = "rename";
              "<leader>ca" = "code_action";
              "gr" = "references";
              "<leader>f" = "format";
            };
          };

          servers = {
            # C/C++
            clangd = {
              enable = true;
              extraOptions = {
                capabilities = {
                  offsetEncoding = [ "utf-16" ];
                };
              };
            };

            # Python
            pyright.enable = true;

            # TypeScript/JavaScript
            ts_ls.enable = true;
            eslint.enable = true;

            # HTML
            html.enable = true;
            emmet_language_server.enable = true;

            # CSS
            cssls.enable = true;
            tailwindcss.enable = true;

            # JSON
            jsonls.enable = true;

            # YAML
            yamlls.enable = true;

            # Docker
            dockerls.enable = true;

            # Bash
            bashls.enable = true;

            # Postgres
            postgres_lsp.enable = true;

            # Lua
            lua_ls = {
              enable = true;
              settings.telemetry.enable = false;
            };

            # Nix
            nixd.enable = true;

            statix.enable = true;

            # VimScript
            vimls.enable = true;

            # LaTeX
            texlab.enable = true;

            # Markdown
            marksman.enable = true;
          };
        };

        # LSP UI enhancements
        lsp-lines.enable = true;

        #trouble = {
        #  enable = true;
        #  settings = {
        #    auto_close = true;
        #    auto_refresh = true;
        #    auto_preview = true;
        #    hl_group = "lualine_c_normal";
        #    modes = {
        #      preview_float = {
        #        mode = "diagnostics";
        #        auto_open = true;
        #        hl_group = "lualine_c_normal";
        #        preview = {
        #          type = "float";
        #          relative = "editor";
        #          border = "rounded";
        #          title = "Preview";
        #          title_pos = "center";
        #          position = [ 0 (-2) ];
        #          size = { width = 0.3; height = 0.3; };
        #          zindex = 200;
        #        };
        #      };
        #    };
        #  };
        #};

        tiny-inline-diagnostic = {
          enable = true;
          settings = {
            multiline = true;
            add_messages = {
              display_count = true;
            };
          };
        };

        # Autocompletion
        cmp = {
          enable = true;
          autoEnableSources = true;

          settings = {
            snippet.expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';

            mapping = {
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<A-CR>" = "cmp.mapping.confirm({ select = true })";
            };

            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "async_path"; }
              { name = "buffer"; }
              { name = "spell"; }
              { name = "tmux"; }
              { name = "treesitter"; }
              { name = "vimtex"; }
              { name = "nixpkgs_maintainers"; }
            ];
          };
        };

        # Snippets
        luasnip.enable = true;

        # Treesitter for better syntax highlighting
        treesitter = {
          enable = true;
          nixGrammars = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };

        gitgutter = {
          enable = true;
          settings = {
            highlight_lines = true;
            highlight_linenrs = true;
            preview_win_floating = true;
            sign_priority = 20;
          };
        };

        # Syntax
        rainbow-delimiters.enable = true;

        # UI
        web-devicons.enable = true;

        lualine = {
          enable = true;
          theme = "auto";
        };

        # Markdown preview
        markdown-preview = {
          enable = true;
          settings = {
            auto_close = 0;
          };
        };

        # Navigation
        tmux-navigator.enable = true;

        # Editing
        nvim-autopairs.enable = true;

        # Nix support
        nix.enable = true;
        nix-develop.enable = true;

        # Formatting
        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              python = [ "black" ];
              javascript = [ "prettier" ];
              typescript = [ "prettier" ];
              html = [ "prettier" ];
              css = [ "prettier" ];
              json = [ "prettier" ];
              yaml = [ "prettier" ];
              markdown = [ "prettier" ];
              nix = [ "nixfmt" ];
            };
            format_on_save = {
              lsp_fallback = true;
              timeout_ms = 500;
            };
          };
        };

        # Linting
        lint = {
          enable = true;
          lintersByFt = {
            javascript = [ "eslint" ];
            typescript = [ "eslint" ];
            markdown = [ "vale" ];
            sh = [ "shellcheck" ];
          };
        };

        # Multi-cursor support
        visual-multi = {
          enable = true;
          settings = {
            maps = {
              "Find Under" = "<C-d>";
              "Find Subword Under" = "<C-d>";
            };
          };
        };

        # Surround
        vim-surround.enable = true;

        # Indent
        indent-blankline.enable = true;
      };

      # Key mappings
      keymaps = [
        # NvimTree
        {
          mode = "n";
          key = "<C-n>";
          action = "<cmd>NvimTreeToggle<CR>";
          options = {
            silent = true;
          };
        }

        # Markdown Preview
        {
          mode = "n";
          key = "<M-m>";
          action = "<cmd>MarkdownPreview<CR>";
          options = { };
        }

        # Tab navigation
        {
          mode = "n";
          key = "<C-Right>";
          action = "<cmd>tabnext<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<C-Left>";
          action = "<cmd>tabprevious<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<C-Down>";
          action = "<cmd>tabclose<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "t";
          key = "<C-Right>";
          action = "<C-\\><C-n><cmd>tabnext<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "t";
          key = "<C-Left>";
          action = "<C-\\><C-n><cmd>tabprevious<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "t";
          key = "<C-Down>";
          action = "<C-\\><C-n><cmd>tabclose<CR>";
          options = {
            silent = true;
          };
        }

        # Search
        {
          mode = "n";
          key = "<C-f>";
          action = "<Esc>/";
          options = {
            silent = true;
          };
        }

        # Window resizing
        {
          mode = "n";
          key = "<C-S-Right>";
          action = "<cmd>vert res +5<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<C-S-Left>";
          action = "<cmd>vert res -5<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<C-S-Up>";
          action = "<cmd>res +5<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<C-S-Down>";
          action = "<cmd>res -5<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "t";
          key = "<C-S-Right>";
          action = "<C-\\><C-n><cmd>vert res +5<CR>i";
          options = {
            silent = true;
          };
        }
        {
          mode = "t";
          key = "<C-S-Left>";
          action = "<C-\\><C-n><cmd>vert res -5<CR>i";
          options = {
            silent = true;
          };
        }
        {
          mode = "t";
          key = "<C-S-Up>";
          action = "<C-\\><C-n><cmd>res +5<CR>i";
          options = {
            silent = true;
          };
        }
        {
          mode = "t";
          key = "<C-S-Down>";
          action = "<C-\\><C-n><cmd>res -5<CR>i";
          options = {
            silent = true;
          };
        }

        # Quit commands
        {
          mode = "n";
          key = "<C-c>";
          action = "<cmd>quitall<CR>";
          options = { };
        }
        {
          mode = "n";
          key = "<C-q>";
          action = "<cmd>q<CR>";
          options = { };
        }
        {
          mode = "i";
          key = "<C-q>";
          action = "<Esc><cmd>q<CR>";
          options = { };
        }
        {
          mode = "t";
          key = "<C-q>";
          action = "<C-\\><C-n><cmd>q<CR>";
          options = { };
        }

        # Save
        {
          mode = "n";
          key = "<A-w>";
          action = "<cmd>w<CR>";
          options = { };
        }
        {
          mode = "i";
          key = "<A-w>";
          action = "<Esc><cmd>w<CR>";
          options = { };
        }

        # Split windows
        {
          mode = "n";
          key = "<A-Down>";
          action = "<cmd>split<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<A-Right>";
          action = "<cmd>vsplit<CR>";
          options = {
            silent = true;
          };
        }

        # Delete word in insert mode
        {
          mode = "i";
          key = "<C-h>";
          action = "<C-w>";
          options = { };
        }

        # Disable n key in normal mode
        {
          mode = "n";
          key = "<n>";
          action = "<Nop>";
          options = { };
        }
      ];

      # Extra configuration
      extraConfigVim = ''
        " Terminal: click to enter insert mode
        if has('nvim')
            augroup terminal_setup | au!
                autocmd TermOpen * nnoremap <buffer><LeftRelease> <LeftRelease>i
            augroup end
        endif

        " Open on last line before closed
        autocmd BufRead * autocmd FileType <buffer> ++once
          \ if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif

        " Auto enter insert mode in terminal
        autocmd BufWinEnter,WinEnter term://* startinsert
      '';
    };
  };
}
