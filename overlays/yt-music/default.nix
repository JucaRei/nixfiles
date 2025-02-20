{ channels, namespace, ... }:

final: prev: {
  ${namespace} = (prev.${namespace} or { }) // {
    yt-music = prev.makeDesktopItem {
      name = "YT Music";
      desktopName = "YT Music";
      genericName = "Music, from YouTube.";
      exec = ''${final.firefox}/bin/firefox "https://music.youtube.com/?${namespace}.app=true"'';
      icon = ./icon.svg;
      type = "Application";
      categories = [
        "AudioVideo"
        "Audio"
        "Player"
      ];
      terminal = false;
    };
  };
}
