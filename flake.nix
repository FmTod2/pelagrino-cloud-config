{
  description = "Nixos config flake";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixpkgs-stable";

    agenix.url = "github:ryantm/agenix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fzf-tab = {
      url = "github:Aloxaf/fzf-tab";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Supported systems for your flake packages, shell, etc.
    systems = ["x86_64-linux"];

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Set global state version for nixos and home-manager
    stateVersion = "24.05";

    # Hostname
    hostName = "pelagrino-remote";

    # Root domain
    rootDomain = "pelagrino.com";

    # User information
    user = {
      name = "pelagrino";
      description = "Pelagrino";
    };
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # Your nixos configurations
    nixosConfigurations = let
      lib = nixpkgs.lib;
    in {
      ${hostName} = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs user hostName stateVersion rootDomain;
        };
        modules =
          [
            inputs.home-manager.nixosModules.default
            inputs.agenix.nixosModules.default
            ./hardware.nix
            ./configuration
            ./secrets
          ]
          ++ lib.attrsets.mapAttrsToList (name: value: value) outputs.nixosModules;
      };
    };
  };
}
