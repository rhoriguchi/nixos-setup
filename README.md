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
- ProtonVPN Gui
- Signal
- Spotify
- Steam
- TeamViewer

### Server

#### Setup plex over `IP:32400/web`

#### Home Assistant

- Create default user
- Delete all areas
- Add integrations
  - Netatmo
  - Ubiquiti UniFi
- Configure myStrom buttons
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_blue" "http://myStrom-Button-E9DACB.iot/api/v1/device/F4CFA2E9DACB"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_orange" "http://myStrom-Button-E9DAD9.iot/api/v1/device/F4CFA2E9DAD9"`

#### Google Photos Sync

Run the command the service calls and authenticate the application with Google.

### Hypervisor

#### Setup RAID 0

```bash
sudo mdadm --create --verbose /dev/md0 --level=mirror --raid-devices=2 /dev/sda /dev/sdb
sudo mkfs.ext4 -F /dev/md0
```

Add output to `boot.initrd.mdadmConf`:

```bash
sudo mdadm --detail --scan
```

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
