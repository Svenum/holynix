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
      ripgrep
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withPython3 = true;

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
        mapleader = " ";
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
            indent_blankline = {
              enable = true;
              colored_indent_levels = true;
            };
            cmp = true;
            treesitter = true;
            treesitter_context = true;
            nvimtree = true;
          };
        };
      };

      # diagnostic
      diagnostic.settings = {
        virtual_text = false;
        signs.text = {
          "__rawKey__vim.diagnostic.severity.ERROR" = "●";
          "__rawKey__vim.diagnostic.severity.WARN" = "●";
          "__rawKey__vim.diagnostic.severity.INFO" = "●";
          "__rawKey__vim.diagnostic.severity.HINT" = "●";
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

        # Fuzzy Finder
        telescope = {
          enable = true;
          extensions = {
            file-browser.enable = true;
            fzf-native.enable = true;
          };
        };

        # LSP
        lsp = {
          enable = true;
          inlayHints = true;

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
            basedpyright = {
              enable = true;
              settings.basedpyright.analysis.inlayHints = {
                callArgumentNames = true;
                variableTypes = true;
                returnTypes = true;
              };
            };

            # TypeScript/JavaScript
            ts_ls = {
              enable = true;
              settings = {
                typescript.inlayHints = {
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = true;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayVariableTypeHints = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayEnumMemberValueHints = true;
                };
                javascript.inlayHints = {
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = true;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayVariableTypeHints = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayEnumMemberValueHints = true;
                };
              };
            };
            biome.enable = true;

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
              settings = {
                telemetry.enable = false;
                Lua.hint = {
                  enable = true;
                  arrayIndex = "Enable";
                  await = true;
                  paramName = "All";
                  paramType = true;
                  setType = true;
                };
              };
            };

            # Nix
            nixd = {
              enable = true;
              config.cmd = [ "--inlay-hints" ];
            };

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

        tiny-inline-diagnostic = {
          enable = true;
          settings = {
            preset = "powerline";
            options = {
              multilines = true;
              add_messages = {
                display_count = true;
              };
              show_source = {
                enabled = true;
              };
              use_icons_from_diagnostic = false;
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
        rainbow-delimiters = {
          enable = true;
          settings.highlight = [
            "RainbowDelimiterRed"
            "RainbowDelimiterYellow"
            "RainbowDelimiterBlue"
            "RainbowDelimiterOrange"
            "RainbowDelimiterGreen"
            "RainbowDelimiterViolet"
            "RainbowDelimiterCyan"
          ];
        };

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
        indent-blankline = {
          enable = true;
          settings.scope.highlight = [
            "RainbowDelimiterRed"
            "RainbowDelimiterYellow"
            "RainbowDelimiterBlue"
            "RainbowDelimiterOrange"
            "RainbowDelimiterGreen"
            "RainbowDelimiterViolet"
            "RainbowDelimiterCyan"
          ];
        };
      };

      # Key mappings
      keymaps = [
        # Telescope
        {
          mode = "n";
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<CR>";
          options = {
            silent = true;
            desc = "Telescope find_files";
          };
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
          options = {
            silent = true;
            desc = "Telescope live_grep";
          };
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = "<cmd>Telescope buffers<CR>";
          options = {
            silent = true;
            desc = "Telescope buffers";
          };
        }
        # NvimTree
        {
          mode = "n";
          key = "<C-n>";
          action = "<cmd>NvimTreeToggle<CR>";
          options = {
            silent = true;
            desc = "Toggle NvimTree";
          };
        }

        # Markdown Preview
        {
          mode = "n";
          key = "<M-m>";
          action = "<cmd>MarkdownPreview<CR>";
          options = {
            desc = "Toggle MarkdownPreview";
          };
        }

        # Window resizing
        {
          mode = "n";
          key = "<C-Right>";
          action = "<cmd>vert res +5<CR>";
          options = {
            silent = true;
            noremap = true;
            desc = "Grow window vertically";
          };
        }
        {
          mode = "n";
          key = "<C-Left>";
          action = "<cmd>vert res -5<CR>";
          options = {
            silent = true;
            noremap = true;
            desc = "Shrink window vertically";
          };
        }
        {
          mode = "n";
          key = "<C-Up>";
          action = "<cmd>res +5<CR>";
          options = {
            silent = true;
            noremap = true;
            desc = "Grow window horizontally";
          };
        }
        {
          mode = "n";
          key = "<C-Down>";
          action = "<cmd>res -5<CR>";
          options = {
            silent = true;
            noremap = true;
            desc = "Shrink window horizontally";
          };
        }
        # Quit commands
        {
          mode = "n";
          key = "<C-c>";
          action = "<cmd>quitall<CR>";
          options = {
            desc = "Quitall";
          };
        }
        {
          mode = "n";
          key = "<C-q>";
          action = "<cmd>q<CR>";
          options = {
            desc = "Quit";
          };
        }
        {
          mode = "i";
          key = "<C-q>";
          action = "<Esc><cmd>q<CR>";
          options = {
            desc = "Quit";
          };
        }

        # Save
        {
          mode = "n";
          key = "<A-w>";
          action = "<cmd>w<CR>";
          options = {
            desc = "Save";
          };
        }
        {
          mode = "i";
          key = "<A-w>";
          action = "<Esc><cmd>w<CR>";
          options = {
            desc = "Save";
          };
        }

        # Split windows
        {
          mode = "n";
          key = "\"";
          action = "<cmd>split<CR>";
          options = {
            silent = true;
            noremap = true;
            desc = "Split window horizontally";
          };
        }
        {
          mode = "n";
          key = "%";
          action = "<cmd>vsplit<CR>";
          options = {
            silent = true;
            noremap = true;
            desc = "Split window vertically";
          };
        }
      ];

      # Extra configuration
      extraConfigVim = ''
        " Open on last line before closed
        autocmd BufRead * autocmd FileType <buffer> ++once
          \ if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif
      '';

      extraConfigLua = ''
        local hooks = require "ibl.hooks"
        hooks.register(
          hooks.type.SCOPE_HIGHLIGHT,
          hooks.builtin.scope_highlight_from_extmark
        )
        -- Manually set % keymap until https://github.com/nix-community/nixvim/issues/4353 is resolved
        vim.keymap.set("n", "%%", "<Cmd>vsplit<CR>", {noremap = true, silent = true})
      '';
    };
  };
}
