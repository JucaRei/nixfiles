{ inputs
, outputs
, stateVersion
, pkgs
, lib
, config
, ...
}:
let
  helpers = import ./helpers.nix { inherit inputs outputs stateVersion; }
    //
    import ./nixgl.nix { inherit pkgs lib config; };
in
{
  inherit (helpers)
    mkDarwin
    mkHome
    mkNixos
    forAllSystems
    nixGLMesaWrap
    nixGLVulkanWrap
    nixGLVulkanMesaWrap
    ;
}
