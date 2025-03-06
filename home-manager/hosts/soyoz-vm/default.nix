{ pkgs, ... }: {
  # i18n = {
  #   glibcLocales = pkgs.glibcLocales.override {
  #     allLocales = false;
  #     locales = [
  #       "en_US.UTF-8/UTF-8"
  #       "pt_BR.UTF-8/UTF-8"
  #     ];
  #   };
  # };

  console.fzf.enable = true;

  home = {
    keyboard = {
      layout = "br";
      variant = "abnt2";
      model = "pc105";
    };
  };
}
