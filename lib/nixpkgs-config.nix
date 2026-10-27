# lib/nixpkgs-config.nix
# Configuração canônica unificada de nixpkgs para NixOS e Home Manager.
# Pacotes com falhas conhecidas de segurança (insecure) NÃO devem ser
# permitidos aqui de forma genérica. Use `permittedInsecurePackages`
# especificamente no host que deles necessita (ex.: rocinante).
{
  allowUnfree = true;
  allowBroken = true;
  nvidia.acceptLicense = true;
}
