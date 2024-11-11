# NixOS Configuration Documentation

This documentation provides an overview of the NixOS configuration files, detailing the setup for system state, nixpkgs, environment variables, fonts, users, Home Manager, security, programs, services, and systemd.

## Configuration Files

### `default.nix`

This file sets up the overall system configuration, including system state, nixpkgs overlays, environment variables, fonts, users, Home Manager, security settings, programs, services, and systemd configurations.

#### System State

- **State Version:** `24.05`

#### Nixpkgs

- **Overlays:** Adds various overlays for package modifications and additions.
- **Allow Unfree Packages:** `true`

#### Nix

- **Registry:** Adds each flake input as a registry.
- **Nix Path:** Adds inputs to the system's legacy channels.
- **Settings:**
  - **Experimental Features:** `nix-command flakes`
  - **Auto Optimize Store:** `true`
  - **Substituters:** `https://nix-community.cachix.org`
  - **Trusted Public Keys:** `nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=`
- **Garbage Collection:** Weekly with options `--delete-older-than 1w`

#### Networking

- **Host Name:** Inherited from the configuration.
- **Allowed TCP Ports:** `80`, `443`

#### Environment

- **System Packages:** Imported from `packages.nix`.
- **Session Variables:**
  - `FLAKE`: Flake path
  - `COREPACK_ENABLE_STRICT`: `0`
  - `COREPACK_ENABLE_AUTO_PIN`: `0`
  - `COREPACK_ENABLE_PROJECT_SPEC`: `0`
- **Legacy Channels:** Adds inputs to the system's legacy channels.

#### Fonts

- **Installed Fonts:**
  - `noto-fonts`
  - `noto-fonts-cjk`
  - `noto-fonts-emoji`
  - `nerdfonts` (overridden with `FiraCode`, `JetBrainsMono`, `DroidSansMono`)

#### Users

- **Default Shell:** Zsh
- **Groups:** Adds `www-data` group.

#### Home Manager

- **Use User Packages:** `true`
- **Use Global Packages:** `true`
- **Backup File Extension:** `backup`
- **Shared Modules:** Maps outputs to Home Manager modules.
- **Extra Special Args:** Includes inputs, outputs, and state version.

#### Security

- **RealtimeKit:** Enabled
- **SSH Agent Authentication:** Enabled for PAM and sudo.

#### Programs

- **SSH Agent:** Enabled
- **Zsh:** Enabled
- **NH:** Enabled with flake path and clean options.

#### Services

- **OpenSSH:** Enabled with specific settings.
- **Locate:** Enabled
- **Fail2ban:** Enabled
- **Logrotate:** Enabled
- **Redis:** Enabled for `pelagrino`
- **MeiliSearch:** Enabled with production environment and master key.
- **PostgreSQL:** Enabled with specific databases and users.

#### Systemd

- **PM2 Service:** Configured with specific settings.

#### Server

- **Reverse Proxy:** Disabled
- **Linode Networking:** Enabled

### `packages.nix`

This file lists the system packages to be installed.

- **Packages:**
  - `agenix`
  - `libsecret`
  - `kitty`
  - `git`
  - `wget`
  - `curl`
  - `fzf`
  - `lshw`
  - `lsd`
  - `bat`
  - `mtr`
  - `ripgrep`
  - `unzip`
  - `jq`
  - `zoxide`
  - `htop`
  - `gcc`
  - `glibc`
  - `glib`
  - `just`
  - `gtop`
  - `wmctrl`
  - `busybox`
  - `libinput`
  - `wl-clipboard`
  - `inetutils`
  - `sysstat`
  - `smartmontools`
  - `dig`
  - `pm2`
  - `nodejs_20`
  - `corepack_20`
  