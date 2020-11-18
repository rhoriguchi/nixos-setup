# nix_setup

## Update to unstable package source

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz home-manager

sudo nix-channel --update
```
