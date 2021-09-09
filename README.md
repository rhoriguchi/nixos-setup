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

#### Large File Storage (LFS)

```bash
git lfs install
```

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

#### Google Photos Sync

Run the command the service `gphotos-sync.service` calls and authenticate the application with Google.

### Hypervisor

#### Setup ZFS

```bash
zpool create -f -o ashift=12 -m /media/Data data raidz ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E2PN4A53 ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E5JNF5EA
zfs set mountpoint=legacy data
mount -t zfs data /media/Data
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
