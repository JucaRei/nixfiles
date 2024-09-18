function switch-home
    if test -e $HOME/Zero/nix-configurations        pushd $HOME/Zero/nix-configurations        home-manager switch -b backup --flake $HOME/Zero/nix-configurations        popd
    else
        echo "ERROR! No nix-config found in $HOME/Zero/nix-config"
    end
end
