{ config, pkgs, username, ... }: {
  # https://github.com/muesli/deckmaster
  home = {
    file = {
      "${config.xdg.configHome}/autostart/deskmaster-xl.desktop".text =
        "\n        [Desktop Entry]\n        Name=Deckmaster XL\n        Comment=Deckmaster XL\n        Type=Application\n        Exec=deckmaster -deck ${config.home.homeDirectory}/Studio/StreamDeck/Deckmaster-xl/main.deck\n        Categories=\n        Terminal=false\n        NoDisplay=true\n        StartupNotify=false";
    };
    # Deckmaster and the utilities I bind to the Stream Deck
    packages = with pkgs; [
      bc
      deckmaster
      hueadm
      libnotify
      unstable.obs-cli
      playerctl
    ];
  };
}
