{
  stateVersion,
  inputs,
  lib,
  ...
}: {
  config = {
    # Use sd-switch to manage systemd services
    systemd.user.startServices = lib.mkDefault "sd-switch";

    # Configure the package manager
    xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs.nix;
    nixpkgs.config = import ./nixpkgs.nix;

    home = {
      # Set state version
      stateVersion = lib.mkDefault stateVersion;

      # Set session variables
      sessionVariables = {
        COREPACK_ENABLE_STRICT = "0";
        COREPACK_ENABLE_AUTO_PIN = "0";
        COREPACK_ENABLE_PROJECT_SPEC = "0";
      };
    };

    # Enable programs
    programs = {
      # Allow home-manager to manage itself
      home-manager.enable = true;

      # Enable SSH
      ssh.enable = true;

      # Enable git and delta
      git = {
        enable = true;
        delta.enable = true;
      };

      # Enable fzf
      fzf = {
        enable = true;
        enableZshIntegration = true;
        tmux.enableShellIntegration = true;
      };

      # Enable zoxide
      zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = ["--cmd cd"];
      };

      # Enable hstr
      hstr = {
        enable = true;
        enableZshIntegration = true;
      };

      # Enable zsh with plugins
      zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;

        shellAliases = {
          ls = "lsd";
          l = "ls -l";
          la = "ls -a";
          lla = "ls -la";
          lt = "ls --tree";
          pn = "pnpm";
          cat = "bat";
        };

        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "npm"
            "node"
            "zoxide"
            "zsh-interactive-cd"
          ];
        };

        plugins = [
          {
            name = "fzf-tab";
            src = inputs.fzf-tab;
            file = "fzf-tab.plugin.zsh";
          }
        ];
      };
    };

    # Enable tmux
    presets.tmux = {
      enable = true;
      zshIntegration = true;
    };
  };
}
