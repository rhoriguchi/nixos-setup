{ pkgs, ... }:
let
  email = (import ../../../../secrets.nix).services.home-assistant.config.withings.email;
  password = (import ../../../../secrets.nix).services.home-assistant.config.withings.password;

  getBatteryScript = pkgs.writeText "get_battery.py" ''
    import json

    import requests

    session = requests.session()

    session.post('https://account.withings.com/connectionwou/account_login', data={
        'email': '${email}',
        'password': '${password}'
    })

    response = session.post('https://scalews.withings.com/cgi-bin/association', data={
        'action': 'getbyaccountid',
        'enrich': 't',
    })

    match = next(filter(
        lambda device: device['deviceproperties']['macaddress'] == '00:24:e4:c3:ad:d8',
        json.loads(response.content)['body']['associations']
    ))

    print(match['deviceproperties']['batterylvl'])
  '';

  pythonWithPackages = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.requests ]);
in {
  services.home-assistant.config.sensor = [{
    platform = "command_line";
    name = "Withings Body+ battery";
    scan_interval = 60 * 60;
    command = "${pythonWithPackages}/bin/python ${getBatteryScript}";
    unit_of_measurement = "%";
  }];
}
