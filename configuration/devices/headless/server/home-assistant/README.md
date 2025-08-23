# Home Assistant

- Add integrations
  - Discord
    - Get `API Token` from <https://discord.com/developers/applications> for `Home Assistant bot`
  - ESPHome
    - `airgradient-one.local`
  - Homekit Device
    - `DIRIGERA (Bridge)`
  - Philips Hue
    - Rename
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
    - Add device, id can be found here <https://iot.tuya.com/cloud/basic?id=p1706658370961ww5yan&deviceTab=all>
  - Shelly
    - Wake up sensor with button or wait till it shows up
- Settings to change
  - Add guest user
    - `Settings` -> `People` -> `Add person`
      - Name: `Guest`
      - Allow login: `true`
        - Password: `RANDOM_PASSWORD`
        - Local Access only: `true`
        - Administrator: `false`
    - Get ID from <https://home-assistant.00a.ch/config/users> and update `trusted_users` in [default.nix](./default.nix)
  - Setup automatic backups
    - `Settings` -> `Backups` -> `Set up backups`
  - `Profile` (bottom left user icon) -> `Advanced mode = true`
  - Delete all areas
    - `Settings` -> `Areas & zones` -> `Areas`

## Shelly

Configure:

- `shellyhtg3-34b7da8ccedc`
- `shellyhtg3-84fce639c104`

1. Open in browser:`http://HOSTNAME.local/#/settings/web-socket`
2. Outbound websocket settings
   - Enable: `true`
   - Connection type: `TLS no validation`:
   - Server: `wss://home-assistant.00a.ch/api/shelly/ws`
