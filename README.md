# Nix Flake with Snowfall

This repository contains a Nix flake configuration using the [snowfall](https://github.com/GTrunSec/snowfall) framework. Snowfall is a lightweight and flexible framework for managing NixOS configurations.

## Getting Started

To use this flake, you need to have Nix installed on your system. Follow the instructions on the [Nix website](https://nixos.org/download.html) to install Nix.

## Usage

Clone this repository and navigate to the directory:

```sh
git clone https://github.com/JucaRei/nixfiles.git
cd nixfiles
```

### Running the Flake

To apply the NixOS configuration defined in this flake, use the following command:

```sh
sudo nixos-rebuild switch --flake .
```

### Updating the Flake

To update the flake and its dependencies, run:

```sh
nix flake update
```

## Structure

- `flake.nix`: The main flake configuration file.
- `nixos/`: Directory containing NixOS configuration modules.
- `overlays/`: Directory for custom Nixpkgs overlays.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [NixOS](https://nixos.org/)
- [Snowfall](https://github.com/GTrunSec/snowfall)

Feel free to customize this README to better fit your project's needs.