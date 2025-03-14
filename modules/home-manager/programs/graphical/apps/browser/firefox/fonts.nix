_:
let
  # defaultFont = "Iosevka Comfy";
  defaultFont1 = "Roboto";
  defaultFont2 = "FiraCode Nerd Font Mono";
  defaultFont3 = "Fira Sans";
in
{
  # override fonts
  "font.minimum-size.x-western" = 12;
  "font.size.fixed.x-western" = 16;
  "font.size.monospace.x-western" = 16;
  "font.size.variable.x-western" = 16;
  "font.name.monospace.x-western" = "${defaultFont2}";
  "font.name.sans-serif.x-western" = "${defaultFont3}";
  "font.name.serif.x-western" = "${defaultFont1}";
  "browser.display.use_document_fonts" = 0;
}
