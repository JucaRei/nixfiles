function switch-home
    if test -e $HOME/.dotfiles/nixfiles        pushd $HOME/.dotfiles/nixfiles        home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles        popd
    else
        echo "ERROR! No nix-config found in $HOME/.dotfiles/nixfiles"
    end
end
