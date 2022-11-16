{ pkgs, secrets, ... }:
let
  authUrl = "https://auth.netatmo.com/access";
  apiUrl = "https://app.netatmo.net/syncapi/v1";

  getBatteryStateScript = id:
    pkgs.writeText "netatmo_get_battery_state_${id}.py" ''
      import json

      import requests

      with requests.session() as session:
          response = session.get('${authUrl}/csrf')
          csrf_token = json.loads(response.content)['token']

          session.post('${authUrl}/postlogin',
                       data={
                           'email': '${secrets.netatmo.email}',
                           'password': '${secrets.netatmo.password}',
                           'stay_logged': 'on',
                           '_token': csrf_token
                       })

          response = session.post('${apiUrl}/homestatus',
                                  headers={
                                      'Authorization': f'Bearer {session.cookies.get("netatmocomaccess_token").replace("%7C", "|")}'
                                  },
                                  json={
                                      'device_types': [
                                          'NAPlug'
                                      ],
                                      'home_id': '${secrets.netatmo.homeId}'
                                  })

          match = next(filter(
              lambda module: module['id'] == '${id}',
              json.loads(response.content)['body']['home']['modules']
          ))

          print(match['battery_state'])
    '';

  pythonWithPackages = pkgs.python3.withPackages (ps: [ ps.requests ]);

  createValveBatterySensors = map (valve: {
    platform = "command_line";
    name = valve.name;
    scan_interval = 60 * 60;
    command = "${pythonWithPackages}/bin/python ${getBatteryStateScript valve.id}";
    value_template = ''
      {% if value == 'full' %}
        100
      {% elif value == 'high' %}
        75
      {% elif value == 'medium' %}
        50
      {% elif value == 'low' %}
        25
      {% elif value == 'very_low' %}
        10
      {% endif %}
    '';
    unit_of_measurement = "%";
  });
in {
  services.home-assistant.config = {
    sensor = createValveBatterySensors [
      {
        name = "Netatmo valve living room battery";
        id = "09:00:00:14:eb:85";
      }
      {
        name = "Netatmo valve entrance hallway battery";
        id = "09:00:00:01:fe:14";
      }
      {
        name = "Netatmo valve entrance window battery";
        id = "09:00:00:02:01:91";
      }
    ];

    template = [{
      sensor = [
        {
          name = "Netatmo current temperature entrance";
          icon = "mdi:thermometer";
          state = "{{ state_attr('climate.entrance', 'current_temperature') }}";
          unit_of_measurement = "°C";
        }
        {
          name = "Netatmo current temperature living room";
          icon = "mdi:thermometer";
          state = "{{ state_attr('climate.living_room', 'current_temperature') }}";
          unit_of_measurement = "°C";
        }
      ];
    }];
  };
}
