{
  config,
  lib,
  pkgs,
  font,
  ...
}: {
  home.packages = [
    pkgs.qutebrowser
    (pkgs.callPackage ./qute-containers.nix {dmenuCmd = "fuzzel -d";})
  ];
  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.qutebrowser}/bin/qutebrowser";
  };
  xdg.mimeApps.defaultApplications = {
    "text/html" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
  };
  home.file.".config/qutebrowser/userscripts/container-open".source = "${
    (pkgs.callPackage ./qute-containers.nix {dmenuCmd = "fuzzel -d";})
  }/bin/container-open";
  home.file.".config/qutebrowser/userscripts/containers_config".source = "${
    (pkgs.callPackage ./qute-containers.nix {dmenuCmd = "fuzzel -d";})
  }/bin/containers_config";

  programs.qutebrowser.enable = true;
  programs.qutebrowser.extraConfig =
    ''
      config.load_autoconfig(False)

      base00 = "#''
    + config.lib.stylix.colors.base00
    + ''
      "
      base01 = "#''
    + config.lib.stylix.colors.base01
    + ''
      "
      base02 = "#''
    + config.lib.stylix.colors.base02
    + ''
      "
      base03 = "#''
    + config.lib.stylix.colors.base03
    + ''
      "
      base04 = "#''
    + config.lib.stylix.colors.base04
    + ''
      "
      base05 = "#''
    + config.lib.stylix.colors.base05
    + ''
      "
      base06 = "#''
    + config.lib.stylix.colors.base06
    + ''
      "
      base07 = "#''
    + config.lib.stylix.colors.base07
    + ''
      "
      base08 = "#''
    + config.lib.stylix.colors.base08
    + ''
      "
      base09 = "#''
    + config.lib.stylix.colors.base09
    + ''
      "
      base0A = "#''
    + config.lib.stylix.colors.base0A
    + ''
      "
      base0B = "#''
    + config.lib.stylix.colors.base0B
    + ''
      "
      base0C = "#''
    + config.lib.stylix.colors.base0C
    + ''
      "
      base0D = "#''
    + config.lib.stylix.colors.base0D
    + ''
      "
      base0E = "#''
    + config.lib.stylix.colors.base0E
    + ''
      "
      base0F = "#''
    + config.lib.stylix.colors.base0F
    + ''
      "

      # TODO stylix user CSS
      # current_stylesheet_directory = '~/.config/qutebrowser/themes/'
      # current_stylesheet = base16_theme+'-all-sites.css'
      # current_stylesheet_path = current_stylesheet_directory + current_stylesheet
      # config.set('content.user_stylesheets', current_stylesheet_path)

      config.set('content.cookies.accept', 'no-3rdparty', 'chrome-devtools://*')
      config.set('content.cookies.accept', 'no-3rdparty', 'devtools://*')

      config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}; rv:90.0) Gecko/20100101 Firefox/90.0', 'https://accounts.google.com/*')
      config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99 Safari/537.36', 'https://*.slack.com/*')

      config.set('content.images', True, 'chrome-devtools://*')
      config.set('content.images', True, 'devtools://*')

      config.set('content.javascript.enabled', True, 'chrome-devtools://*')
      config.set('content.javascript.enabled', True, 'devtools://*')
      config.set('content.javascript.enabled', True, 'chrome://*/*')
      config.set('content.javascript.enabled', True, 'qute://*/*')
      c.tabs.favicons.scale = 1.0
      c.tabs.last_close = 'close'
      c.tabs.position = 'left'
      c.tabs.width = '3%'
      c.window.transparent = True
      c.colors.webpage.darkmode.enabled = True

      c.url.default_page = str(config.configdir)+'/qute-home.html'
      c.url.start_pages = str(config.configdir)+'/qute-home.html'

      c.url.searchengines = {'DEFAULT': 'https://startpage.com/do/search?query={}',
                             'd'   : 'https://duckduckgo.com/?q={}&ia=web',
                             'az'     : 'https://www.amazon.com/s?k={}',
                             'aw'     : 'https://wiki.archlinux.org/index.php?search={}&title=Special%3ASearch&wprov=acrw1',
                             'nw'     : 'https://nixos.wiki/index.php?search={}&go=Go',
                             'mn'     : 'https://mynixos.com/search?q={}',
                             'sb'     : 'https://www.serebii.net/search.shtml?q={}&sa=Search',
                             'bp'     : 'https://bulbapedia.bulbagarden.net/wiki/index.php?title=Special%3ASearch&search={}&go=Go'
                            }

      config.set('completion.open_categories',["searchengines","quickmarks","bookmarks"])

      config.bind('t', 'open -t')
      config.bind('x', 'tab-close')
      config.bind('yf', 'hint links yank')
      config.bind(',m', 'hint links spawn freetube {hint-url}')
      config.bind(',co', 'spawn container-open')
      config.bind(',cf', 'hint links userscript container-open')
      #config.bind(',s', 'set content.user_stylesheets \'\' ')
      #config.bind(',S', 'set content.user_stylesheets '+current_stylesheet_path)

      c.colors.completion.fg = base05
      c.colors.completion.odd.bg = base01
      c.colors.completion.even.bg = base00
      c.colors.completion.category.fg = base0A
      c.colors.completion.category.bg = base00
      c.colors.completion.category.border.top = base00
      c.colors.completion.category.border.bottom = base00
      c.colors.completion.item.selected.fg = base05
      c.colors.completion.item.selected.bg = base02
      c.colors.completion.item.selected.border.top = base02
      c.colors.completion.item.selected.border.bottom = base02
      c.colors.completion.item.selected.match.fg = base0B
      c.colors.completion.match.fg = base0B
      c.colors.completion.scrollbar.fg = base05
      c.colors.completion.scrollbar.bg = base00
      c.colors.contextmenu.disabled.bg = base01
      c.colors.contextmenu.disabled.fg = base04
      c.colors.contextmenu.menu.bg = base00
      c.colors.contextmenu.menu.fg =  base05
      c.colors.contextmenu.selected.bg = base02
      c.colors.contextmenu.selected.fg = base05
      c.colors.downloads.bar.bg = base00
      c.colors.downloads.start.fg = base00
      c.colors.downloads.start.bg = base0D
      c.colors.downloads.stop.fg = base00
      c.colors.downloads.stop.bg = base0C
      c.colors.downloads.error.fg = base08
      c.colors.hints.fg = base00
      c.colors.hints.bg = base0A
      c.colors.hints.match.fg = base05
      c.colors.keyhint.fg = base05
      c.colors.keyhint.suffix.fg = base05
      c.colors.keyhint.bg = base00
      c.colors.messages.error.fg = base00
      c.colors.messages.error.bg = base08
      c.colors.messages.error.border = base08
      c.colors.messages.warning.fg = base00
      c.colors.messages.warning.bg = base0E
      c.colors.messages.warning.border = base0E
      c.colors.messages.info.fg = base05
      c.colors.messages.info.bg = base00
      c.colors.messages.info.border = base00
      c.colors.prompts.fg = base05
      c.colors.prompts.border = base00
      c.colors.prompts.bg = base00
      c.colors.prompts.selected.bg = base02
      c.colors.prompts.selected.fg = base05
      c.colors.statusbar.normal.fg = base0B
      c.colors.statusbar.normal.bg = base00
      c.colors.statusbar.insert.fg = base00
      c.colors.statusbar.insert.bg = base0D
      c.colors.statusbar.passthrough.fg = base00
      c.colors.statusbar.passthrough.bg = base0C
      c.colors.statusbar.private.fg = base00
      c.colors.statusbar.private.bg = base01
      c.colors.statusbar.command.fg = base05
      c.colors.statusbar.command.bg = base00
      c.colors.statusbar.command.private.fg = base05
      c.colors.statusbar.command.private.bg = base00
      c.colors.statusbar.caret.fg = base00
      c.colors.statusbar.caret.bg = base0E
      c.colors.statusbar.caret.selection.fg = base00
      c.colors.statusbar.caret.selection.bg = base0D
      c.colors.statusbar.progress.bg = base0D
      c.colors.statusbar.url.fg = base05
      c.colors.statusbar.url.error.fg = base08
      c.colors.statusbar.url.hover.fg = base05
      c.colors.statusbar.url.success.http.fg = base0C
      c.colors.statusbar.url.success.https.fg = base0B
      c.colors.statusbar.url.warn.fg = base0E
      c.colors.tabs.bar.bg = base00
      c.colors.tabs.indicator.start = base0D
      c.colors.tabs.indicator.stop = base0C
      c.colors.tabs.indicator.error = base08
      c.colors.tabs.odd.fg = base05
      c.colors.tabs.odd.bg = base01
      c.colors.tabs.even.fg = base05
      c.colors.tabs.even.bg = base00
      c.colors.tabs.pinned.even.bg = base0C
      c.colors.tabs.pinned.even.fg = base07
      c.colors.tabs.pinned.odd.bg = base0B
      c.colors.tabs.pinned.odd.fg = base07
      c.colors.tabs.pinned.selected.even.bg = base02
      c.colors.tabs.pinned.selected.even.fg = base05
      c.colors.tabs.pinned.selected.odd.bg = base02
      c.colors.tabs.pinned.selected.odd.fg = base05
      c.colors.tabs.selected.odd.fg = base05
      c.colors.tabs.selected.odd.bg = base02
      c.colors.tabs.selected.even.fg = base05
      c.colors.tabs.selected.even.bg = base02
      c.colors.webpage.bg = base00

      font = "''
    + font
    + ''
      "

      c.fonts.default_family = font
      c.fonts.default_size = '14pt'

      c.fonts.web.family.standard = font
      c.fonts.web.family.serif = font
      c.fonts.web.family.sans_serif = font
      c.fonts.web.family.fixed = font
      c.fonts.web.family.fantasy = font
      c.fonts.web.family.cursive = font
    '';

  home.file.".config/qutebrowser/qute-home.html".text =
    ''
      <!DOCTYPE html>
      <html>

      <head>
        <title>Home</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          /*body*/
          body {
              background-color: #''
    + config.lib.stylix.colors.base00
    + ''

      }
      /*paragraphs*/
      p {
          font-family:''
    + font
    + ''
      ;

                  font-size:24px;
                  text-align:center;
                  color: #''
    + config.lib.stylix.colors.base08
    + ''
      ;

                  line-height: 1.35;
                  margin-top: 0;
                  margin-bottom: 0;
              }
              .open {
                color: #''
    + config.lib.stylix.colors.base09
    + ''
      ;
                font-weight: bold;
              }
              .quickmarks {
                color: #''
    + config.lib.stylix.colors.base0A
    + ''
      ;
                font-weight: bold;
              }
              .history {
                color: #''
    + config.lib.stylix.colors.base0B
    + ''
      ;
                font-weight: bold;
              }
              .newtab {
                color: #''
    + config.lib.stylix.colors.base0C
    + ''
      ;
                font-weight: bold;
              }
              .close {
                color: #''
    + config.lib.stylix.colors.base0D
    + ''
      ;
                font-weight: bold;
              }

              /*xmp tag style for ascii art*/
              xmp {
                  font-family:''
    + font
    + ''
      ;

                  font-size:22px;
                  color: #''
    + config.lib.stylix.colors.base01
    + ''

              text-align:center;
          }
          /*div*/
          div {
              margin:auto;
              width:50%;
              text-align:center;
          }
          /*class made for ascii art icon*/
          .icon {
              line-height:10%
          }
        </style>
      </head>

      <body>
        <!--start with cool qutebrowser ascii art-->
        <div class="icon">
             <xmp>       ..--------..        </xmp>
             <xmp>    .``            "'.     </xmp>
             <xmp>  .`  _.---.. /--|    '.   </xmp>
             <xmp>   /``      ||   |         </xmp>
             <xmp> /`  /--|   ||   |         </xmp>
             <xmp>/   /   |   ||   `/----\,  </xmp>
             <xmp>|   |   | .-`.-/- __.    \ </xmp>
             <xmp>|   \   `-.`` ..-`   \    |</xmp>
             <xmp>\    ````   ~.^` |    |   |</xmp>
             <xmp> \.____.-``'||   |   /   / </xmp>
             <xmp>        |   ||   |_.-   /  </xmp>
             <xmp>        |   ||         /   </xmp>
             <xmp>   .    |_-` `------~``.   </xmp>
             <xmp>    `..             ..`    </xmp>
             <xmp>       ``--______-'`       </xmp>
        </div>
        <br>
        <!--qutebrowser title-->
        <p style="color:#''
    + config.lib.stylix.colors.base01
    + ''
      ">Welcome to Qutebrowser</p>
            <br>
            <p><b>Personal Profile</b></p>
            <br>
            <!--basic keyboard commands-->
            <div>
              <p class="open"> [o] [Search] </p>
              <p class="quickmarks"> [b] [Quickmarks] </p>
              <p class="history"> [S h] [History] </p>
              <p class="newtab"> [t] [New tab] </p>
              <p class="close"> [x] [Close tab] </p>
            </div>
          </body>

          </html>

    '';

  home.file.".config/qutebrowser/containers".text = ''
    Teaching
    Tech
    Finances
    Gaming
    Gamedev
    Bard
  '';

  # TODO make this final section more efficient...

  home.file.".browser/Teaching/config/qute-home.html".text =
    ''
      <!DOCTYPE html>
      <html>

      <head>
        <title>Home</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          /*body*/
          body {
              background-color: #''
    + config.lib.stylix.colors.base00
    + ''

      }
      /*paragraphs*/
      p {
          font-family:''
    + font
    + ''
      ;

                font-size:24px;
                text-align:center;
                color: #''
    + config.lib.stylix.colors.base08
    + ''
      ;

                line-height: 1.35;
                margin-top: 0;
                margin-bottom: 0;
            }
            .open {
              color: #''
    + config.lib.stylix.colors.base09
    + ''
      ;
              font-weight: bold;
            }
            .quickmarks {
              color: #''
    + config.lib.stylix.colors.base0A
    + ''
      ;
              font-weight: bold;
            }
            .history {
              color: #''
    + config.lib.stylix.colors.base0B
    + ''
      ;
              font-weight: bold;
            }
            .newtab {
              color: #''
    + config.lib.stylix.colors.base0C
    + ''
      ;
              font-weight: bold;
            }
            .close {
              color: #''
    + config.lib.stylix.colors.base0D
    + ''
      ;
              font-weight: bold;
            }

            /*xmp tag style for ascii art*/
            xmp {
                font-family:''
    + font
    + ''
      ;

                font-size:22px;
                color: #''
    + config.lib.stylix.colors.base01
    + ''

              text-align:center;
          }
          /*div*/
          div {
              margin:auto;
              width:50%;
              text-align:center;
          }
          /*class made for ascii art icon*/
          .icon {
              line-height:10%
          }
        </style>
      </head>

      <body>
        <!--start with cool qutebrowser ascii art-->
        <div class="icon">
             <xmp>       ..--------..        </xmp>
             <xmp>    .``            "'.     </xmp>
             <xmp>  .`  _.---.. /--|    '.   </xmp>
             <xmp>   /``      ||   |         </xmp>
             <xmp> /`  /--|   ||   |         </xmp>
             <xmp>/   /   |   ||   `/----\,  </xmp>
             <xmp>|   |   | .-`.-/- __.    \ </xmp>
             <xmp>|   \   `-.`` ..-`   \    |</xmp>
             <xmp>\    ````   ~.^` |    |   |</xmp>
             <xmp> \.____.-``'||   |   /   / </xmp>
             <xmp>        |   ||   |_.-   /  </xmp>
             <xmp>        |   ||         /   </xmp>
             <xmp>   .    |_-` `------~``.   </xmp>
             <xmp>    `..             ..`    </xmp>
             <xmp>       ``--______-'`       </xmp>
        </div>
        <br>
        <!--qutebrowser title-->
        <p style="color:#''
    + config.lib.stylix.colors.base01
    + ''
      ">Welcome to Qutebrowser</p>
          <br>
          <p><b>Teaching Profile</b></p>
          <br>
          <!--basic keyboard commands-->
          <div>
            <p class="open"> [o] [Search] </p>
            <p class="quickmarks"> [b] [Quickmarks] </p>
            <p class="history"> [S h] [History] </p>
            <p class="newtab"> [t] [New tab] </p>
            <p class="close"> [x] [Close tab] </p>
          </div>
        </body>

        </html>

    '';

  home.file.".browser/Tech/config/qute-home.html".text =
    ''
      <!DOCTYPE html>
      <html>

      <head>
        <title>Home</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          /*body*/
          body {
              background-color: #''
    + config.lib.stylix.colors.base00
    + ''

      }
      /*paragraphs*/
      p {
          font-family:''
    + font
    + ''
      ;

                font-size:24px;
                text-align:center;
                color: #''
    + config.lib.stylix.colors.base08
    + ''
      ;

                line-height: 1.35;
                margin-top: 0;
                margin-bottom: 0;
            }
            .open {
              color: #''
    + config.lib.stylix.colors.base09
    + ''
      ;
              font-weight: bold;
            }
            .quickmarks {
              color: #''
    + config.lib.stylix.colors.base0A
    + ''
      ;
              font-weight: bold;
            }
            .history {
              color: #''
    + config.lib.stylix.colors.base0B
    + ''
      ;
              font-weight: bold;
            }
            .newtab {
              color: #''
    + config.lib.stylix.colors.base0C
    + ''
      ;
              font-weight: bold;
            }
            .close {
              color: #''
    + config.lib.stylix.colors.base0D
    + ''
      ;
              font-weight: bold;
            }

            /*xmp tag style for ascii art*/
            xmp {
                font-family:''
    + font
    + ''
      ;

                font-size:22px;
                color: #''
    + config.lib.stylix.colors.base01
    + ''

              text-align:center;
          }
          /*div*/
          div {
              margin:auto;
              width:50%;
              text-align:center;
          }
          /*class made for ascii art icon*/
          .icon {
              line-height:10%
          }
        </style>
      </head>

      <body>
        <!--start with cool qutebrowser ascii art-->
        <div class="icon">
             <xmp>       ..--------..        </xmp>
             <xmp>    .``            "'.     </xmp>
             <xmp>  .`  _.---.. /--|    '.   </xmp>
             <xmp>   /``      ||   |         </xmp>
             <xmp> /`  /--|   ||   |         </xmp>
             <xmp>/   /   |   ||   `/----\,  </xmp>
             <xmp>|   |   | .-`.-/- __.    \ </xmp>
             <xmp>|   \   `-.`` ..-`   \    |</xmp>
             <xmp>\    ````   ~.^` |    |   |</xmp>
             <xmp> \.____.-``'||   |   /   / </xmp>
             <xmp>        |   ||   |_.-   /  </xmp>
             <xmp>        |   ||         /   </xmp>
             <xmp>   .    |_-` `------~``.   </xmp>
             <xmp>    `..             ..`    </xmp>
             <xmp>       ``--______-'`       </xmp>
        </div>
        <br>
        <!--qutebrowser title-->
        <p style="color:#''
    + config.lib.stylix.colors.base01
    + ''
      ">Welcome to Qutebrowser</p>
          <br>
          <p><b>Tech Profile</b></p>
          <br>
          <!--basic keyboard commands-->
          <div>
            <p class="open"> [o] [Search] </p>
            <p class="quickmarks"> [b] [Quickmarks] </p>
            <p class="history"> [S h] [History] </p>
            <p class="newtab"> [t] [New tab] </p>
            <p class="close"> [x] [Close tab] </p>
          </div>
        </body>

        </html>

    '';

  home.file.".browser/Finances/config/qute-home.html".text =
    ''
      <!DOCTYPE html>
      <html>

      <head>
        <title>Home</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          /*body*/
          body {
              background-color: #''
    + config.lib.stylix.colors.base00
    + ''

      }
      /*paragraphs*/
      p {
          font-family:''
    + font
    + ''
      ;

                font-size:24px;
                text-align:center;
                color: #''
    + config.lib.stylix.colors.base08
    + ''
      ;

                line-height: 1.35;
                margin-top: 0;
                margin-bottom: 0;
            }
            .open {
              color: #''
    + config.lib.stylix.colors.base09
    + ''
      ;
              font-weight: bold;
            }
            .quickmarks {
              color: #''
    + config.lib.stylix.colors.base0A
    + ''
      ;
              font-weight: bold;
            }
            .history {
              color: #''
    + config.lib.stylix.colors.base0B
    + ''
      ;
              font-weight: bold;
            }
            .newtab {
              color: #''
    + config.lib.stylix.colors.base0C
    + ''
      ;
              font-weight: bold;
            }
            .close {
              color: #''
    + config.lib.stylix.colors.base0D
    + ''
      ;
              font-weight: bold;
            }

            /*xmp tag style for ascii art*/
            xmp {
                font-family:''
    + font
    + ''
      ;

                font-size:22px;
                color: #''
    + config.lib.stylix.colors.base01
    + ''

              text-align:center;
          }
          /*div*/
          div {
              margin:auto;
              width:50%;
              text-align:center;
          }
          /*class made for ascii art icon*/
          .icon {
              line-height:10%
          }
        </style>
      </head>

      <body>
        <!--start with cool qutebrowser ascii art-->
        <div class="icon">
             <xmp>       ..--------..        </xmp>
             <xmp>    .``            "'.     </xmp>
             <xmp>  .`  _.---.. /--|    '.   </xmp>
             <xmp>   /``      ||   |         </xmp>
             <xmp> /`  /--|   ||   |         </xmp>
             <xmp>/   /   |   ||   `/----\,  </xmp>
             <xmp>|   |   | .-`.-/- __.    \ </xmp>
             <xmp>|   \   `-.`` ..-`   \    |</xmp>
             <xmp>\    ````   ~.^` |    |   |</xmp>
             <xmp> \.____.-``'||   |   /   / </xmp>
             <xmp>        |   ||   |_.-   /  </xmp>
             <xmp>        |   ||         /   </xmp>
             <xmp>   .    |_-` `------~``.   </xmp>
             <xmp>    `..             ..`    </xmp>
             <xmp>       ``--______-'`       </xmp>
        </div>
        <br>
        <!--qutebrowser title-->
        <p style="color:#''
    + config.lib.stylix.colors.base01
    + ''
      ">Welcome to Qutebrowser</p>
          <br>
          <p><b>Finances Profile</b></p>
          <br>
          <!--basic keyboard commands-->
          <div>
            <p class="open"> [o] [Search] </p>
            <p class="quickmarks"> [b] [Quickmarks] </p>
            <p class="history"> [S h] [History] </p>
            <p class="newtab"> [t] [New tab] </p>
            <p class="close"> [x] [Close tab] </p>
          </div>
        </body>

        </html>

    '';

  home.file.".browser/Gamedev/config/qute-home.html".text =
    ''
      <!DOCTYPE html>
      <html>

      <head>
        <title>Home</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          /*body*/
          body {
              background-color: #''
    + config.lib.stylix.colors.base00
    + ''

      }
      /*paragraphs*/
      p {
          font-family:''
    + font
    + ''
      ;

                font-size:24px;
                text-align:center;
                color: #''
    + config.lib.stylix.colors.base08
    + ''
      ;

                line-height: 1.35;
                margin-top: 0;
                margin-bottom: 0;
            }
            .open {
              color: #''
    + config.lib.stylix.colors.base09
    + ''
      ;
              font-weight: bold;
            }
            .quickmarks {
              color: #''
    + config.lib.stylix.colors.base0A
    + ''
      ;
              font-weight: bold;
            }
            .history {
              color: #''
    + config.lib.stylix.colors.base0B
    + ''
      ;
              font-weight: bold;
            }
            .newtab {
              color: #''
    + config.lib.stylix.colors.base0C
    + ''
      ;
              font-weight: bold;
            }
            .close {
              color: #''
    + config.lib.stylix.colors.base0D
    + ''
      ;
              font-weight: bold;
            }

            /*xmp tag style for ascii art*/
            xmp {
                font-family:''
    + font
    + ''
      ;

                font-size:22px;
                color: #''
    + config.lib.stylix.colors.base01
    + ''

              text-align:center;
          }
          /*div*/
          div {
              margin:auto;
              width:50%;
              text-align:center;
          }
          /*class made for ascii art icon*/
          .icon {
              line-height:10%
          }
        </style>
      </head>

      <body>
        <!--start with cool qutebrowser ascii art-->
        <div class="icon">
             <xmp>       ..--------..        </xmp>
             <xmp>    .``            "'.     </xmp>
             <xmp>  .`  _.---.. /--|    '.   </xmp>
             <xmp>   /``      ||   |         </xmp>
             <xmp> /`  /--|   ||   |         </xmp>
             <xmp>/   /   |   ||   `/----\,  </xmp>
             <xmp>|   |   | .-`.-/- __.    \ </xmp>
             <xmp>|   \   `-.`` ..-`   \    |</xmp>
             <xmp>\    ````   ~.^` |    |   |</xmp>
             <xmp> \.____.-``'||   |   /   / </xmp>
             <xmp>        |   ||   |_.-   /  </xmp>
             <xmp>        |   ||         /   </xmp>
             <xmp>   .    |_-` `------~``.   </xmp>
             <xmp>    `..             ..`    </xmp>
             <xmp>       ``--______-'`       </xmp>
        </div>
        <br>
        <!--qutebrowser title-->
        <p style="color:#''
    + config.lib.stylix.colors.base01
    + ''
      ">Welcome to Qutebrowser</p>
          <br>
          <p><b>Gamedev Profile</b></p>
          <br>
          <!--basic keyboard commands-->
          <div>
            <p class="open"> [o] [Search] </p>
            <p class="quickmarks"> [b] [Quickmarks] </p>
            <p class="history"> [S h] [History] </p>
            <p class="newtab"> [t] [New tab] </p>
            <p class="close"> [x] [Close tab] </p>
          </div>
        </body>

        </html>

    '';

  home.file.".browser/Gaming/config/qute-home.html".text =
    ''
      <!DOCTYPE html>
      <html>

      <head>
        <title>Home</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          /*body*/
          body {
              background-color: #''
    + config.lib.stylix.colors.base00
    + ''

      }
      /*paragraphs*/
      p {
          font-family:''
    + font
    + ''
      ;

                font-size:24px;
                text-align:center;
                color: #''
    + config.lib.stylix.colors.base08
    + ''
      ;

                line-height: 1.35;
                margin-top: 0;
                margin-bottom: 0;
            }
            .open {
              color: #''
    + config.lib.stylix.colors.base09
    + ''
      ;
              font-weight: bold;
            }
            .quickmarks {
              color: #''
    + config.lib.stylix.colors.base0A
    + ''
      ;
              font-weight: bold;
            }
            .history {
              color: #''
    + config.lib.stylix.colors.base0B
    + ''
      ;
              font-weight: bold;
            }
            .newtab {
              color: #''
    + config.lib.stylix.colors.base0C
    + ''
      ;
              font-weight: bold;
            }
            .close {
              color: #''
    + config.lib.stylix.colors.base0D
    + ''
      ;
              font-weight: bold;
            }

            /*xmp tag style for ascii art*/
            xmp {
                font-family:''
    + font
    + ''
      ;

                font-size:22px;
                color: #''
    + config.lib.stylix.colors.base01
    + ''

              text-align:center;
          }
          /*div*/
          div {
              margin:auto;
              width:50%;
              text-align:center;
          }
          /*class made for ascii art icon*/
          .icon {
              line-height:10%
          }
        </style>
      </head>

      <body>
        <!--start with cool qutebrowser ascii art-->
        <div class="icon">
             <xmp>       ..--------..        </xmp>
             <xmp>    .``            "'.     </xmp>
             <xmp>  .`  _.---.. /--|    '.   </xmp>
             <xmp>   /``      ||   |         </xmp>
             <xmp> /`  /--|   ||   |         </xmp>
             <xmp>/   /   |   ||   `/----\,  </xmp>
             <xmp>|   |   | .-`.-/- __.    \ </xmp>
             <xmp>|   \   `-.`` ..-`   \    |</xmp>
             <xmp>\    ````   ~.^` |    |   |</xmp>
             <xmp> \.____.-``'||   |   /   / </xmp>
             <xmp>        |   ||   |_.-   /  </xmp>
             <xmp>        |   ||         /   </xmp>
             <xmp>   .    |_-` `------~``.   </xmp>
             <xmp>    `..             ..`    </xmp>
             <xmp>       ``--______-'`       </xmp>
        </div>
        <br>
        <!--qutebrowser title-->
        <p style="color:#''
    + config.lib.stylix.colors.base01
    + ''
      ">Welcome to Qutebrowser</p>
          <br>
          <p><b>Gaming Profile</b></p>
          <br>
          <!--basic keyboard commands-->
          <div>
            <p class="open"> [o] [Search] </p>
            <p class="quickmarks"> [b] [Quickmarks] </p>
            <p class="history"> [S h] [History] </p>
            <p class="newtab"> [t] [New tab] </p>
            <p class="close"> [x] [Close tab] </p>
          </div>
        </body>

        </html>

    '';

  home.file.".browser/Bard/config/qute-home.html".text =
    ''
      <!DOCTYPE html>
      <html>

      <head>
        <title>Home</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          /*body*/
          body {
              background-color: #''
    + config.lib.stylix.colors.base00
    + ''

      }
      /*paragraphs*/
      p {
          font-family:''
    + font
    + ''
      ;

                font-size:24px;
                text-align:center;
                color: #''
    + config.lib.stylix.colors.base08
    + ''
      ;

                line-height: 1.35;
                margin-top: 0;
                margin-bottom: 0;
            }
            .open {
              color: #''
    + config.lib.stylix.colors.base09
    + ''
      ;
              font-weight: bold;
            }
            .quickmarks {
              color: #''
    + config.lib.stylix.colors.base0A
    + ''
      ;
              font-weight: bold;
            }
            .history {
              color: #''
    + config.lib.stylix.colors.base0B
    + ''
      ;
              font-weight: bold;
            }
            .newtab {
              color: #''
    + config.lib.stylix.colors.base0C
    + ''
      ;
              font-weight: bold;
            }
            .close {
              color: #''
    + config.lib.stylix.colors.base0D
    + ''
      ;
              font-weight: bold;
            }

            /*xmp tag style for ascii art*/
            xmp {
                font-family:''
    + font
    + ''
      ;

                font-size:22px;
                color: #''
    + config.lib.stylix.colors.base01
    + ''

              text-align:center;
          }
          /*div*/
          div {
              margin:auto;
              width:50%;
              text-align:center;
          }
          /*class made for ascii art icon*/
          .icon {
              line-height:10%
          }
        </style>
      </head>

      <body>
        <!--start with cool qutebrowser ascii art-->
        <div class="icon">
             <xmp>       ..--------..        </xmp>
             <xmp>    .``            "'.     </xmp>
             <xmp>  .`  _.---.. /--|    '.   </xmp>
             <xmp>   /``      ||   |         </xmp>
             <xmp> /`  /--|   ||   |         </xmp>
             <xmp>/   /   |   ||   `/----\,  </xmp>
             <xmp>|   |   | .-`.-/- __.    \ </xmp>
             <xmp>|   \   `-.`` ..-`   \    |</xmp>
             <xmp>\    ````   ~.^` |    |   |</xmp>
             <xmp> \.____.-``'||   |   /   / </xmp>
             <xmp>        |   ||   |_.-   /  </xmp>
             <xmp>        |   ||         /   </xmp>
             <xmp>   .    |_-` `------~``.   </xmp>
             <xmp>    `..             ..`    </xmp>
             <xmp>       ``--______-'`       </xmp>
        </div>
        <br>
        <!--qutebrowser title-->
        <p style="color:#''
    + config.lib.stylix.colors.base01
    + ''
      ">Welcome to Qutebrowser</p>
          <br>
          <p><b>Bard Profile</b></p>
          <br>
          <!--basic keyboard commands-->
          <div>
            <p class="open"> [o] [Search] </p>
            <p class="quickmarks"> [b] [Quickmarks] </p>
            <p class="history"> [S h] [History] </p>
            <p class="newtab"> [t] [New tab] </p>
            <p class="close"> [x] [Close tab] </p>
          </div>
        </body>

        </html>

    '';
}
