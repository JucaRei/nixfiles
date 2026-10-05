_:
let
  # defaultFont = "Iosevka Comfy";
  default-Serif = "FiraGO"; # "Lato" # "Roboto"
  default-Mono = "FantasqueSansM Nerd Font Mono";
  default-Sans-serif = "Atkinson Hyperlegible";
in
{

  # override fonts
  "font.minimum-size.x-western" = 16;
  "font.size.fixed.x-western" = 20;
  "font.size.monospace.x-western" = 16;
  "font.size.variable.x-western" = 16;
  "font.name.monospace.x-western" = "${default-Mono}";
  "font.name.sans-serif.x-western" = "${default-Sans-serif}";
  "font.name.serif.x-western" = "${default-Serif}";
  # "browser.display.use_document_fonts" = 0; Disable site fonts
  "browser.display.use_document_fonts" = 1;
}
