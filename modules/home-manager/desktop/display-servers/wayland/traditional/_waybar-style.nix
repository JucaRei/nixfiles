# Waybar CSS stylesheet with dynamic theme integration.
{ c }:
''
  * {
    border: none;
    border-radius: 0;
    font-family: 'Inter', 'JetBrainsMono Nerd Font', Roboto, Helvetica, Arial, sans-serif;
    font-size: 13px;
    min-height: 0;
  }

  window#waybar {
    background-color: transparent;
    color: ${c.fg};
  }

  tooltip {
    background: ${c.bgDark};
    border-radius: 10px;
    border: 1px solid ${c.accent};
    color: ${c.fg};
  }

  #custom-launcher {
    background: ${c.accent};
    color: ${c.bg};
    border-radius: 8px;
    padding: 2px 10px;
    margin: 4px 2px;
    font-size: 15px;
    transition: all 0.2s ease-in-out;
  }

  #custom-launcher:hover {
    background: ${c.purple};
  }

  #tags,
  #workspaces {
    background: ${c.surface};
    border: 1px solid ${c.border};
    border-radius: 8px;
    margin: 4px 2px;
    padding: 0 4px;
  }

  #tags button,
  #workspaces button {
    padding: 2px 6px;
    color: ${c.fgMuted};
    border-radius: 6px;
    transition: all 0.2s ease-in-out;
    font-size: 13px;
  }

  #tags button.occupied,
  #workspaces button.occupied {
    color: ${c.yellow};
  }

  #tags button.empty,
  #workspaces button.empty {
    color: ${c.fgSubtle};
  }

  #tags button.focused,
  #tags button.active,
  #workspaces button.focused,
  #workspaces button.active {
    color: ${c.bg};
    background: ${c.accent};
    font-weight: 800;
  }

  #tags button.urgent,
  #workspaces button.urgent {
    color: ${c.bg};
    background: ${c.red};
  }

  #tags button:hover,
  #workspaces button:hover {
    background: ${c.surfaceAlt};
    color: ${c.fg};
  }

  #tags button.empty:nth-child(n+6),
  #workspaces button.empty:nth-child(n+6) {
    padding: 0;
    margin: 0;
    min-width: 0;
    font-size: 0;
    border: none;
    opacity: 0;
  }

  #custom-layout {
    background: ${c.surface};
    border: 1px solid ${c.border};
    color: ${c.purple};
    border-radius: 8px;
    padding: 2px 10px;
    margin: 4px 3px;
    transition: all 0.2s ease-in-out;
  }

  #custom-layout:hover {
    background: ${c.purple};
    color: ${c.bg};
    border-color: ${c.pink};
  }

  #window,
  #custom-window {
    color: ${c.fgMuted};
    padding: 2px 8px;
    margin: 4px 3px;
    font-weight: 600;
  }

  #custom-window.empty {
    opacity: 0;
    padding: 0;
    margin: 0;
  }

  #clock {
    background: ${c.surface};
    border: 1px solid ${c.border};
    color: ${c.accent};
    border-radius: 8px;
    padding: 2px 12px;
    margin: 4px 0;
  }

  #cpu,
  #temperature,
  #memory,
  #disk,
  #network,
  #pulseaudio,
  #backlight,
  #battery,
  #tray {
    background: ${c.surface};
    border: 1px solid ${c.border};
    border-radius: 8px;
    padding: 2px 8px;
    margin: 4px 2px;
  }

  #cpu {
    color: ${c.cyan};
  }

  #temperature {
    color: ${c.orange};
  }

  #temperature.critical {
    color: ${c.red};
  }

  #memory {
    color: ${c.green};
  }

  #disk {
    color: ${c.yellow};
  }

  #network {
    color: ${c.purple};
  }

  #pulseaudio {
    color: ${c.pink};
  }

  #pulseaudio.muted {
    color: ${c.fgMuted};
    background: ${c.bgDark};
  }

  #backlight {
    color: ${c.yellow};
  }

  #battery {
    color: ${c.green};
  }

  #battery.charging {
    color: ${c.teal};
  }

  #battery.warning:not(.charging) {
    color: ${c.orange};
  }

  #battery.critical:not(.charging) {
    color: ${c.red};
    animation: blink 1s steps(2) infinite;
  }

  @keyframes blink {
    to {
      background-color: ${c.red};
      color: ${c.bg};
    }
  }

  #custom-power {
    background: ${c.surface};
    border: 1px solid ${c.red};
    color: ${c.red};
    border-radius: 8px;
    padding: 2px 10px;
    margin: 4px 2px 4px 4px;
    transition: all 0.2s ease-in-out;
  }

  #custom-power:hover {
    background: ${c.red};
    color: ${c.bg};
    border-color: ${c.red};
  }
''
