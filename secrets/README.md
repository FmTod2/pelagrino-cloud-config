# Secrets Configuration

This directory contains the configuration files for managing secrets using Age and Agenix.

## Files

### `secrets.nix`

This file defines the public keys for creating and editing the secrets.

```nix
let
  remote = "<public key>";
  local = "<public key>";
in {
  "meilisearch/environment.age".publicKeys = [remote local];
}
```

### `default.nix`

This file specifies the secrets to be managed by Agenix and their location.

```nix
{
  age.secrets = {
    "meilisearch/environment".file = ../secrets/meilisearch/environment.age;
  };
}
```
