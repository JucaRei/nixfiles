{ lib, ... }: {
  xdg = {
    configFile = {
      ".Xresources" = lib.mkForce {
        text = ''
          ! special
          *.foreground:   #d3c6aa
          *.background:   #232a2e
          *.cursorColor:  #d3c6aa

          ! black
          *.color0:       #7a8478
          *.color8:       #7a8478

          ! red
          *.color1:       #e67e80
          *.color9:       #e67e80

          ! green
          *.color2:       #a7c080
          *.color10:      #a7c080

          ! yellow
          *.color3:       #dbbc7f
          *.color11:      #dbbc7f

          ! blue
          *.color4:       #7fbbb3
          *.color12:      #7fbbb3

          ! magenta
          *.color5:       #d699b6
          *.color13:      #d699b6

          ! cyan
          *.color6:       #83c092
          *.color14:      #83c092

          ! white
          *.color7:       #d3c6aa
          *.color15:      #d3c6aa

          st.font: monospace:size=12:antialias=true:autohint=true
          st.background:       #232a2e
          st.depth:		32
          st.letterSpace: 0
          st.lineSpace: 0
          st.geometry: 92x24
          !URxvt.internalBorder: 24
          st.internalBorder: 4
          st.cursorBlink: true
          st.cursorUnderline: false
          st.saveline: 2048
          st.scrollBar_right: false
          st.urgentOnBell: true
          st.iso14755: false
        '';
      };
    };
  };
}
