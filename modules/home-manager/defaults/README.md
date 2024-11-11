# Home Manager Configuration

This NixOS module configures various programs and settings using Home Manager. It includes default base configurations for systemd services, package manager, session variables, and several programs like SSH, Git, FZF, Zoxide, HSTR, ZSH, and Tmux.

## Configuration

### Systemd Services

- **Start services using sd-switch:**

  ```nix
  systemd.user.startServices = lib.mkDefault "sd-switch";
  ```

### Package Manager

- **Configure the package manager:**

  ```nix
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs.nix;
  nixpkgs.config = import ./nixpkgs.nix;
  ```

### Home

- **Set default state version to system's state verstion:**

  ```nix
  stateVersion = lib.mkDefault stateVersion;
  ```

- **Set session variables for corepack not to modify the `package.json` file:**

  ```nix
  sessionVariables = {
    COREPACK_ENABLE_STRICT = "0";
    COREPACK_ENABLE_AUTO_PIN = "0";
    COREPACK_ENABLE_PROJECT_SPEC = "0";
  };
  ```

### Programs

#### Home Manager

- **Allow Home Manager to manage itself:**

  ```nix
  home-manager.enable = true;
  ```

#### SSH

- **Enable SSH:**

  ```nix
  ssh.enable = true;
  ```

#### Git and Delta

- **Enable Git and Delta:**

  ```nix
  git = {
    enable = true;
    delta.enable = true;
  };
  ```

#### FZF

- **Enable FZF with Zsh and Tmux integration:**

  ```nix
  fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };
  ```

#### Zoxide

- **Enable Zoxide with Zsh integration:**

  ```nix
  zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };
  ```

#### HSTR

- **Enable HSTR with Zsh integration:**

  ```nix
  hstr = {
    enable = true;
    enableZshIntegration = true;
  };
  ```

#### ZSH

- **Enable ZSH with plugins and aliases:**

  ```nix
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
  ```

#### Tmux

- **Enable Tmux preset with Zsh integration:**

  ```nix
  presets.tmux = {
    enable = true;
    zshIntegration = true;
  };
  ```

## Usage

To use this module, include it in your NixOS configuration and set the desired options. For example:

```nix
{
  imports = [
    outputs.homeManagerModules.defaults
  ];
}
```
