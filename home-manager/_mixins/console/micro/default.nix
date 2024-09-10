{ config, lib, ... }:
with lib;
let
  cfg = config.custom.console.micro;
in
{
  options.custom.console.micro = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.micro = {
      enable = true;
      settings = {
        autoclose = true;
        autoindent = true;
        autosu = true;
        comment = true;
        colorscheme = "monokai";
        diffgutter = true;
        rmtrailingws = true;
        savecursor = true;
        saveundo = true;
        scrollbar = true;
        scrollbarchar = "░";
        backup = true;
        basename = false;
        colorcolumn = 0;
        cursorline = true;
        diff = true;
        encoding = "utf-8";
        eofnewline = true;
        fastdirty = true;
        fileformat = "unix";
        filetype = "unknown";
        ftoptions = true;
        hidehelp = false;
        ignorecase = false;
        indentchar = " ";
        infobar = true;
        keepautoindent = false;
        keymenu = false;
        linter = true;
        literate = true;
        matchbrace = false;
        matchbraceleft = false;
        mkparents = false;
        mouse = true;
        paste = false;
        pluginchannels = [
          "https://raw.githubusercontent.com/micro-editor/plugin-channel/master/channel.json"
        ];
        pluginrepos = [ ];
        readonly = false;
        ruler = true;
        savehistory = true;
        scrollmargin = 3;
        scrollspeed = 2;
        smartpaste = true;
        softwrap = false;
        splitbottom = true;
        splitright = true;
        status = true;
        statusline = true;
        sucmd = "sudo";
        syntax = true;
        tabmovement = false;
        tabsize = 4;
        tabstospaces = false;
        termtitle = false;
        useprimary = true;
      };
    };
  };
}
