# NixOS Flake Configuration

This flake configuration sets up a NixOS system with various inputs, outputs, and modules. It includes configurations for packages, formatters, overlays, NixOS modules, Home Manager modules, and NixOS configurations.

## Inputs

- **nixpkgs-stable:** [`github:nixos/nixpkgs/nixos-24.05`](https://github.com/NixOS/nixpkgs/tree/nixos-24.05)
- **nixpkgs-unstable:** [`github:nixos/nixpkgs/nixos-unstable`](https://github.com/NixOS/nixpkgs/tree/nixos-unstable)
- **agenix:** [`github:ryantm/agenix`](https://github.com/ryantm/agenix)
- **home-manager:** [`github:nix-community/home-manager/release-24.05`](https://github.com/nix-community/home-manager/tree/release-24.05)
- **fzf-tab:** [`github:Aloxaf/fzf-tab`](https://github.com/Aloxaf/fzf-tab)
- **tmux-tokyo-night:** [`github:janoamaral/tokyo-night-tmux`](https://github.com/janoamaral/tokyo-night-tmux)


## Outputs

- **Supported Systems:** `x86_64-linux`
- **Packages:** Custom packages accessible through `nix build`, `nix shell`, etc.
- **Formatter:** Formatter for nix files, available through `nix fmt` (using `alejandra`).
- **Overlays:** Custom packages and modifications exported as overlays.
- **NixOS Modules:** Reusable NixOS modules.
- **Home Manager Modules:** Reusable Home Manager modules.
- **NixOS Configurations:** NixOS configurations for the system.

## NixOS Configurations

The NixOS configurations are defined in the `nixosConfigurations` attribute. The configuration for the host `pelagrino-production` is set up with the following modules:

- `inputs.home-manager.nixosModules.default`
- `inputs.agenix.nixosModules.default`
- [`./hardware.nix`](./hardware.nix)
- [`./configuration`](./configuration/)
- [`./secrets`](./secrets)
- [`./users`](./users)