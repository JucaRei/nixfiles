{ config, pkgs, ... }:
{

  # see https://editorconfig.org/ for settings and their meaning

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
      };
      "*.nix" = {
        indent_style = "space";
        indent_size = 2;
      };
      "*.fish" = {
        indent_style = "space";
        indent_size = 4;
      };
    };
  };

}
