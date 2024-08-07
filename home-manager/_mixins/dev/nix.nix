{ pkgs, inputs, ... }: {
  home = {
    packages = with pkgs; [
      # alejandra
      cachix
      any-nix-shell
      cached-nix-shell
      deadnix
      nix-bash-completions
      # nix-index
      nix-melt
      nix-prefetch-git
      nix-du
      nix-tree
      nixpkgs-fmt
      # inputs.chaotic.packages.${pkgs.system}.nixfmt_rfc166
      nurl
      nil
      # nixd
      # rnix-lsp
      # statix
    ];
  };

  # programs = {
  #   nix-index = {
  #     enable = true;
  #     enableBashIntegration = true;
  #     enableFishIntegration = true;
  #     enableZshIntegration = true;
  #   };
  # };
}
