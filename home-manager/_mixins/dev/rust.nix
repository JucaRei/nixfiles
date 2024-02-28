{pkgs, ...}: {
  home.packages = with pkgs; [
    cargo
    rustc
    # rusty-man
    # surrealdb
  ];
  home.sessionPath = ["$HOME/.cargo/bin"];
}
