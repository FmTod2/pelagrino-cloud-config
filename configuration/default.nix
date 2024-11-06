{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  hostName,
  ...
}: {
  # Set system state version
  system.stateVersion = "24.05";

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

  # Configure networking
  networking = {
    inherit hostName;

    useDHCP = false;
    enableIPv6 = false;
    networkmanager.enable = true;
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
  };

  # Configure environment
  environment = {
    systemPackages = import ./packages.nix pkgs;

    # Set environment variables
    sessionVariables = {
      # Set flake path
      FLAKE = "/etc/nixos";

      COREPACK_ENABLE_STRICT = 0;
      COREPACK_ENABLE_AUTO_PIN = 0;
      COREPACK_ENABLE_PROJECT_SPEC = 0;
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

  users = {
    # Set default shell to Zsh
    defaultUserShell = pkgs.zsh;

    # Add group for www-data
    groups = {
      "www-data" = {};
    };
  };

  # Home Manager
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    sharedModules = lib.mapAttrsToList (name: value: value) outputs.homeManagerModules;
    extraSpecialArgs = {
      inherit inputs outputs;
      stateVersion = config.system.stateVersion;
    };
  };

  security = {
    # Enable the RealtimeKit system service
    rtkit.enable = true;

    # Enable SSH agent authentication
    pam.sshAgentAuth.enable = true;
  };

  # Configure system programs
  programs = {
    # Enable SSH agent
    ssh.startAgent = true;

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
    # Enable SSH server
    openssh.enable = true;

    # Enable redis
    redis.servers.pelagrino.enable = true;

    # Enable MeiliSearch
    meilisearch = {
      enable = true;
      environment = "production";
      masterKeyEnvironmentFile = config.age.secrets."meilisearch/environment".path;
    };

    # Enable PostgreSQL
    postgresql = {
      enable = true;

      ensureDatabases = ["pelagrino"];

      ensureUsers = [
        {
          name = "pelagrino";
          ensureDBOwnership = true;
        }
      ];

      authentication = ''
        #type database  DBuser  auth-method
        local all       all     trust
      '';

      identMap = ''
        # ArbitraryMapName systemUser DBUser
          superuser_map      root      postgres
          superuser_map      postgres  postgres
          # Let other names login as themselves
          superuser_map      /^(.*)$   \1
      '';
    };
  };

  # Configure systemd service for PM2
  systemd.services.pm2 = {
    enable = true;
    description = "pm2";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      PM2_HOME = "/etc/.pm2";
    };
    serviceConfig = {
      Type = "forking";
      User = "pelagrino";
      LimitNOFILE = "infinity";
      LimitNPROC = "infinity";
      LimitCORE = "infinity";
      PIDFile = "/etc/.pm2/pm2.pid";

      Restart = "on-failure";

      ExecStart = "${pkgs.pm2}/bin/pm2 resurrect";
      ExecReload = "${pkgs.pm2}/bin/pm2 reload all";
      ExecStop = "${pkgs.pm2}/bin/pm2 kill";
    };
  };

  server.reverse-proxy.enable = false;
}
