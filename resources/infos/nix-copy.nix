# /nix/store/2yij6h01b222biq14sl1w9jj3vapqzxi-home-manager-generation

# readlink result
# configDrv=$(nix-store -q --deriver result)
# nix copy $configDrv --to file:///home/juca/Documents/configCache
# nix store ls --store file:///home/juca/Documents/configCache $configDrv
# nix copy /nix/store/yikb1qgrx37qrqh85852fm3dbxj760kp-home-manager-generation --to ssh-ng//juca@192.168.1.230
# nix copy --to ssh-ng://juca@192.168.1.230?require-sigs=false ./result

# nix-copy-closure --to juca@192.168.1.230  /nix/store/2yij6h01b222biq14sl1w9jj3vapqzxi-home-manager-generation

# nom build --no-link --print-out-paths .#homeConfigurations."juca@scrubber".activationPackage --impure


# nix copy --to $"ssh-ng://cole@(tailscale ip --4 pktspot1)" ./result
# nix copy --to $"ssh-ng://cole@(tailscale ip --4 pktspot1)" ./result --no-check-sigs

# Steps To Reproduce

#     nix build --impure --expr 'with import <nixpkgs> {}; runCommand "foo" {} "touch $out"'
#     Each of the following commands will fail with error: cannot add path '/nix/store/wgf5y2kzib2wg10yki4jrs4alnzs6iy7-foo' because it lacks a valid signature:
#     a. nix copy --to ssh-ng://$untrusteduser@$otherhost ./result -- expected
#     b. nix copy --to ssh-ng://root@$otherhost ./result
#     c. nix copy --no-require-sigs --to ssh-ng://root@$otherhost ./result
#     d. nix copy --to ssh-ng://root@$otherhost?require-sigs=false ./result (also prints warning: unknown setting 'require-sigs')
#     e. nix copy --from daemon?trusted=1 --to ssh-ng://root@$otherhost ./result
#     f. (monster combination of all the plausible mechanisms) nix copy --no-require-sigs --from daemon?trusted=1 --to ssh-ng://root@$otherhost?require-sigs=false --no-require-sigs ./result
