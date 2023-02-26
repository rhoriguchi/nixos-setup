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

### Add KeePass password to keyring

```console
nix-shell -p libsecret --run "secret-tool store --label=KeePass KeePass 2FA"
```

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
  -o compression=zstd \
  data/snapshots

zfs create \
  -o quota=465GB \
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
