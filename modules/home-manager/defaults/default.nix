{
  stateVersion,
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
        COREPACK_ENABLE_STRICT = 0;
        COREPACK_ENABLE_AUTO_PIN = 0;
        COREPACK_ENABLE_PROJECT_SPEC = 0;
      };
    };
  };
}
