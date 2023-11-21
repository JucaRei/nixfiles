# { pkgs, ... }: {
#   home = {
#    # packages = [ pkgs.neovim ];
#     packages = [ pkgs.neovim-unwrapped ];
#   };
#   programs.neovim = {
#     defaultEditor = false;
#     coc.settings = { };
#     viAlias = true;
#     vimAlias = true;
#     vimdiffAlias = true;
#     extraPackages = with pkgs; [ ];
#   };
# }

{ pkgs, nixvim, inputs, ... }: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  programs = {
    nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      options = {
        ### tab/indentation
        tabstop = 2; # sets the numbers of spaces of tab char
        shiftwidth = 2; # set the numbers of spaces of each number of indentation
        expandtab = true; # convert tabs into spaces
        softtabstop = 2; # insert mode how many spaces are in tab
        wrap = false; # long lines of code
        autoindent = true;
        # smartindent = true;

        ### Search
        incsearch =2 true; # incremental search
        ignorecase = true;
        smartcase = true; # when use capitalization to detect
        hlsearch = false;

        ### Appearence
        number = true;
        relativenumber = true;
        termguicolors = true; # full color on terminals
        # colorcolumn = "100"; # how many chars on line
        signcolumn = "yes"; # for debug
        cmdheight = 1;
        scrolloff = 10;
        completeopt = [ "menu" "menuone" "noselect" "noinsert" ];

        ### Behaviour
        hidden = true; # change buffers without saving
        errorbells = false;
        fileencoding = "utf-8";
        swapfile = false;
        backup = false;
        backspace = "indent,eol,start";
        splitright = true; # start spliting to right
        splitbelow = true;
        iskeyword = ":append('-')"; # ignore - and get full keyword
        mouse = ":append('a')"; # mouse is always available
        modifiable = true; # can edit the buffer you are in
        guicursor = "n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175";
      };

      colorschemes = {
        onedark.enable = true;
      };

      # clipboard = {
      #   register = "unnamedplus";
      #   providers.wl-copy.enable = true;
      # };

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      keymaps = [
        {
          key = "<C-s>";
          action = ":w<CR>";
          options.desc = "Save";
        }
        {
          key = "<F2>";
          action = ":Neotree toggle<CR>";
          options.desc = "Toggle NeoTree";
        }
        {
          key = "<F3>";
          action = ":UndotreeToggle<CR>";
          options.desc = "Toggle Undotree";
        }
        {
          key = "<leader><Left>";
          action = "<C-w>h";
          options.desc = "Select Window Left";
        }
        {
          key = "<leader>h";
          action = "<C-w>h";
          options.desc = "Select Window Left";
        }
        {
          key = "<leader><Right>";
          action = "<C-w>l";
          options.desc = "Select Window Right";
        }
        {
          key = "<leader>l";
          action = "<C-w>l";
          options.desc = "Select Window Right";
        }
        {
          key = "<leader>b";
          action = ":BufferLinePick<CR>";
          options.desc = "View Open Buffer";
        }
      ];

      plugins = {
        lualine.enable = true;
        bufferline.enable = true;
        gitgutter.enable = true;
        #which-key.enable = true;
        indent-blankline = {
          enable = true;
          scope.enabled = true;
        };
        lastplace.enable = true;
        fugitive.enable = true;
        markdown-preview.enable = true;
        nvim-autopairs.enable = true;
        telescope = {
          enable = true;
          keymaps = {
            "<leader>ff" = "find_files";
            "<leader>fg" = "live_grep";
            "<leader>fb" = "buffers";
            "<leader>fh" = "help_tags";
          };
        };
        neo-tree = {
          enable = true;
          window.width = 30;
        };
        undotree = {
          enable = true;
          focusOnToggle = true;
          highlightChangedText = true;
        };
        treesitter = {
          enable = true;
          nixvimInjections = true;
          folding = false;
          indent = true;
          incrementalSelection.enable = true;
        };
        treesitter-refactor = {
          enable = true;
        };
        nvim-colorizer.enable = true;
        neorg = {
          enable = true;
          modules = {
            "core.defaults" = { };
            "core.dirman".config.workspaces.home = "~/Documents/workspace";
            "core.completion".config.engine = "nvim-cmp";
            "core.norg.concealer" = { };
            "core.norg.journal" = { };
          };
        };
        # emmet.enable = true;
        luasnip.enable = true;
        cmp_luasnip.enable = true;
        lsp = {
          enable = true;
          servers = {
            nil_ls.enable = true;
            svelte.enable = true;
            html.enable = true;
            cssls.enable = true;
            tsserver.enable = true;
            pyright.enable = true;
            tailwindcss = {
              enable = true;
              filetypes = [
                "html"
                "js"
                "ts"
                "jsx"
                "tsx"
                "mdx"
                "svelte"
              ];
            };
          };
        };
        lspkind = {
          enable = true;
          cmp = {
            enable = true;
            menu = {
              nvim_lsp = "[LSP]";
              nvim_lua = "[api]";
              path = "[path]";
              luasnip = "[snip]";
              buffer = "[buffer]";
            };
          };
        };
        nvim-cmp = {
          enable = true;
          snippet.expand = "luasnip";
          mapping = {
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
            "<Tab>" = {
              modes = [ "i" "s" ];
              action = "cmp.mapping.select_next_item()";
            };
            "<S-Tab>" = {
              modes = [ "i" "s" ];
              action = "cmp.mapping.select_prev_item()";
            };
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
          sources = [
            { name = "path"; }
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            {
              name = "buffer";
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            }
            { name = "neorg"; }
          ];
        };
      };
    };
  };
}
