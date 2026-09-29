{ pkgs, ... }: {
  imports = [
    ./firefox
    ./chrome
  ];

  home = {
    # Add more fonts for any browser
    packages = with pkgs; [
      # msttcorefonts
      nerd-fonts.martian-mono
      lato
      ffmpeg # Codecs de vídeo/áudio para YouTube
    ];
  };
}
