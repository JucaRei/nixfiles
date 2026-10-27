# Template único de Style Scheme para GtkSourceView (gedit, meld, gnome-text-editor)
# Gerado dinamicamente a partir dos papéis semânticos de config.desktop.theme.colors.
{
  id,
  name,
  variant,
  colors,
}:
''
  <?xml version="1.0" encoding="UTF-8"?>
  <style-scheme id="${id}" _name="${name}" kind="${variant}">
    <_description>${name} theme for GtkSourceView</_description>

    <!-- Global Settings -->
    <style name="text" foreground="${colors.fg}" background="${colors.bg}"/>
    <style name="selection" foreground="${colors.fg}" background="${colors.surfaceAlt}"/>
    <style name="cursor" foreground="${colors.accent}"/>
    <style name="secondary-cursor" foreground="${colors.accent}"/>
    <style name="current-line" background="${colors.surface}"/>
    <style name="line-numbers" foreground="${colors.fgSubtle}" background="${colors.bgDark}"/>
    <style name="draw-spaces" foreground="${colors.fgSubtle}"/>
    <style name="background-pattern" background="${colors.bgDark}"/>

    <!-- Bracket Matching -->
    <style name="bracket-match" foreground="${colors.accent}" bold="true"/>
    <style name="bracket-mismatch" foreground="${colors.fg}" background="${colors.orange}"/>

    <!-- Right Margin -->
    <style name="right-margin" foreground="${colors.fgSubtle}" background="${colors.bgDark}"/>

    <!-- Search Matching -->
    <style name="search-match" foreground="${colors.bg}" background="${colors.blue}"/>

    <!-- Comments -->
    <style name="def:comment" foreground="${colors.fgMuted}" italic="true"/>
    <style name="def:shebang" foreground="${colors.fgMuted}" bold="true"/>
    <style name="def:doc-comment-element" italic="true"/>

    <!-- Constants -->
    <style name="def:constant" foreground="${colors.orange}"/>
    <style name="def:string" foreground="${colors.green}"/>
    <style name="def:special-char" foreground="${colors.purple}"/>
    <style name="def:special-constant" foreground="${colors.purple}"/>
    <style name="def:floating-point" foreground="${colors.orange}"/>

    <!-- Identifiers -->
    <style name="def:identifier" foreground="${colors.blue}"/>

    <!-- Statements -->
    <style name="def:statement" foreground="${colors.purple}" bold="true"/>

    <!-- Types -->
    <style name="def:type" foreground="${colors.yellow}" bold="true"/>

    <!-- Markup -->
    <style name="def:emphasis" italic="true"/>
    <style name="def:strong-emphasis" foreground="${colors.yellow}" bold="true"/>
    <style name="def:inline-code" foreground="${colors.green}"/>
    <style name="def:insertion" underline="single"/>
    <style name="def:deletion" strikethrough="true"/>
    <style name="def:link-text" foreground="${colors.accent}"/>
    <style name="def:link-symbol" foreground="${colors.blue}" bold="true"/>
    <style name="def:link-destination" foreground="${colors.blue}" italic="true" underline="single"/>
    <style name="def:heading" foreground="${colors.teal}" bold="true"/>
    <style name="def:thematic-break" foreground="${colors.green}" bold="true"/>
    <style name="def:preformatted-section" foreground="${colors.green}"/>
    <style name="def:list-marker" foreground="${colors.teal}" bold="true"/>

    <!-- Others -->
    <style name="def:preprocessor" foreground="${colors.teal}"/>
    <style name="def:error" foreground="${colors.red}" bold="true"/>
    <style name="def:warning" foreground="${colors.orange}"/>
    <style name="def:note" foreground="${colors.blue}" bold="true"/>
    <style name="def:net-address" italic="true" underline="single"/>
  </style-scheme>
''
