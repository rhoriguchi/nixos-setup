# nix-setup

## Switch to unstable package channel

```console
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

## Devices

### XXLPitu-Aizen

#### Manual setup

- Discord
- Gitkraken
- SSH Keys
- Firefox
  - BitWarden
  - Grammarly
  - Tab Session Manager
  - RabattCorner
- qBittorrent
- Resilio Sync
- RustDesk
- Signal
- Spotify
- Steam

##### GPG Key

###### Export

```console
gpg --output private.gpg --armor --export-secret-key ryan.horiguchi@gmail.com
```

###### Import

```console
gpg --import private.gpg

expect << 'EOF'
spawn gpg --edit-key ryan.horiguchi@gmail.com
expect "gpg>"
send "trust\n"
expect "Your decision?"
send "5\n"
expect "Do you really want to set this key to ultimate trust?"
send "y\n"
expect "gpg>"
send "quit\n"
interact
EOF
```

##### [Authorize OneDrive](https://github.com/abraunegg/onedrive/blob/master/docs/usage.md#authorise-the-application-with-your-microsoft-onedrive-account)

##### Add KeePass password to keyring

```console
nix-shell -p libsecret --run 'secret-tool store --label=KeePass KeePass 2FA'
```

### XXLPitu-Tier

#### Bios

- `Advanced mode(F7)` -> `Advanced` -> `AMD CBS` ->  `ECC` -> `Enabled`
- `Advanced mode(F7)` -> `Advanced` -> `APM Configuration` -> `Restore AC Power Loss` -> `Last State`
- `Advanced mode(F7)` -> `Boot` -> `Boot Configuration` -> `Wait For [F1] If Error` -> `Disabled`
- `Advanced mode(F7)` -> `Boot` `Secure Boot` -> `OS Type` -> `Other OS`
- `Advanced mode(F7)` -> `Boot` `Secure Boot` -> `Secure Boot Mode` -> `Custom`
- `Advanced mode(F7)` -> `Tool` -> `ASUS Armoury Crate` -> `Download & Install ARMOURY CRATE app` -> `Disabled`
- `AURA(F4)` -> `Aura Off`
- `ReSizable BAR` -> `ON`

#### [Home Assistant](configuration/devices/headless/tier/home-assistant/README.md)

#### Setup Plex over `http://IP:32400/web`

#### Setup Tautulli `https://tautulli.00a.ch:8181`

Set any username and password. Will be removed after restart of service.

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
    nvme-WD_BLACK_SN850X_2000GB_25256R803288_1-part2

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
  data/monitoring

zfs create \
  data/movies

zfs create \
  data/series

zfs create \
  -o quota=512G \
  data/sync
```

## disko

```console
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount ./disko/XXLPitu-Aizen.nix
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

### List hardware

```console
fwupdmgr get-devices
```

### Upgrade hardware

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
