{ pkgs, config, lib }:
let
  inherit (lib) getExe;
in
{
  enable = false;
  package = pkgs.unstable.nano;
  syntaxHighlight = true;
  nanorc = ''
    set autoindent   # Auto indent
    set constantshow # Show cursor position at the bottom of the screen
    set fill 78      # Justify command (Ctrl+j) wraps at 78 columns
    set historylog   # Remember command history
    set multibuffer  # Allow opening multiple files (Alt+< and Alt+> to switch)
    set nohelp       # Remove the help bar from the bottom of the screen
    set nowrap       # Do not wrap text
    set quickblank   # Clear status messages after a single keystroke
    set regexp       # Enable regular expression mode for find (Ctrl+r to disable)
    set smarthome    # Home key jumps to first non-whitespace character
    set tabsize 2    # Insert 2 spaces per tab
    set tabstospaces # Tab key inserts spaces (Ctrl+t for verbatim mode)
    set numbercolor  blue,black
    set statuscolor  black,yellow
    set titlecolor   black,magenta
    include "${getExe config.programs.nano.package}/share/nano/extra/*.nanorc"
  '';
}
