# Home Assistant

- Create default user `admin`
- Add integrations
  - Deluge
    - Get credentials from [secret.nix](../../../../../secrets.nix)
  - Netatmo
    - Get credentials from <https://dev.netatmo.com>
  - Shelly
    - shellycolorbulb-98CDAC1F031E.iot
    - shellycolorbulb-98CDAC1F68BC.iot
  - UniFi Network

## Configure myStrom buttons

- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_blue" "http://myStrom-Button-E9DACB.iot/api/v1/device/F4CFA2E9DACB"`
- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_gray" "http://myStrom-Button-E9DA8E.iot/api/v1/device/F4CFA2E9DA8E"`
- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_orange" "http://myStrom-Button-E9DAD9.iot/api/v1/device/F4CFA2E9DAD9"`
- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_purple" "http://myStrom-Button-E9D761.iot/api/v1/device/F4CFA2E9D761"`
- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_white" "http://myStrom-Button-F8CB7A.iot/api/v1/device/CC50E3F8CB7A"`
