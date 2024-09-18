_: {
  programs = {
    imv = {
      enable = true;
      settings = { };
    };
  };

  xdg = {
    configFile = {
      "imv/conf" = {
        text = ''
          # Default config for imv

          [options]
          background = 1B161F
          fullscreen = true
          loop_input = true
          overlay_font = Terminus:18
          scaling_mode = shrink


          # Suppress built-in key bindings, and specify them explicitly in this
          # config file.
          suppress_default_binds = true

          [aliases]
          # Define aliases here. Any arguments passed to an alias are appended to the
          # command.
          # alias = command to run

          [binds]
          # Define some key bindings
          q = quit
          # y = exec echo working!

          # Image navigation
          <Left> = prev
          <bracketleft> = prev
          <Right> = next
          <bracketright> = next
          gg = goto 0
          <Shift+G> = goto -1

          # Panning
          j = pan 0 -50
          k = pan 0 50
          h = pan 50 0
          l = pan -50 0

          # Zooming
          <Up> = zoom 1
          <Shift+plus> = zoom 1
          i = zoom 1
          <Down> = zoom -1
          <minus> = zoom -1
          o = zoom -1

          # Other commands
          x = close
          <Shift+X> = exec rm "$imv_current_file"; close

          f = fullscreen
          d = overlay
          p = exec echo $imv_current_file
          c = center
          s = scaling next
          <Shift+S> = upscaling next
          a = zoom actual
          r = reset

          # Gif playback
          <period> = next_frame
          <space> = toggle_playing

          # Slideshow control
          t = slideshow +2
          <Shift+T> = slideshow 0
        '';
      };
    };
  };
}
