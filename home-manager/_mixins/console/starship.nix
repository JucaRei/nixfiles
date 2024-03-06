{lib, ...}: let
  inherit (lib) mkDefault;
in {
  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "[]"
        "(fg:dark-blue)"
        "$username"
        "$hostname"
        "$os"
        "$nix_shell"
        "[]"
        "(fg:dark-blue bg:light-blue)"
        "$directory"
        "[]"
        "(fg:light-blue bg:purple)"
        "$git_branch"
        "$git_status"
        "[]"
        "(fg:purple bg:dark-blue)"
        "$rust"
        "[]"
        "(fg:dark-blue)"
        "$fill"
        "[]"
        "(fg:dark-blue)"
        "$cmd_duration"
        "[]"
        "(fg:purple bg:dark-blue)"
        "$jobs"
        "[]"
        "(fg:light-blue bg:purple)"
        "$status"
        "[]"
        "(fg:dark-blue bg:light-blue)"
        "$localip"
        "[]"
        "(fg:dark-blue)"
        "$line_break"
        ''

          $character''
      ];

      # Timeout for commands executed by starship (ms)
      command_timeout = 1000;

      aws = {
        format = "[$symbol($profile )(($region) )([$duration] )]($style)";
        # symbol = "🅰 ";
        symbol = mkDefault " ";
        style = "fg:pink bg:dark-blue";
        disabled = false;
        expiration_symbol = "X";
        force_display = false;
      };
      azure = {
        format = "[$symbol($subscription)([$duration])]($style) ";
        symbol = "ﴃ ";
        style = "fg:pink bg:dark-blue";
        disabled = true;
      };
      buf = {
        format = "[$symbol ($version)]($style)";
        version_format = "v$raw";
        symbol = "";
        style = "fg:pink bg:dark-blue";
        disabled = false;
        detect_extensions = [];
        detect_files = ["buf.yaml" "buf.gen.yaml" "buf.work.yaml"];
        detect_folders = [];
      };
      battery.full_symbol = mkDefault "";
      battery.charging_symbol = mkDefault "";
      battery.discharging_symbol = mkDefault "";
      battery.unknown_symbol = mkDefault "";
      battery.empty_symbol = mkDefault "";
      c = {
        format = "[$symbol($version(-$name) )]($style)";
        version_format = "v$raw";
        style = "fg:pink bg:dark-blue";
        symbol = " ";
        disabled = false;
        # detect_extensions = [
        #   "c"
        #   "h"
        # ];
        detect_files = [];
        detect_folders = [];
        # commands = [
        #   [
        #     "cc"
        #     "--version"
        #   ]
        #   [
        #     "gcc"
        #     "--version"
        #   ]
        #   [
        #     "clang"
        #     "--version"
        #   ]
        # ];
      };
      cmake = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault "△ ";
        style = "fg:pink bg:dark-blue";
        disabled = false;
        detect_extensions = [];
        detect_files = ["CMakeLists.txt" "CMakeCache.txt"];
        detect_folders = [];
      };
      conda = {
        truncation_length = 1;
        format = "[$symbol$environment]($style) ";
        symbol = mkDefault " ";
        style = "green bold";
        ignore_base = true;
        disabled = false;
      };
      container = {
        format = "[$symbol [$name]]($style) ";
        symbol = mkDefault "⬢";
        style = "red bold dimmed";
        disabled = false;
      };
      crystal = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault "🔮 ";
        style = "bold red";
        disabled = false;
        detect_extensions = ["cr"];
        detect_files = ["shard.yml"];
        detect_folders = [];
      };
      dart = {
        symbol = mkDefault " ";
        # symbol = "🎯 ";
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        style = "fg:pink bg:dark-blue";
        disabled = false;
        detect_extensions = ["dart"];
        detect_files = ["pubspec.yaml" "pubspec.yml" "pubspec.lock"];
        detect_folders = [".dart_tool"];
      };
      deno = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = "🦕 ";
        style = "green bold";
        disabled = false;
        detect_extensions = [];
        detect_files = ["deno.json" "deno.jsonc" "mod.ts" "deps.ts" "mod.js" "deps.js"];
        detect_folders = [];
      };
      #directory.read_only = mkDefault " ";
      docker_context = {
        format = "[$symbol$context]($style) ";
        symbol = mkDefault " ";
        style = "blue bold bg:0x06969A";
        only_with_files = true;
        disabled = false;
        detect_extensions = [];
        detect_files = ["docker-compose.yml" "docker-compose.yaml" "Dockerfile"];
        detect_folders = [];
      };
      dotnet = {
        format = "[$symbol($version )( $tfm )]($style)";
        symbol = mkDefault " ";
        version_format = "v$raw";
        style = "blue bold";
        heuristic = true;
        disabled = false;
        detect_extensions = ["csproj" "fsproj" "xproj"];
        detect_files = [
          "global.json"
          "project.json"
          "Directory.Build.props"
          "Directory.Build.targets"
          "Packages.props"
        ];
        detect_folders = [];
      };
      elixir = {
        format = "[$symbol($version (OTP $otp_version) )]($style)";
        style = "bold purple bg:0x86BBD8";
        symbol = mkDefault " ";
        disabled = false;
        detect_extensions = [];
        detect_files = ["mix.exs"];
        detect_folders = [];
      };
      elm = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        style = "cyan bold bg:0x86BBD8";
        symbol = mkDefault " ";
        disabled = false;
        detect_extensions = ["elm"];
        detect_files = ["elm.json" "elm-package.json" ".elm-version"];
        detect_folders = ["elm-stuff"];
      };
      env_var = {};
      env_var.SHELL = {
        format = "[$symbol($env_value )]($style)";
        style = "grey bold italic dimmed";
        symbol = "e:";
        disabled = true;
        variable = "SHELL";
        default = "unknown shell";
      };
      env_var.USER = {
        format = "[$symbol($env_value )]($style)";
        style = "grey bold italic dimmed";
        symbol = "e:";
        disabled = true;
        default = "unknown user";
      };
      erlang = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault " ";
        style = "bold red";
        disabled = false;
        detect_extensions = [];
        detect_files = ["rebar.config" "erlang.mk"];
        detect_folders = [];
      };
      fill = {
        style = "bold black";
        # symbol = ".";
        symbol = " ";
        disabled = false;
      };
      gcloud = {
        symbol = mkDefault " ";
        format = "[$symbol$account(@$domain)(($region))(($project))]($style) ";
        style = "fg:pink bg:dark-blue";
        disabled = false;
      };
      gcloud.project_aliases = {};
      gcloud.region_aliases = {};
      #git_branch.symbol = mkDefault " ";
      git_commit.tag_symbol = mkDefault " ";
      #git_status.format = mkDefault "([$all_status$ahead_behind]($style) )";
      #git_status.conflicted = mkDefault " ";
      #git_status.ahead = mkDefault " ";
      #git_status.behind = mkDefault " ";
      #git_status.diverged = mkDefault " ";
      #git_status.untracked = mkDefault " ";
      #git_status.stashed = mkDefault " ";
      #git_status.modified = mkDefault " ";
      #git_status.staged = mkDefault " ";
      #git_status.renamed = mkDefault " ";
      #git_status.deleted = mkDefault " ";
      golang = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault " ";
        style = "bold cyan bg:0x86BBD8";
        disabled = false;
        detect_extensions = ["go"];
        detect_files = [
          "go.mod"
          "go.sum"
          "glide.yaml"
          "Gopkg.yml"
          "Gopkg.lock"
          ".go-version"
        ];
        detect_folders = ["Godeps"];
      };
      haskell = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault "λ ";
        style = "bold purple bg:0x86BBD8";
        disabled = false;
        detect_extensions = ["hs" "cabal" "hs-boot"];
        detect_files = ["stack.yaml" "cabal.project"];
        detect_folders = [];
      };
      helm = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault "⎈ ";
        style = "bold white";
        disabled = false;
        detect_extensions = [];
        detect_files = ["helmfile.yaml" "Chart.yaml"];
        detect_folders = [];
      };
      hg_branch = {
        symbol = " ";
        style = "bold purple";
        format = "on [$symbol$branch]($style) ";
        truncation_length = 9223372036854775807;
        truncation_symbol = "…";
        disabled = true;
      };
      java = {
        disabled = false;
        format = "[$symbol($version )]($style)";
        style = "red dimmed bg:0x86BBD8";
        symbol = mkDefault " ";
        version_format = "v$raw";
        detect_extensions = ["java" "class" "jar" "gradle" "clj" "cljc"];
        detect_files = [
          "pom.xml"
          "build.gradle.kts"
          "build.sbt"
          ".java-version"
          "deps.edn"
          "project.clj"
          "build.boot"
        ];
        detect_folders = [];
      };
      julia = {
        disabled = false;
        format = "[$symbol($version )]($style)";
        style = "bold purple bg:0x86BBD8";
        symbol = mkDefault " ";
        version_format = "v$raw";
        detect_extensions = ["jl"];
        detect_files = ["Project.toml" "Manifest.toml"];
        detect_folders = [];
      };
      kotlin = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        # symbol = "🅺 ";
        symbol = mkDefault " ";
        style = "fg:pink bg:dark-blue";
        kotlin_binary = "kotlin";
        disabled = false;
        detect_extensions = ["kt" "kts"];
        detect_files = [];
        detect_folders = [];
      };
      kubernetes = {
        disabled = false;
        format = "[$symbol$context( ($namespace))]($style) in ";
        symbol = mkDefault "☸ ";
        style = "cyan bold";
      };
      kubernetes.context_aliases = {};
      lua = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        # symbol = "🌙 ";
        symbol = mkDefault " ";
        style = "fg:pink bg:dark-blue";
        lua_binary = "lua";
        disabled = false;
        detect_extensions = ["lua"];
        detect_files = [".lua-version"];
        detect_folders = ["lua"];
      };
      memory_usage.symbol = mkDefault " ";
      nim = {
        format = "[$symbol($version )]($style)";
        style = "yellow bold bg:0x86BBD8";
        symbol = mkDefault " ";
        version_format = "v$raw";
        disabled = false;
        detect_extensions = ["nim" "nims" "nimble"];
        detect_files = ["nim.cfg"];
        detect_folders = [];
      };
      nix_shell = {
        impure_msg = "[impure](bold red)";
        pure_msg = "[pure](bold green)";
        symbol = mkDefault " ";
        disabled = true;
      };
      nodejs = {
        format = "[$symbol($version )]($style)";
        not_capable_style = "bold red";
        style = "bold green bg:0x86BBD8";
        symbol = " ";
        version_format = "v$raw";
        disabled = false;
        detect_extensions = ["js" "mjs" "cjs" "ts" "mts" "cts"];
        detect_files = ["package.json" ".node-version" ".nvmrc"];
        detect_folders = ["node_modules"];
      };
      ocaml = {
        format = "[$symbol($version )(($switch_indicator$switch_name) )]($style)";
        global_switch_indicator = "";
        local_switch_indicator = "*";
        style = "bold yellow";
        symbol = "🐫 ";
        version_format = "v$raw";
        disabled = false;
        detect_extensions = ["opam" "ml" "mli" "re" "rei"];
        detect_files = ["dune" "dune-project" "jbuild" "jbuild-ignore" ".merlin"];
        detect_folders = ["_opam" "esy.lock"];
      };
      openstack = {
        format = "[$symbol$cloud(($project))]($style) ";
        symbol = "☁️  ";
        style = "bold yellow";
        disabled = false;
      };
      package = {
        format = "[$symbol$version]($style) ";
        symbol = mkDefault " ";
        style = "208 bold";
        display_private = false;
        disabled = false;
        version_format = "v$raw";
      };
      perl = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault " ";
        style = "149 bold";
        disabled = false;
        detect_extensions = ["pl" "pm" "pod"];
        detect_files = [
          "Makefile.PL"
          "Build.PL"
          "cpanfile"
          "cpanfile.snapshot"
          "META.json"
          "META.yml"
          ".perl-version"
        ];
        detect_folders = [];
      };
      php = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        style = "147 bold";
        symbol = mkDefault " ";
        disabled = false;
        detect_extensions = ["php"];
        detect_files = ["composer.json" ".php-version"];
        detect_folders = [];
      };
      pulumi = {
        format = "[$symbol($username@)$stack]($style) ";
        version_format = "v$raw";
        symbol = " ";
        style = "bold 5";
        disabled = false;
      };
      purescript = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = "<=> ";
        style = "bold white";
        disabled = false;
        detect_extensions = ["purs"];
        detect_files = ["spago.dhall"];
        detect_folders = [];
      };
      python = {
        format = "[$symbol$pyenv_prefix($version )(($virtualenv) )]($style)";
        python_binary = ["python" "python3" "python2"];
        pyenv_prefix = "pyenv ";
        pyenv_version_name = true;
        style = "yellow bold";
        symbol = mkDefault " ";
        version_format = "v$raw";
        disabled = false;
        detect_extensions = ["py"];
        detect_files = [
          "requirements.txt"
          ".python-version"
          "pyproject.toml"
          "Pipfile"
          "tox.ini"
          "setup.py"
          "__init__.py"
        ];
        detect_folders = [];
      };
      red = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = "🔺 ";
        style = "red bold";
        disabled = false;
        detect_extensions = ["red" "reds"];
        detect_files = [];
        detect_folders = [];
      };
      rlang = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        style = "blue bold";
        symbol = "📐 ";
        disabled = false;
        detect_extensions = ["R" "Rd" "Rmd" "Rproj" "Rsx"];
        detect_files = [".Rprofile"];
        detect_folders = [".Rproj.user"];
      };
      ruby = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault " ";
        style = "bold red";
        disabled = false;
        detect_extensions = ["rb"];
        detect_files = ["Gemfile" ".ruby-version"];
        detect_folders = [];
        detect_variables = ["RUBY_VERSION" "RBENV_VERSION"];
      };
      swift = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault " ";
        style = "bold 202";
        disabled = false;
        detect_extensions = ["swift"];
        detect_files = ["Package.swift"];
        detect_folders = [];
      };
      sudo = {
        format = "[as $symbol]($style)";
        symbol = "🧙 ";
        style = "fg:pink bg:dark-blue";
        allow_windows = false;
        disabled = true;
      };
      terraform = {
        format = "[$symbol$workspace]($style) ";
        version_format = "v$raw";
        # symbol = "💠 ";
        symbol = mkDefault "𝗧 ";
        style = "bold 105";
        disabled = false;
        detect_extensions = ["tf" "tfplan" "tfstate"];
        detect_files = [];
        detect_folders = [".terraform"];
      };
      vagrant = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        # symbol = "⍱ ";
        style = "cyan bold";
        disabled = false;
        detect_extensions = [];
        detect_files = ["Vagrantfile"];
        detect_folders = [];
        symbol = mkDefault "𝗩 ";
      };
      vlang = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = "V ";
        style = "blue bold";
        disabled = false;
        detect_extensions = ["v"];
        detect_files = ["v.mod" "vpkg.json" ".vpkg-lock.json"];
        detect_folders = [];
      };
      zig = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = mkDefault "↯ ";
        style = "bold yellow";
        disabled = false;
        detect_extensions = ["zig"];
        detect_files = [];
        detect_folders = [];
        # symbol = mkDefault " ";
      };

      # Bottom right only
      right_format = lib.concatStrings [
        "[](fg:purple)"
        "$memory_usage"
        "[](fg:pink bg:purple)"
        "$time"
        "[](fg:pink)"
      ];

      palette = "cyberpunk-neon";

      palettes.cyberpunk-neon = {
        dark-blue = "17";
        # blue =
        light-blue = "25";
        cyan = "44";
        pink = "201";
        purple = "13";
        red = "9";
        #orange = "208";
        white = "255";
        #yellow = "11";
        green = "#00FF00";
      };
      os = {
        disabled = false;
        # format = "[](fg:blue)[$symbol](bg:blue fg:black)[](fg:blue)";
        format = "$symbol";
      };
      os.symbols = {
        Arch = "[ ](fg:bright-blue)";
        Alpine = "[ ](fg:bright-blue)";
        Android = "[ ](fg:bright-green)";
        Debian = "[ ](fg:red)";
        EndeavourOS = "[ ](fg:purple)";
        Fedora = "[ ](fg:blue)";
        NixOS = "[ ](fg:bright-white)";
        openSUSE = "[ ](fg:green)";
        SUSE = "[ ](fg:green)";
        Ubuntu = "[ ](fg:bright-purple)";
      };

      # Upper left
      username = {
        show_always = true;
        style_user = "fg:pink bg:dark-blue";
        style_root = "fg:red bg:dark-blue";
        format = "[ $user]($style)[@]($style)";
      };

      hostname = {
        ssh_only = false;
        style = "fg:pink bg:dark-blue";
        format = "[$hostname ]($style)";
      };

      # Here is how you can shorten some long paths by text replacement
      directory = {
        home_symbol = "~";
        read_only = " ro";
        substitutions = {
          "Documents" = " ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
          "Important " = " ";
        };
        truncate_to_repo = true;
        truncation_symbol = "…/";
      };
      # Keep in mind that the order matters. For example:
      # "Important Documents" = "  "
      # will not be replaced, because "Documents" was already substituted before.
      # So either put "Important Documents" before "Documents" or use the substituted version:
      # "Important  " = " 
      git_branch = {
        symbol = "";
        style = "fg:green bg:purple";
        format = "[ $symbol $branch ]($style)";
        truncation_length = 9223372036854775807;
        truncation_symbol = "…";
        only_attached = false;
        always_show_remote = false;
        ignore_branches = [];
        disabled = false;
      };

      git_metrics = {
        added_style = "bold green";
        deleted_style = "bold red";
        only_nonzero_diffs = true;
        format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
        disabled = false;
      };

      git_state = {
        am = "AM";
        am_or_rebase = "AM/REBASE";
        bisect = "BISECTING";
        cherry_pick = "🍒PICKING(bold red)";
        disabled = false;
        format = "([$state( $progress_current/$progress_total)]($style)) ";
        merge = "MERGING";
        rebase = "REBASING";
        revert = "REVERTING";
        style = "bold yellow";
      };

      git_status = {
        conflicted = "=🏳$count";
        ahead = "🏎💨$count";
        behind = "⇣😰$count";
        diverged = "⇕⇣$behind_count⇡$ahead_count";
        untracked = "?🤷$count";
        ignore_submodules = false;
        stashed = " $count";
        modified = "!📝$count";
        staged = "+📦$count";
        renamed = "»$count";
        up_to_date = "✓";
        deleted = "✘🗑$count";
        style = "fg:green bg:purple";
        format = "[($all_status$ahead_behind )]($style)";
      };

      rust = {
        symbol = "";
        style = "fg:pink bg:dark-blue";
        format = "[ $symbol ($version) ]($style)";
        disabled = false;
        detect_extensions = ["rs"];
        detect_files = ["Cargo.toml"];
        detect_folders = [];
      };

      scala = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        disabled = false;
        style = "red bold";
        symbol = "🆂 ";
        detect_extensions = ["sbt" "scala"];
        detect_files = [".scalaenv" ".sbtenv" "build.sbt"];
        detect_folders = [".metals"];
      };

      shell = {
        format = "[$indicator]($style) ";
        bash_indicator = "bsh";
        cmd_indicator = "cmd";
        elvish_indicator = "esh";
        fish_indicator = "";
        ion_indicator = "ion";
        nu_indicator = "nu";
        powershell_indicator = "_";
        style = "white bold";
        tcsh_indicator = "tsh";
        unknown_indicator = "mystery shell";
        xonsh_indicator = "xsh";
        zsh_indicator = "zsh";
        disabled = false;
      };

      shlvl = {
        threshold = 2;
        format = "[$symbol$shlvl]($style) ";
        symbol = "  ";
        repeat = false;
        style = "bold yellow";
        disabled = true;
      };
      singularity = {
        format = "[$symbol[$env]]($style) ";
        style = "blue bold dimmed";
        symbol = "📦 ";
        disabled = false;
      };
      spack = {
        truncation_length = 1;
        format = "[$symbol$environment]($style) ";
        symbol = "🅢 ";
        style = "blue bold";
        disabled = false;
      };

      cobol = {
        format = "[$symbol($version )]($style)";
        version_format = "v$raw";
        symbol = "⚙️ ";
        style = "fg:pink bg:dark-blue";
        disabled = false;
        detect_extensions = ["cbl" "cob" "CBL" "COB"];
        detect_files = [];
        detect_folders = [];
      };

      # Upper right
      # cmd_duration = {
      #   min_time = 1000;
      #   format = "⏱ [$duration]($style) ";
      #   style = "yellow bold";
      #   show_milliseconds = true;
      #   disabled = false;
      # };

      nix_shell = {
        # disabled = false;
        format = "[](fg:white)[ ](bg:white fg:black)[](fg:white) ";
      };

      jobs = {
        style = "bold fg:cyan bg:purple";
        symbol = "";
        format = "[ $number$symbol ]($style)";
        threshold = 1;
        symbol_threshold = 0;
        number_threshold = 2;
        disabled = false;
      };

      status = {
        disabled = false;
        style = "bold fg:cyan bg:light-blue";
        symbol = "✘";
        not_executable_symbol = "";
        not_found_symbol = "";
        sigint_symbol = "";
        signal_symbol = "";
        map_symbol = true;
        format = "[ $common_meaning $status $symbol ]($style)";
      };

      localip = {
        disabled = false;
        ssh_only = false;
        style = "fg:pink bg:dark-blue";
        format = "[ $localipv4 ﯱ ]($style)";
      };

      # Lower right
      memory_usage = {
        disabled = false;
        threshold = 0;
        #symbol = "";
        style = "fg:cyan bg:purple";
        format = "[ $ram_pct $swap_pct $symbol ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%T"; # Hour:Minute:Second Format
        style = "fg:white bg:pink";
        format = "[ $time  ]($style)";
      };
      # git = {
      #   # Timeout for commands executed by starship (ms)
      #   command_timeout = 1000;
      # };
    };
    enableBashIntegration = true;
    enableZshIntegration = false;
    enableFishIntegration = false;
    enableIonIntegration = false;
    enableNushellIntegration = false;
  };
}
