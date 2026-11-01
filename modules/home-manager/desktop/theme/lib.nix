# Helper functions for color manipulation and theme generation.
# Usado por hyprland, mangowm, bspwm, bat, etc.
{ lib }:
let
  stripHash =
    hex:
    if lib.hasPrefix "#" hex then builtins.substring 1 (builtins.stringLength hex - 1) hex else hex;

  hexDigits = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
    "A" = 10;
    "B" = 11;
    "C" = 12;
    "D" = 13;
    "E" = 14;
    "F" = 15;
  };

  hexToDec =
    hex:
    let
      h = stripHash hex;
      len = builtins.stringLength h;
    in
    if len == 2 then
      (hexDigits.${builtins.substring 0 1 h} * 16 + hexDigits.${builtins.substring 1 1 h})
    else if len == 1 then
      hexDigits.${h}
    else
      0;

  hexToTuple =
    hex:
    let
      h = stripHash hex;
    in
    [
      (hexToDec (builtins.substring 0 2 h))
      (hexToDec (builtins.substring 2 2 h))
      (hexToDec (builtins.substring 4 2 h))
    ];

  hexToRgb =
    hex:
    let
      t = hexToTuple hex;
    in
    {
      r = builtins.elemAt t 0;
      g = builtins.elemAt t 1;
      b = builtins.elemAt t 2;
    };

  withAlpha = hex: alpha: "${stripHash hex}${stripHash (toString alpha)}";

  # Hyprland format: rgb(rrggbb)
  rgb = hex: "rgb(${stripHash hex})";

  # Hyprland format: rgba(rrggbbaa)
  rgba = hex: alpha: "rgba(${withAlpha hex alpha})";

  # CSS format: rgb(r, g, b)
  cssRgb =
    hex:
    let
      t = hexToTuple hex;
    in
    "rgb(${toString (builtins.elemAt t 0)}, ${toString (builtins.elemAt t 1)}, ${toString (builtins.elemAt t 2)})";

  # CSS format: rgba(r, g, b, a)
  cssRgba =
    hex: alpha:
    let
      t = hexToTuple hex;
    in
    "rgba(${toString (builtins.elemAt t 0)}, ${toString (builtins.elemAt t 1)}, ${toString (builtins.elemAt t 2)}, ${toString alpha})";

  # MangoWM format: 0xrrggbbaa
  hexTo0x = hex: alpha: "0x${withAlpha hex alpha}";

  # Gera especificação TextMate .tmTheme (usado por bat e editores baseados em TextMate)
  generateTmTheme =
    {
      name ? "Generated",
      colors,
    }:
    let
      c = colors;
      norm = hex: if lib.hasPrefix "#" hex then hex else "#${hex}";
    in
    ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>name</key>
          <string>${name}</string>
          <key>settings</key>
          <array>
            <dict>
              <key>settings</key>
              <dict>
                <key>background</key>
                <string>${norm c.bg}</string>
                <key>foreground</key>
                <string>${norm c.fg}</string>
                <key>caret</key>
                <string>${norm c.accent}</string>
                <key>invisibles</key>
                <string>${norm c.fgSubtle}</string>
                <key>gutterForeground</key>
                <string>${norm c.fgSubtle}</string>
                <key>lineHighlight</key>
                <string>${norm c.surface}</string>
                <key>selection</key>
                <string>${norm c.surfaceAlt}</string>
                <key>selectionBorder</key>
                <string>${norm c.border}</string>
                <key>findHighlight</key>
                <string>${norm c.yellow}</string>
                <key>findHighlightForeground</key>
                <string>${norm c.bgDark}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Comment</string>
              <key>scope</key>
              <string>comment, punctuation.definition.comment</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.fgMuted}</string>
                <key>fontStyle</key>
                <string>italic</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>String</string>
              <key>scope</key>
              <string>string, punctuation.definition.string</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.green}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Number and Constant</string>
              <key>scope</key>
              <string>constant.numeric, constant.language, constant.character, constant.other</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.orange}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Keyword and Storage</string>
              <key>scope</key>
              <string>keyword, storage, storage.type</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.purple}</string>
                <key>fontStyle</key>
                <string>bold</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Function</string>
              <key>scope</key>
              <string>entity.name.function, support.function</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.blue}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Type and Class</string>
              <key>scope</key>
              <string>entity.name.type, entity.name.class, support.class, support.type</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.yellow}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Tag and HTML</string>
              <key>scope</key>
              <string>entity.name.tag, meta.tag</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.red}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Operator</string>
              <key>scope</key>
              <string>keyword.operator</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.cyan}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Punctuation</string>
              <key>scope</key>
              <string>punctuation</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.fgSubtle}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Diff Inserted</string>
              <key>scope</key>
              <string>markup.inserted</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.green}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Diff Deleted</string>
              <key>scope</key>
              <string>markup.deleted</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.red}</string>
              </dict>
            </dict>
            <dict>
              <key>name</key>
              <string>Diff Changed</string>
              <key>scope</key>
              <string>markup.changed</string>
              <key>settings</key>
              <dict>
                <key>foreground</key>
                <string>${norm c.yellow}</string>
              </dict>
            </dict>
          </array>
        </dict>
      </plist>
    '';
in
{
  inherit
    stripHash
    hexToDec
    hexToTuple
    hexToRgb
    withAlpha
    rgb
    rgba
    cssRgb
    cssRgba
    hexTo0x
    generateTmTheme
    ;
}
