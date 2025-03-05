_:
let
  # defaultFont = "Iosevka Comfy";
  defaultFont = "Merriweather";
in
{
  # override fonts
  "font.minimum-size.x-western" = 12;
  "font.size.fixed.x-western" = 16;
  "font.size.monospace.x-western" = 16;
  "font.size.variable.x-western" = 16;
  "font.name.monospace.x-western" = "${defaultFont}";
  "font.name.sans-serif.x-western" = "${defaultFont}";
  "font.name.serif.x-western" = "${defaultFont}";
  "browser.display.use_document_fonts" = 0;
}
