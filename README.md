# nix-setup

## Switch to unstable package channel

```console
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
- NixOps
- ProtonVPN Gui
- qBittorrent
- Resilio Sync
- GPG Key
- Signal
- Spotify
- Steam
- TeamViewer

#### [Authorize OneDrive](https://github.com/abraunegg/onedrive/blob/master/docs/USAGE.md#authorize-the-application-with-your-onedrive-account)

### Add KeePass password to keyring

```console
nix-shell -p libsecret --run 'secret-tool store --label=KeePass KeePass 2FA'
```

### Server

#### Setup Plex over `http://IP:32400/web`

#### Setup Tautulli `http://IP:8181`

Set any username and password. Will be removed after restart of service.

#### [Home Assistant](configuration/devices/headless/server/home-assistant/README.md)

#### Google Photos Sync

Run the command the service `gphotos-sync.service` calls and authenticate the application with Google.

#### Setup ZFS

```console
zpool create -f \
  -o ashift=12 \
  -o autotrim=on \
  -O compression=off \
  -O mountpoint=legacy \
  os \
  mirror \
    nvme-WD_BLACK_SN850X_2000GB_24271Z801901_1-part2 \
    nvme-WD_BLACK_SN850X_2000GB_24271Z801902_1-part2

zfs create \
  os/root

zpool create -f \
  -o ashift=12 \
  -o autotrim=on \
  -O compression=off \
  -O mountpoint=legacy \
  data \
  raidz \
    ata-Samsung_SSD_870_EVO_2TB_S6PPNM0TB02114B \
    ata-Samsung_SSD_870_EVO_2TB_S6PPNM0TB02182K \
    ata-Samsung_SSD_870_EVO_2TB_S6PPNM0TB06008F \
    ata-Samsung_SSD_870_EVO_2TB_S6PPNM0TB06013H

zfs create \
  -o compression=zstd \
  data/backup

zfs create \
  data/deluge

zfs create \
  data/loki

zfs create \
  data/series

zfs create \
  -o quota=512G \
  data/sync
```

#### [libvirt](configuration/devices/headless/server/libvirtd/README.md)

## Update flake

```console
nix flake update
```

## Setup direnv

Navigate to directory and run command

```console
direnv allow .
```

## deploy-rs

### Deploy all

```console
deploy --keep-result . |& nom
```

### Deploy single

```console
deploy --keep-result '.#Laptop' |& nom
```

## Encrypt backup drive

```console
cryptsetup luksFormat --type luks2 /dev/sdX

dd if=/dev/random bs=256 count=1 of=/PATH_TO_KEY_FILE
cryptsetup luksAddKey /dev/sdX /PATH_TO_KEY_FILE

cryptsetup luksOpen --key-file /PATH_TO_KEY_FILE /dev/disk/by-uuid/792d67dc-3de4-4790-9e51-ec281e28b0d1 backup

mkfs.ext4 -L backup /dev/mapper/backup
```

## Upgrade firmware

### Hardware

#### List hardware

```console
fwupdmgr get-devices
```

#### Upgrade hardware

```console
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update
```

### Raspberry Pi

```console
mkdir -p /mnt/FIRMWARE && mount /dev/disk/by-label/FIRMWARE /mnt/FIRMWARE
BOOTFS=/mnt/FIRMWARE FIRMWARE_RELEASE_STATUS=stable rpi-eeprom-update -d -a
umount /mnt/FIRMWARE && rm -rf /mnt/FIRMWARE
```
