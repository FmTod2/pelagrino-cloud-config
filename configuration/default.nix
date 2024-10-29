{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  user,
  hostName,
  stateVersion,
  rootDomain,
  ...
}: {
  # Set system state version
  system.stateVersion = stateVersion;

  # Enable SSH server
  services.openssh.enable = true;

  # Disable printing
  services.printing.enable = false;

  # Enable the RealtimeKit system service
  security.rtkit.enable = true;

  # Enable SSH agent authentication
  security.pam.sshAgentAuth.enable = true;
  programs.ssh.startAgent = true;

  # Configure networking
  networking = {
    inherit hostName;

    useDHCP = false;
    networkmanager.enable = true;
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
  };

  # Configure nixpkgs
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
      outputs.overlays.unstable-packages
      outputs.overlays.flake-inputs
    ];

    # Allow unfree packages
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = ["/etc/nix/path"];

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";

      # Deduplicate and optimize nix store
      auto-optimise-store = true;

      # Use community binary cache
      substituters = ["https://nix-community.cachix.org"];
      trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    };

    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = false; # Disable in favor of NH
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  # Configure environment
  environment = {
    systemPackages = import ./systemPackages.nix pkgs;

    # Set environment variables
    sessionVariables = {
      # Set flake path
      FLAKE = "/etc/nixos";
    };

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    etc =
      lib.mapAttrs' (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Install fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "JetBrainsMono"
        "DroidSansMono"
      ];
    })
  ];

  # Set user name and groups
  users = {
    # Set default shell
    defaultUserShell = pkgs.zsh;

    # Set up the user accounts
    users.${user.name} = {
      isNormalUser = true;
      description = user.description;
      extraGroups = [user.name "wheel" "networkmanager"];

      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5mPSIN5BINqWXcPN+Iky1rePCrmSXx9mQpDpMNDThE" ];
    };
  };

  # Home Manager
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.${user.name} = import ./home.nix;
    extraSpecialArgs = {inherit inputs outputs user stateVersion;};
  };

  # Configure system programs
  programs = {
    # Enable Zsh
    zsh.enable = true;

    # Enable NH for easier system rebuilds
    nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
    };
  };

  # Configure needed services
  services = {
    # Enable redis
    redis.servers.${user.name}.enable = true;

    # Enable MeiliSearch
    meilisearch = {
      enable = false;
      environment = "production";
      masterKeyEnvironmentFile = config.age.secrets."meilisearch/environment".path;
    };

    # Enable PostgreSQL
    postgresql = {
      enable = true;

      ensureDatabases = [user.name];

      ensureUsers = [
        {
          name = user.name;
          ensureDBOwnership = true;
        }
      ];
    };
  };

  server.pelagrino.enable = false;
}
