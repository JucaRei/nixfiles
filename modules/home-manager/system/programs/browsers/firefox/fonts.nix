_:
let
  # defaultFont = "Iosevka Comfy";
  default-Serif = "Georgia"; # "Roboto"
  default-Mono = "Martian Mono Nerd Font";
  default-Sans-serif = "Fira Sans";
in
{

  # override fonts
  "font.minimum-size.x-western" = 16;
  "font.size.fixed.x-western" = 16;
  "font.size.monospace.x-western" = 16;
  "font.size.variable.x-western" = 16;
  "font.name.monospace.x-western" = "${default-Mono}";
  "font.name.sans-serif.x-western" = "${default-Sans-serif}";
  "font.name.serif.x-western" = "${default-Serif}";
  "browser.display.use_document_fonts" = 0;
}
