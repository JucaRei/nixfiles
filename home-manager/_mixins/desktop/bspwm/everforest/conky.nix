{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      conky
      lua
      jq
      wirelesstools

      #Fonts
      dosis
      roboto
      bebasNeue
      feather
      abel
    ];

    file = {
      "${config.xdg.configHome}/conky/Regulus/Regulus.conf" = {
        text = ''
          conky.config = {
          --==============================================================================

          -- Size and Position settings --
            alignment = 'top_right',
            gap_x = 20,
            gap_y = 0,
            maximum_width = 300,
            minimum_height = 600,
            minimum_width = 300,

          -- Text settings --
            use_xft = true,
            override_utf8_locale = true,
            font = 'Roboto:light:size=9',

          -- Color Settings --
            default_color = '#f9f9f9',
            default_outline_color = 'white',
            default_shade_color = 'white',
            color1 = '1E90FF',
            color2 = 'CF1C61',

          -- Window Settings --
            background = false,
            border_width = 1,
            draw_borders = false,
            draw_graph_borders = false,
            draw_outline = false,
            draw_shades = false,
            own_window = true,
            own_window_colour = '000000',
            own_window_class = 'Conky',
            draw_blended = false,
            own_window_argb_visual = false,
            own_window_type = 'desktop',
            own_window_transparent = true,
            own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
            stippled_borders = 0,

          -- Others --
            cpu_avg_samples = 2,
            net_avg_samples = 1,
            double_buffer = true,
            out_to_console = false,
            out_to_stderr = false,
            extra_newline = false,
            update_interval = 1,
            uppercase = false,
            use_spacer = 'none',
            show_graph_scale = false,
            show_graph_range = false,
            lua_load = '~/.config/conky/Regulus/scripts/rings-v1.2.1.lua',
            lua_draw_hook_pre = 'ring_stats',
          }

          conky.text = [[
          $\{execi 100 ~/.config/conky/Regulus/scripts/weather-v2.0.sh}\
          $\{image ~/.config/conky/Regulus/res/Box1.png -s 140x140 -p 150,10}\
          $\{image ~/.config/conky/Regulus/res/Box.png -s 140x140 -p 150,165}\
          $\{image ~/.config/conky/Regulus/res/Box.png -s 140x140 -p 150,320}\
          $\{offset 0}$\{voffset 0}$\{color}$\{font Bebas Neue:size=110}$\{time %H}$\{font}
          $\{offset  235}$\{voffset -59}$\{color}$\{font Abel:size=8}System :$\{font}
          $\{offset  235}$\{voffset -5}$\{color1}$\{font Abel:bold:size=9}$\{fs_used_perc /}%$\{font}
          $\{offset  235}$\{voffset -2}$\{color}$\{font Abel:size=8}Home :$\{font}
          $\{offset  235}$\{voffset -5}$\{color1}$\{font Abel:bold:size=9}$\{fs_used_perc /home}%$\{font}
          $\{offset 0}$\{voffset -10}$\{color}$\{font Bebas Neue:size=110}$\{time %M}$\{font}
          $\{alignc 90}$\{voffset 15}$\{color}$\{font Bebas Neue:size=16}$\{time %^A}
          $\{alignc 90}$\{voffset 0}$\{color}$\{font Bebas Neue:size=16}$\{time %d / %b / %Y}$\{font}
          $\{offset 165}$\{voffset -160}$\{font feather:size=25}$\{execi 15 ~/.config/conky/Regulus/scripts/weather-text-icon}$\{goto 220}$\{font Bebas Neue:size=25}$\{execi 100 cat ~/.cache/weather.json | jq '.main.temp' | awk '{print int($1+0.5)}'}°C$\{font}
          $\{offset 165}$\{voffset -2}$\{color}$\{font Abel:size=10}............
          $\{offset 165}$\{voffset 0}$\{color1}$\{font Abel:bold:size=13}$\{execi 100 cat ~/.cache/weather.json | jq -r '.name'}$\{font}
          $\{offset 165}$\{voffset 0}$\{color}$\{font Abel:size=11}$\{execi 100 cat ~/.cache/weather.json | jq -r '.weather[0].description' | sed "s|\<.|\U&|g"}$\{font}
          $\{offset 165}$\{voffset 0}$\{color}$\{font Abel:size=8}Wind speed : $\{execi 100 (cat ~/.cache/weather.json | jq '.wind.speed')} m/s
          $\{offset 165}$\{voffset 0}$\{color}$\{font Abel:size=8}Humidity : $\{execi 100 (cat ~/.cache/weather.json | jq '.main.humidity')}%
          $\{offset 165}$\{voffset 34}$\{font Feather:size=9}$\{font Abel:bold:size=8}: $\{execi 5 ~/.config/conky/Regulus/scripts/ssid}
          $\{offset 165}$\{voffset 2}$\{font Abel:size=8}Downspeed : $\{downspeed wlan0}
          $\{offset 165}$\{voffset 0}$\{downspeedgraph wlan0 24,107 CF1C61 1E90FF}
          $\{offset 165}$\{voffset -3}$\{color}$\{font Abel:size=8}Upspeed : $\{upspeed wlan0}
          $\{offset 165}$\{voffset 0}$\{upspeedgraph wlan0 24,107 CF1C61 1E90FF}
          $\{color}$\{alignr 13}$\{voffset 25}$\{font Abel:bold:size=11}$\{exec playerctl status}
          $\{color2}$\{alignr 13}$\{voffset 0}$\{font Dosis:bold:size=24}$\{exec ~/.config/conky/Regulus/scripts/playerctl.sh}$\{font}
          $\{color}$\{alignr 13}$\{voffset 4}$\{if_running mpd}$\{font Feather:size=13} $\{font Abel:size=12}$\{exec playerctl metadata xesam:artist}$\{font}
          ]]
        '';
      };
      "${config.xdg.configHome}/conky/Regulus/res" = {
        source = ../../../config/conky/regulus/res;
        recursive = true;
      };
      "${config.xdg.configHome}/conky/Regulus/scripts/rings-v1.2.1.lua" = {
        text =
          ''
              settings_table = {
                {
                  name='cpu',
                  arg='cpu0',
                  max=100,
                  bg_colour=0x1E90FF,
                  bg_alpha=0.2,
                  fg_colour=0x1E90FF,
                  fg_alpha=0.8,
                  x=195, y=53,
                  radius=24,
                  thickness=6,
                  start_angle=0,
                  end_angle=360,
                },
                {
                  name='memperc',
                  arg=''',
                  max=100,
                  bg_colour=0x1E90FF,
                  bg_alpha=0.2,
                  fg_colour=0x1E90FF,
                  fg_alpha=0.8,
                  x=255, y=53,
                  radius=24,
                  thickness=6,
                  start_angle=0,
                  end_angle=360
                },
                {
                  name='fs_used_perc',
                  arg='/',
                  max=100,
                  bg_colour=0x1E90FF,
                  bg_alpha=0.2,
                  fg_colour=0x1E90FF,
                  fg_alpha=0.8,
                  x=195, y=117,
                  radius=24,
                  thickness=6,
                  start_angle=0,
                  end_angle=360
                },
                {
                  name='fs_used_perc',
                  arg='/home',
                  max=100,
                  bg_colour=0x1E90FF,
                  bg_alpha=0.2,
                  fg_colour=0x1E90FF,
                  fg_alpha=0.8,
                  x=195, y=117,
                  radius=15,
                  thickness=6,
                  start_angle=0,
                  end_angle=360,
                },
              }

              require 'cairo'

              function rgb_to_r_g_b(colour,alpha)
                  return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
              end

              function draw_ring(cr,t,pt)
                  local w,h=conky_window.width,conky_window.height

                  local
                  xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
                  local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

                  local angle_0=sa*(2*math.pi/360)-math.pi/2
                  local angle_f=ea*(2*math.pi/360)-math.pi/2
                  local t_arc=t*(angle_f-angle_0)

                  -- Draw background ring

                  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
                  cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
                  cairo_set_line_width(cr,ring_w)
                  cairo_stroke(cr)

                  -- Draw indicator ring

                  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
                  cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
                  cairo_stroke(cr)
              end

              function conky_ring_stats()
                  local function setup_rings(cr,pt)
                      local str='''
                      local value=0

                      str=string.format('$\{%s %s}',pt['name'],pt['arg'])
                      str=conky_parse(str)

                      value=tonumber(str)
                      if value == nil then value = 0 end
                      pct=value/pt['max']

                      draw_ring(cr,pct,pt)
                  end

                  if conky_window==nil then return end
                  local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

                  local cr=cairo_create(cs)
                  local updates=conky_parse('$\{updates}')
                  update_num=tonumber(updates)

                  if update_num>5 then
                      for i in pairs(settings_table) do
                          setup_rings(cr,settings_table[i])
                      end
                  end
                cairo_surface_destroy(cs)
              cairo_destroy(cr)
            end
          '';
      };
      "${config.xdg.configHome}/conky/Regulus/scripts/weather-text-icon" = {
        executable = true;
        text = ''
          # icon font based openweathermap.org data
          ICON_01D=""
          ICON_01N=""
          ICON_02=""
          ICON_09=""
          ICON_10=""
          ICON_11=""
          ICON_13=""
          ICON_50=""
          NO_DATA=""

          WEATHER_ICON=$(cat ~/.cache/weather.json | jq -r '.weather[0].icon')

          if [[ "$\{WEATHER_ICON}" = *01d* ]]; then
              echo "$\{ICON_01D}"
          elif [[ "$\{WEATHER_ICON}" = *01n* ]]; then
              echo "$\{ICON_01N}"
          elif [[ "$z{WEATHER_ICON}" = *02d* || "$\{WEATHER_ICON}" = *02n* || "$\{WEATHER_ICON}" = *03d* || "$\{WEATHER_ICON}" = *03n* || "$\{WEATHER_ICON}" = *04d* || "$\{WEATHER_ICON}" = *04n* ]]; then
              echo "$\{ICON_02}"
          elif [[ "$\{WEATHER_ICON}" = *09d* || "$\{WEATHER_ICON}" = *09n* ]]; then
              echo "$\{ICON_09}"
          elif [[ "$\{WEATHER_ICON}" = *10d* || "$\{WEATHER_ICON}" = *10n* ]]; then
              echo "$\{ICON_10}"
          elif [[ "$\{WEATHER_ICON}" = *11d* || "$\{WEATHER_ICON}" = *11n* ]]; then
              echo "$\{ICON_11}"
          elif [[ "$\{WEATHER_ICON}" = *13d* || "$\{WEATHER_ICON}" = *13n* ]]; then
              echo "$\{ICON_13}"
          elif [[ "$\{WEATHER_ICON}" = *50d* || "$\{WEATHER_ICON}" = *50n* ]]; then
              echo "$\{ICON_50}"
          else
            echo "$\{NO_DATA}"
          fi
          exit
        '';
      };
      "${config.xdg.configHome}/conky/Regulus/scripts/playerctl.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # Simple script to get playerctl status

          PCTL=$(playerctl status)

          if [[ $\{PCTL} == "" ]]; then
          	echo "No Music Played"
          else
          	playerctl metadata xesam:title
          fi

          exit
        '';
      };
      "${config.xdg.configHome}/conky/Regulus/scripts/weather-v2.0.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # This script is to get weather data from openweathermap.com in the form of a json file
          # so that conky will still display the weather when offline even though it doesn't up to date

          # Variables
          # get your city id at https://openweathermap.org/find and replace
          city_id=3448439

          # replace with yours
          api_key=3901194171bca9e5e3236048e50eb1a5

          # choose between metric for Celcius or imperial for fahrenheit
          unit=metric

          # i'm not sure it will support all languange,
          lang=en

          # Main command
          url="api.openweathermap.org/data/2.5/weather?id=$\{city_id}&appid=$\{api_key}&cnt=5&units=$\{unit}&lang=$\{lang}"
          curl $\{url} -s -o ~/.cache/weather.json

          exit
        '';
      };
    };
  };
}
