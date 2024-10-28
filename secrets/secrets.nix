let
  pelagrino = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5mPSIN5BINqWXcPN+Iky1rePCrmSXx9mQpDpMNDThE";
  remote = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFAKBpW8WJvcpdKDC7BSk7pwWyvXX+GuWZBy3OtrrLUJ";
  local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVQJb4vtkKXIrgE440ywBqMLNKZvbLEbT7G5WEFIvL+";
in
{
  "meilisearch/environment.age".publicKeys = [ pelagrino remote local ];
}