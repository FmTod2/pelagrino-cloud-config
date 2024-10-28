{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  user,
  stateVersion,
  ...
}: {
  # Use sd-switch to manage systemd services
  systemd.user.startServices = "sd-switch";

  # Configure the package manager
  nixpkgs.config = import ./nixpkgsConfig.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgsConfig.nix;

  # Configure the home environment
  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    packages = import ./userPackages.nix pkgs;
    stateVersion = stateVersion;
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
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

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
          "docker"
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
}
