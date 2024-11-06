{...}: let
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
    home = {
      username = user;
      homeDirectory = "/home/${user}";
    };
  };
}
