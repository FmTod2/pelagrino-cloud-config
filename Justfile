# use zshell for shell commands
set shell := ["zsh", "-c"]

############################################################################
#
#  Common commands(suitable for all machines)
#
############################################################################

# Run eval tests
test:
  nix eval .#evalTests --show-trace --print-build-logs --verbose

# update all the flake inputs
update:
  nix flake update

# Update specific input
# Usage: just upgrade nixpkgs
update-input INPUT:
  nix flake lock --update-input {{INPUT}}

# Upgrade the system using the default nix command
nix-upgrade COMMAND='switch':
  sudo nixos-rebuild {{COMMAND}} --flake .

# Upgrade the system using the default nix command and the flake path
nix-upgrade-path COMMAND='switch':
  sudo nixos-rebuild {{COMMAND}} --flake path:.

# Upgrade the system using the nix helper utility
upgrade COMMAND='switch':
  nh os {{COMMAND}}

# Upgrade the system using the nix helper utility
pull-upgrade COMMAND='switch':
  git pull
  nh os {{COMMAND}}

# Commit any pending file changes and upgrade the system
commit-upgrade MESSAGE COMMAND='switch':
  git add .
  git commit -m "{{MESSAGE}}"
  nh os {{COMMAND}}

# Commit any pending file changes
commit MESSAGE:
  git add .
  git commit -m "{{MESSAGE}}"

# Commit any pending file changes
push MESSAGE:
  git add .
  git commit -m "{{MESSAGE}}"
  git push

# List all generations of the system profile
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
repl:
  sudo nixos-rebuild repl --flake .#pelagrino-production

# remove all generations older than 7 days
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Garbage collect all unused nix store entries
gc:
  sudo nix store gc --debug
  sudo nix-collect-garbage --delete-old


############################################################################
#
#  Misc, other useful commands
#
############################################################################

# format the nix files in this repo
fmt:
  nix fmt

path:
   $env.PATH | split row ":"