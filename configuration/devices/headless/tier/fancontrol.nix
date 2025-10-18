{ pkgs, ... }:
let
  # https://github.com/lm-sensors/lm-sensors/blob/master/doc/fancontrol.txt

  # grep -H . /sys/class/hwmon/hwmon*/name
  # grep -H . /sys/class/hwmon/hwmon*/temp*_label
  # grep -H . /sys/class/hwmon/hwmon*/fan*_input

  # nct6796 pwm2           = cpu fans (120 mm)
  # corsaircpro pwm(1|2|3|4|5) = case fans (140 mm)

  # k10temp temp1 = Tctl (cpu)
  # nct6796 temp1 = SYSTIN (motherboard)

  script = pkgs.writers.writePython3 "create_fancontrol_config.py" { flakeIgnore = [ "E501" ]; } ''
    import os
    from pathlib import Path

    KERNEL_MODULES = ['k10temp', 'corsaircpro', 'nct6796']

    devpath = []
    devname = []

    ids = {}

    for line in os.popen('grep -H . /sys/class/hwmon/hwmon*/name').read().split('\n')[:-1]:
        split = line.split(':')
        module_name = line.split(':')[1]

        if split[1] in KERNEL_MODULES:
            path = Path(split[0]).parent

            id = path.name
            real_path = str(path.readlink().parent.parent).split('../../')[1]

            ids[module_name] = id
            devpath.append(f'{id}={real_path}')
            devname.append(f'{id}={module_name}')

    print('INTERVAL=1')
    print()
    print(f'DEVPATH={" ".join(devpath)}')
    print(f'DEVNAME={" ".join(devname)}')
    print()
    print(f'FCTEMPS= {ids["nct6796"]}/pwm2={ids["k10temp"]}/temp1_input {ids["corsaircpro"]}/pwm1={ids["nct6796"]}/temp1_input {ids["corsaircpro"]}/pwm2={ids["nct6796"]}/temp1_input {ids["corsaircpro"]}/pwm3={ids["nct6796"]}/temp1_input {ids["corsaircpro"]}/pwm4={ids["nct6796"]}/temp1_input {ids["corsaircpro"]}/pwm5={ids["nct6796"]}/temp1_input')
    print(f'FCFANS=  {ids["nct6796"]}/pwm2={ids["nct6796"]}/fan2_input  {ids["corsaircpro"]}/pwm1={ids["corsaircpro"]}/fan1_input  {ids["corsaircpro"]}/pwm2={ids["corsaircpro"]}/fan2_input  {ids["corsaircpro"]}/pwm3={ids["corsaircpro"]}/fan3_input  {ids["corsaircpro"]}/pwm4={ids["corsaircpro"]}/fan4_input  {ids["corsaircpro"]}/pwm5={ids["corsaircpro"]}/fan5_input')
    print(f'MINTEMP= {ids["nct6796"]}/pwm2=45                 {ids["corsaircpro"]}/pwm1=45                 {ids["corsaircpro"]}/pwm2=45                 {ids["corsaircpro"]}/pwm3=45                 {ids["corsaircpro"]}/pwm4=45                 {ids["corsaircpro"]}/pwm5=45')
    print(f'MAXTEMP= {ids["nct6796"]}/pwm2=60                 {ids["corsaircpro"]}/pwm1=60                 {ids["corsaircpro"]}/pwm2=60                 {ids["corsaircpro"]}/pwm3=60                 {ids["corsaircpro"]}/pwm4=60                 {ids["corsaircpro"]}/pwm5=60')
    print(f'MINSTART={ids["nct6796"]}/pwm2=30                 {ids["corsaircpro"]}/pwm1=30                 {ids["corsaircpro"]}/pwm2=30                 {ids["corsaircpro"]}/pwm3=30                 {ids["corsaircpro"]}/pwm4=30                 {ids["corsaircpro"]}/pwm5=30')
    print(f'MINSTOP= {ids["nct6796"]}/pwm2=35                 {ids["corsaircpro"]}/pwm1=35                 {ids["corsaircpro"]}/pwm2=35                 {ids["corsaircpro"]}/pwm3=35                 {ids["corsaircpro"]}/pwm4=35                 {ids["corsaircpro"]}/pwm5=35')
    print(f'MINPWM=  {ids["nct6796"]}/pwm2=35                 {ids["corsaircpro"]}/pwm1=35                 {ids["corsaircpro"]}/pwm2=35                 {ids["corsaircpro"]}/pwm3=35                 {ids["corsaircpro"]}/pwm4=35                 {ids["corsaircpro"]}/pwm5=35')
    print(f'MAXPWM=  {ids["nct6796"]}/pwm2=160                {ids["corsaircpro"]}/pwm1=160                {ids["corsaircpro"]}/pwm2=160                {ids["corsaircpro"]}/pwm3=160                {ids["corsaircpro"]}/pwm4=160                {ids["corsaircpro"]}/pwm5=160')
  '';
in
{
  boot = {
    kernelModules = [
      "corsaircpro"
      "k10temp"
      "nct6775"
    ];

    # https://bbs.archlinux.org/viewtopic.php?pid=407959#p407959
    extraModprobeConfig = ''
      options nct6775 force_id=0xd420
    '';
  };

  systemd.services.fancontrol = {
    documentation = [ "man:fancontrol(8)" ];
    wantedBy = [ "multi-user.target" ];
    # `config.systemd.services.lm_sensors.name` does not exist
    after = [ "lm_sensors.service" ];

    path = [
      pkgs.lm_sensors
      pkgs.python3
    ];

    script = ''
      file=$(mktemp)

      ${script} > $file
      fancontrol $file
    '';

    serviceConfig.Restart = "on-abort";
  };

  # https://github.com/lm-sensors/lm-sensors/issues/172.
  powerManagement.resumeCommands = ''
    systemctl restart fancontrol.service
  '';
}
