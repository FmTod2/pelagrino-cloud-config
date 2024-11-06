{
  lib,
  config,
  ...
}:
with lib; let
  name = "networking";
  namespace = "linode";

  cfg = config.${namespace}.${name};
in {
  options.${namespace}.${name} = {
    enable = mkEnableOption (mdDoc name);
  };

  config = mkIf cfg.enable {
    # Configure networking
    networking = {
      # Use networkd to manage networking
      useNetworkd = true;

      # Use predictable interface names
      useDHCP = false;
      usePredictableInterfaceNames = false;

      # Configure network interfaces
      interfaces.eth0 = {
        useDHCP = true;
        tempAddress = "disabled";
      };
    };

    # Configure systemd network
    systemd.network = {
      enable = true;

      # Configure network interfaces
      networks."10-wired" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          # Start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";

          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;

          # Disable IPv6 Privacy Extensions
          IPv6PrivacyExtensions = false;
        };

        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
