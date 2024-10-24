# Home Assistant

- Add integrations
  - Discord
    - Get `API Token` from <https://discord.com/developers/applications> for `Home Assistant bot`
  - ESPHome
    - `airgradient-one.local`
  - IKEA Dirigera Hub Integration
    - `gw2-3fb2ef61d5a6.local`
  - Philips Hue
    - `ecb5faac6110.local`
    - Rename
      - `light.bedroom_standing_lamp`
      - `light.living_room_signe_gradient_kitchen`
      - `light.living_room_signe_gradient_window`
  - Govee lights local
    - Serial number: `C6:39:C8:35:34:31:6F:67`
      Rename: `light.bedroom_nightstand_lamp_left`
    - Serial number: `08:D5:D1:35:34:37:5C:1A`
      Rename: `light.bedroom_nightstand_lamp_right`
  - localtuya
    - More info here <https://community.home-assistant.io/t/localtuya-stadler-form-eva-humidifier/414349>
    - Get credentials from <https://iot.tuya.com/cloud/basic?id=p1706658370961ww5yan>
    - User id can be found like this <https://github.com/rospogrigio/localtuya/issues/858#issuecomment-1155201879>
    - Add device, id can be found here <https://eu.local.tuya.com/cloud/basic?id=p1706658370961ww5yan&deviceTab=all>
  - Netatmo
    - Get credentials from <https://dev.netatmo.com>
  - Shelly
    - Wake up sensor with button or wait till it shows up
- Settings to change
  - `Profile` (bottom left user icon) -> `Advanced mode = true`
  - Delete all areas
    - `Settings` -> `Areas & zones` -> `Areas`

## Configure myStrom buttons

- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_blue" "http://myStrom-Button-E9DACB.local/api/v1/device/F4CFA2E9DACB"`
- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_gray" "http://myStrom-Button-E9DA8E.local/api/v1/device/F4CFA2E9DA8E"`
- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_orange" "http://myStrom-Button-E9DAD9.local/api/v1/device/F4CFA2E9DAD9"`
- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_purple" "http://myStrom-Button-E9D761.local/api/v1/device/F4CFA2E9D761"`
- `curl -d "single=post://XXLPitu-Server.local:8123/api/webhook/mystrom_button_white" "http://myStrom-Button-F8CB7A.local/api/v1/device/CC50E3F8CB7A"`

## Shelly

Configure:

- `shellyhtg3-34b7da8ccedc.local`
- `shellyhtg3-84fce639c104.local`

1. Open in browser:`http://HOSTNAME.local/#/settings/web-socket`
2. Outbound websocket settings
   - Enable: `true`
   - Connection type: `TLS no validation`:
   - Server: `wss://home-assistant.00a.ch/api/shelly/ws`
