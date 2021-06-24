# nix-setup

## Switch to unstable package channel

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

## Manual steps

### Laptop

#### [Authorize OneDrive](https://github.com/abraunegg/onedrive/blob/master/docs/USAGE.md#authorize-the-application-with-your-onedrive-account)

#### Login to

- Discord
- Gitkraken
- JetBrains
  - IntelliJ IDEA Ultimate
  - PyCharm Professional
  - WebStorm
  - DataGrip
- Postman
- Signal
- Spotify
- Steam
- TeamViewer

### Server

#### Setup plex over `IP:32400/web`

## Nixops

### Init

```bash
nixops create nixops.nix
```

### Info

```bash
nixops info
```

### Deploy

```bash
sudo nix-channel --update
nixops deploy
```
