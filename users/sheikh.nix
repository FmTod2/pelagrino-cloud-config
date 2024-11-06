{inputs, ...}: let
  user = "sheikh";
  description = "Sheikh";
in {
  users.users.${user} = {
    inherit description;

    isNormalUser = true;
    extraGroups = [user "www-data" "networkmanager"];

    hashedPassword = "$y$j9T$BwWRM82WwZ0R5oYq7g5rc1$BWX3/Nyd0H8ViJ8hxPvd3vzOcrNgRWOv/JTRt4zRU28";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAr1HrvgiEIaJ2ZofvdzoQs6PuwOpaEeVdirt80fAtL0 ${user}@remote"
    ];
  };

  home-manager.users.${user} = {
    home = {
      username = user;
      homeDirectory = "/home/${user}";
    };
  };
}
