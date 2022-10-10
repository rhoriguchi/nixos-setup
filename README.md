# nix-setup

## Switch to unstable package channel

```console
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
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
- NixOps
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

### [Encrypting home directory](https://wiki.archlinux.org/title/ECryptfs#Encrypting_a_home_directory)

Temporarily add password to root user and make sure `users.users.root.hashedPassword` is not set.

```nix
users.users.root.password = "asdf1234";
```

Log out of user and open console `CTRL` + `ALT` + `F1` and login to root user.

```console
modprobe ecryptfs
nix-shell -p ecryptfs --run "ecryptfs-migrate-home -u rhoriguchi"
```

Remove `users.users.root.password` option and delete copy of home `/home/rhoriguchi.random_characters`.

### Server

#### Setup Plex over `http://IP:32400/web`

#### Home Assistant

- Create default user `admin`
- Delete all areas
- Add integrations
  - Netatmo
    - Get credentials from <https://dev.netatmo.com>
  - Shelly
    - shellycolorbulb-98CDAC1F031E.iot
    - shellycolorbulb-98CDAC1F68BC.iot
  - Ubiquiti UniFi
- Configure myStrom buttons
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_blue" "http://myStrom-Button-E9DACB.iot/api/v1/device/F4CFA2E9DACB"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_gray" "http://myStrom-Button-E9DA8E.iot/api/v1/device/F4CFA2E9DA8E"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_orange" "http://myStrom-Button-E9DAD9.iot/api/v1/device/F4CFA2E9DAD9"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_purple" "http://myStrom-Button-E9D761.iot/api/v1/device/F4CFA2E9D761"`
  - `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_white" "http://myStrom-Button-F8CB7A.iot/api/v1/device/CC50E3F8CB7A"`

#### Google Photos Sync

Run the command the service `gphotos-sync.service` calls and authenticate the application with Google.

#### Setup ZFS

```console
zpool create \
  -o ashift=12 \
  -o autotrim=on \
  -O compression=off \
  -O mountpoint=legacy \
  data \
  raidz \
    ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E0ZLJXFX \
    ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E2PN4A53 \
    ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E5JNF5EA

zfs create \
  -o compression=zstd \
  data/backup

zfs create \
  data/deluge

zfs create \
  -o compression=zstd \
  data/snapshots

zfs create \
  data/sync
```

#### [libvirt](configuration/devices/headless/server/libvirtd/README.md)

## Flake

### Setup direnv

Navigate to directory and run command

```console
direnv allow .
```

### Update

```console
nix flake update
```

## NixOps

### Init

```console
nixops create
```

### Deploy

```console
nixops deploy
```

### List devices

```console
nixops info
```

### Update devices

```console
nixops modify
nixops deploy --kill-obsolete --create-only
```

### Update channel

```console
nixops ssh-for-each --parallel "nix-channel --update"
```

### Delete garabge

```console
nixops ssh-for-each --parallel "nix-collect-garbage -d"
```
