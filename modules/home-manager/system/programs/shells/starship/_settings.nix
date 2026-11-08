# Starship prompt configuration settings.
{
  lib,
  config,
  c,
}:
let
  inherit (lib) concatStrings;
in
{
  add_newline = false;
  command_timeout = 1000;

  palette = lib.mkIf config.desktop.theme.targets.starship "current_theme";

  palettes.current_theme = lib.mkIf config.desktop.theme.targets.starship {
    inherit (c)
      rosewater
      flamingo
      pink
      mauve
      red
      maroon
      peach
      yellow
      green
      teal
      sapphire
      sky
      blue
      lavender
      text
      subtext1
      subtext0
      overlay2
      overlay1
      overlay0
      surface2
      surface1
      surface0
      base
      mantle
      crust
      ;
  };

  time = {
    disabled = true;
  };

  format = concatStrings [
    "[](surface1)"
    "$os"
    "[](bg:surface2 fg:surface1)"
    "$username"
    "$sudo"
    "[](bg:overlay0 fg:surface2)"
    "$hostname"
    "[](bg:mauve fg:overlay0)"
    "$directory"
    "[](fg:mauve bg:peach)"
    "$c"
    "$dart"
    "$dotnet"
    "$elixir"
    "$elm"
    "$erlang"
    "$golang"
    "$haskell"
    "$haxe"
    "$java"
    "$julia"
    "$kotlin"
    "$lua"
    "$nim"
    "$nodejs"
    "$rlang"
    "$ruby"
    "$rust"
    "$perl"
    "$php"
    "$python"
    "$scala"
    "$swift"
    "$zig"
    "$package"
    "$git_branch"
    "[](fg:peach bg:yellow)"
    "$git_status"
    "[](fg:yellow bg:teal)"
    "$container"
    "$direnv"
    "$nix_shell"
    "$cmd_duration"
    "$jobs"
    "$shlvl"
    "$status"
    "$character"
  ];

  os = {
    disabled = false;
    format = "$symbol";
    style = "";
  };

  os.symbols = {
    AlmaLinux = "[ ](fg:text bg:surface1)";
    Alpine = "[ ](fg:blue bg:surface1)";
    Amazon = "[ ](fg:peach bg:surface1)";
    Android = "[ ](fg:green bg:surface1)";
    Arch = "[󰣇 ](fg:blue bg:surface1)";
    CentOS = "[ ](fg:mauve bg:surface1)";
    Debian = "[ ](fg:red bg:surface1)";
    EndeavourOS = "[ ](fg:mauve bg:surface1)";
    Fedora = "[ ](fg:blue bg:surface1)";
    FreeBSD = "[ ](fg:red bg:surface1)";
    Garuda = "[󰛓 ](fg:teal bg:surface1)";
    Gentoo = "[ ](fg:lavender bg:surface1)";
    HardenedBSD = "[󰞌 ](fg:yellow bg:surface1)";
    Illumos = "[󰈸 ](fg:peach bg:surface1)";
    Linux = "[ ](fg:yellow bg:surface1)";
    Mabox = "[󰞌 ](fg:green bg:surface1)";
    Macos = "[ ](fg:text bg:surface1)";
    Manjaro = "[ ](fg:green bg:surface1)";
    Mariner = "[ ](fg:blue bg:surface1)";
    MidnightBSD = "[ ](fg:teal bg:surface1)";
    Mint = "[󰣭 ](fg:teal bg:surface1)";
    NetBSD = "[ ](fg:peach bg:surface1)";
    NixOS = "[ ](fg:blue bg:surface1)";
    OpenBSD = "[ ](fg:yellow bg:surface1)";
    OpenCloudOS = "[ ](fg:blue bg:surface1)";
    openEuler = "[ ](fg:green bg:surface1)";
    openSUSE = "[ ](fg:green bg:surface1)";
    OracleLinux = "[󰌷 ](fg:red bg:surface1)";
    Pop = "[ ](fg:teal bg:surface1)";
    Raspbian = "[ ](fg:maroon bg:surface1)";
    Redhat = "[󱄛 ](fg:red bg:surface1)";
    RedHatEnterprise = "[󱄛 ](fg:red bg:surface1)";
    Redox = "[󰞌 ](fg:yellow bg:surface1)";
    Solus = "[ ](fg:blue bg:surface1)";
    SUSE = "[ ](fg:green bg:surface1)";
    Ubuntu = "[ ](fg:peach bg:surface1)";
    Unknown = "[ ](fg:subtext0 bg:surface1)";
    Windows = "[ ](fg:blue bg:surface1)";
  };

  username = {
    disabled = false;
    format = "[ $user ]($style)";
    show_always = true;
    style_root = "fg:red bg:surface2";
    style_user = "fg:yellow bg:surface2";
  };

  sudo = {
    disabled = false;
    format = "[as $symbol]($style)";
    style = "bold italic fg:surface1 bg:surface2";
    symbol = "🧙 ";
  };

  hostname = {
    disabled = false;
    format = "[ $hostname ]($style)";
    ssh_only = false;
    style = "fg:teal bg:overlay0";
    trim_at = ".";
  };

  directory = {
    disabled = false;
    format = "[ $path ]($style)";
    home_symbol = " ~";
    read_only = " 󰌾";
    read_only_style = "fg:red bg:mauve";
    style = "fg:base bg:mauve";
    substitutions = {
      "~" = " ~";
      "~/Development" = " ";
      "~/Documents" = "󰈙 ";
      "~/Downloads" = " ";
      "~/Music" = " ";
      "~/Pictures" = " ";
    };
    truncation_length = 3;
    truncation_symbol = "…/";
  };

  git_branch = {
    format = "[ $symbol$branch(:$remote_branch) ]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  git_status = {
    format = "([ $all_status$ahead_behind]($style))";
    style = "fg:base bg:yellow";
  };

  package = {
    format = "[ $symbol$version ]($style)";
    style = "fg:base bg:peach";
    symbol = "󰏗 ";
  };

  c = {
    format = "[ $symbol($version(-$clang_version) )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  dart = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  dotnet = {
    format = "[ $symbol($version )(🎯 $tfm )]($style)";
    style = "fg:base bg:peach";
    symbol = "󰌛 ";
  };

  elixir = {
    format = "[ $symbol($version \(OTP $otp_version\) )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  elm = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  erlang = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  golang = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  haskell = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  haxe = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  java = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  julia = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  kotlin = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  lua = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  nim = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = "󰆥 ";
  };

  nodejs = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  perl = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  php = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  python = {
    format = "[ $symbol$pyenv_prefix($version )(\($virtualenv\) )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  rlang = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = "󰟔 ";
  };

  ruby = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  rust = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = "󱘗 ";
  };

  scala = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  swift = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  zig = {
    format = "[ $symbol($version )]($style)";
    style = "fg:base bg:peach";
    symbol = " ";
  };

  container = {
    format = "[ $symbol $name ]($style)";
    style = "fg:base bg:teal";
    symbol = "󰏖 ";
  };

  direnv = {
    allowed_msg = "";
    denied_msg = "󱥸";
    disabled = false;
    format = "[ $symbol$loaded/$allowed ]($style)";
    loaded_msg = "󱥹";
    not_allowed_msg = "󱥸";
    style = "fg:base bg:teal";
    symbol = " ";
    unloaded_msg = "";
  };

  nix_shell = {
    format = "[ $symbol ]($style)";
    style = "fg:base bg:teal";
    symbol = " ";
  };

  cmd_duration = {
    format = "[ ⏱ $duration]($style)";
    min_time = 2500;
    min_time_to_notify = 60000;
    show_notifications = false;
    style = "fg:base bg:teal";
  };

  jobs = {
    format = "[ $symbol $number]($style)";
    style = "fg:base bg:teal";
    symbol = "󰈔";
  };

  shlvl = {
    disabled = false;
    format = "[ $symbol]($style)";
    repeat = false;
    style = "fg:surface1 bg:teal";
    symbol = "↕";
    threshold = 3;
  };

  status = {
    disabled = false;
    format = "$symbol";
    map_symbol = true;
    pipestatus = false;
    style = "";
    symbol = "[](fg:teal bg:pink)[ ✖ $status](fg:red bg:pink)";
    success_symbol = "[](fg:teal bg:blue)";
    not_executable_symbol = "[](fg:teal bg:pink)[ 🚫 $common_meaning](fg:red bg:pink)";
    not_found_symbol = "[](fg:teal bg:pink)[ 🔍 $common_meaning](fg:red bg:pink)";
    sigint_symbol = "[](fg:teal bg:pink)[ 🛑 $signal_name](fg:red bg:pink)";
    signal_symbol = "[](fg:teal bg:pink)[ ⚡ $signal_name](fg:red bg:pink)";
  };

  character = {
    disabled = false;
    format = "$symbol";
    error_symbol = "[](fg:red bg:pink)[](fg:pink) ";
    success_symbol = "[](fg:blue) ";
  };
}
