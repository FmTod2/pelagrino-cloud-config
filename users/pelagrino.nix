{inputs, ...}: let
  user = "pelagrino";
  description = "Pelagrino";
in {
  users.users.${user} = {
    inherit description;

    isNormalUser = true;
    extraGroups = [user "www-data" "wheel" "networkmanager"];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5mPSIN5BINqWXcPN+Iky1rePCrmSXx9mQpDpMNDThE ${user}@remote"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPaiRTYOkyQBD8JfB9Vx6GyP+P7AUv9hKDiV5k7PiCe1 ${user}@github"
    ];
  };

  home-manager.users.${user} = {
    # Configure the home environment
    home = {
      username = user;
      homeDirectory = "/home/${user}";
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

        autosuggestion = {
          enable = true;
          # highlight = "fg=#ff00ff,bg=cyan,bold,underline";
          # strategy = ["history" "completion"];
        };

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

        initExtra = ''
          if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
            tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
          fi
        '';
      };
    };

    # Enable tmux
    presets.tmux.enable = true;
  };
}
