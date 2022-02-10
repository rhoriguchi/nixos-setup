# nix-setup

## Switch to unstable package channel

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

## Manual setup

### Laptop

- SSH Keys
- Discord
- Gitkraken
- JetBrains
  - DataGrip
  - IntelliJ IDEA Ultimate
  - PyCharm Professional
  - WebStorm
- Firefox
  - BitWarden
  - Grammarly
  - MetaMask
  - Tab Session Manager
- Nixops
- Postman
- ProtonVPN Gui
- qBittorrent
- Resilio Sync
- GPG Key
- Signal
- Spotify
- Steam
- TeamViewer

#### [Authorize OneDrive](https://github.com/abraunegg/onedrive/blob/master/docs/USAGE.md#authorize-the-application-with-your-onedrive-account)

### Server

#### Setup Plex over `IP:32400/web`

#### Home Assistant

- Create default user
- Delete all areas
- Add integrations
  - Netatmo
  - Shelly
  - Ubiquiti UniFi
- Configure myStrom buttons
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_blue" "http://myStrom-Button-E9DACB.iot/api/v1/device/F4CFA2E9DACB"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_gray" "http://myStrom-Button-E9DA8E.iot/api/v1/device/F4CFA2E9DA8E"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_orange" "http://myStrom-Button-E9DAD9.iot/api/v1/device/F4CFA2E9DAD9"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_purple" "http://myStrom-Button-E9D761.iot/api/v1/device/F4CFA2E9D761"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_white" "http://myStrom-Button-F8CB7A.iot/api/v1/device/CC50E3F8CB7A"`

#### Google Photos Sync

Run the command the service `gphotos-sync.service` calls and authenticate the application with Google.

### Hypervisor

#### Setup ZFS

```bash
zpool create -f -o ashift=12 -m /mnt/Data data raidz ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E2PN4A53 ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E5JNF5EA
zfs set mountpoint=legacy data
mount -t zfs data /mnt/Data
```

## Nixops

### Init

```bash
nixops create
```

### Info

```bash
nixops info
```

### Deploy

```bash
nixops ssh-for-each --parallel "nix-channel --update"
nixops deploy
```

### Delete garabge

```bash
nixops ssh-for-each --parallel "nix-collect-garbage -d"
```
