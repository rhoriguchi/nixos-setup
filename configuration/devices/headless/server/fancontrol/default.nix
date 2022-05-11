{ pkgs, ... }: {
  boot = {
    # TODO remove when this board is supported
    kernelPatches = [{
      name = "Add ROG STRIX X570-E GAMING";
      patch = ./add_rog_strix_x570-e_gaming.patch;
    }];

    kernelModules = [ "corsaircpro" "k10temp" "nct6775" ];
  };

  # TODO pin ids so they don't change anymore

  hardware.fancontrol = {
    # https://github.com/lm-sensors/lm-sensors/blob/master/doc/fancontrol.txt

    # grep -H . /sys/class/hwmon/hwmon*/name
    # grep -H . /sys/class/hwmon/hwmon*/temp*_label
    # grep -H . /sys/class/hwmon/hwmon*/fan*_input

    # hwmon2/pwm(2)         = cpu fans (120 mm)
    # hwmon6/pwm(1|2|3|4|5) = case fans (140 mm)
    # hwmon6/pwm(6)         = motherboard chip fan (20 mm)

    # hwmon1/temp1 = Tctl (cpu)
    # hwmon2/temp1 = SYSTIN (motherboard)

    enable = true;

    config = ''
      INTERVAL=1

      DEVPATH=hwmon1=devices/pci0000:00/0000:00:18.3 hwmon2=devices/platform/nct6775.656 hwmon6=devices/pci0000:00/0000:00:01.2/0000:02:00.0/0000:03:08.0/0000:07:00.3/usb3/3-5/3-5.1/3-5.1:1.0/0003:1B1C:0C10.0002
      DEVNAME=hwmon1=k10temp                         hwmon2=nct6798                      hwmon6=corsaircpro

      FCTEMPS= hwmon2/pwm2=hwmon1/temp1_input hwmon6/pwm1=hwmon2/temp1_input hwmon6/pwm2=hwmon2/temp1_input hwmon6/pwm3=hwmon2/temp1_input hwmon6/pwm4=hwmon2/temp1_input hwmon6/pwm5=hwmon2/temp1_input
      FCFANS=  hwmon2/pwm2=hwmon2/fan2_input  hwmon6/pwm1=hwmon6/fan1_input  hwmon6/pwm2=hwmon6/fan2_input  hwmon6/pwm3=hwmon6/fan3_input  hwmon6/pwm4=hwmon6/fan4_input  hwmon6/pwm5=hwmon6/fan5_input
      MINTEMP= hwmon2/pwm2=40                 hwmon6/pwm1=45                 hwmon6/pwm2=45                 hwmon6/pwm3=45                 hwmon6/pwm4=45                 hwmon6/pwm5=45
      MAXTEMP= hwmon2/pwm2=80                 hwmon6/pwm1=60                 hwmon6/pwm2=60                 hwmon6/pwm3=60                 hwmon6/pwm4=60                 hwmon6/pwm5=60
      MINSTART=hwmon2/pwm2=20                 hwmon6/pwm1=30                 hwmon6/pwm2=30                 hwmon6/pwm3=30                 hwmon6/pwm4=30                 hwmon6/pwm5=30
      MINSTOP= hwmon2/pwm2=25                 hwmon6/pwm1=35                 hwmon6/pwm2=35                 hwmon6/pwm3=35                 hwmon6/pwm4=35                 hwmon6/pwm5=35
      MINPWM=  hwmon2/pwm2=25                 hwmon6/pwm1=35                 hwmon6/pwm2=35                 hwmon6/pwm3=35                 hwmon6/pwm4=35                 hwmon6/pwm5=35
      MAXPWM=  hwmon2/pwm2=160                hwmon6/pwm1=160                hwmon6/pwm2=160                hwmon6/pwm3=160                hwmon6/pwm4=160                hwmon6/pwm5=160
    '';
  };
}
