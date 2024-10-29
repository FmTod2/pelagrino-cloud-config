let
  remote = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH43P4fLLt8BkOueQgdRxWB9p2NZEn1gzgCClMylcPTz";
  local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVQJb4vtkKXIrgE440ywBqMLNKZvbLEbT7G5WEFIvL+";
in
{
  "meilisearch/environment.age".publicKeys = [ remote local ];
}