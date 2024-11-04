{
  stateVersion,
  lib,
  ...
}: {
  config = {
    # Set state version
    home.stateVersion = lib.mkDefault stateVersion;

    # Configure the package manager
    nixpkgs.config = import ./nixpkgs.nix;
    xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs.nix;

    # Use sd-switch to manage systemd services
    systemd.user.startServices = lib.mkDefault "sd-switch";
  };
}
