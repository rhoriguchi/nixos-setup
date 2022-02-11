{ pkgs, ... }: {
  boot = {
    # TODO remove with 5.17 kernel https://www.phoronix.com/scan.php?page=news_item&px=Linux-5.17-HWMON
    # "nct6775" currently does not supports "Asus ROG STRIX X570-E"
    kernelPatches = map (value:
      with value; {
        inherit name;
        patch = pkgs.fetchpatch {
          name = builtins.replaceStrings [ " " ":" "(" ")" "*" ] [ "_" "" "" "" "" ] value.name;
          inherit url sha256;
        };
      }) [
        {
          name = "hwmon: (nct6775) Use superio_*() function pointers in sio_data";
          url = "https://github.com/torvalds/linux/commit/2e7b9886968b89f0b4cbc59b8e6ed47fd4edd0dd.patch";
          sha256 = "sha256-wir9q20ORr0iCl7Rl3dqqWB9Z2upBQmzrOf+CYC24gY=";

        }
        {
          name = "hwmon: (nct6775) Use nct6775_*() function pointers in nct6775_data";
          url = "https://github.com/torvalds/linux/commit/4914036eb66bdffe4cf4150c7d055c18d389d398.patch";
          sha256 = "sha256-ro/p7RHw/h99VzycadoDcrxkUUD2ynRYDc+Ewb1SzZw=";

        }
        {
          name = "hwmon: (nct6775) Support access via Asus WMI";
          url = "https://github.com/torvalds/linux/commit/3fbbfc27f95530fccbcfb3a742af0bce6c59f656.patch";
          sha256 = "sha256-3JFfQRrMTDEepOdjuh2NsRLwN26Skltpyte8VRSkXUU=";

        }
        {
          name = "hwmon: (nct6775) mask out bank number in nct6775_wmi_read_value()";
          url = "https://github.com/torvalds/linux/commit/214f525255069a55b4664842c68bc15b2ee049f0.patch";
          sha256 = "sha256-tP/FOPyPjZExazSZ2+gRRw0kQ70PQ4XnBJ0/hdl/3SE=";
        }
        {
          name = "hwmon: (nct6775) Additional check for ChipID before ASUS WMI usage";
          url = "https://github.com/torvalds/linux/commit/20f2e67cbc7599217d5a764c76e9c2bbe85e3761.patch";
          sha256 = "sha256-czjEHlKOCjh4j/7GFMPd/OyZzaBfjYMpxM1dMi/5m14=";
        }
        {
          name = "hwmon: (nct6775) Fix crash in clear_caseopen";
          url = "https://github.com/torvalds/linux/commit/79da533d3cc717ccc05ddbd3190da8a72bc2408b.patch";
          sha256 = "sha256-UJlImYIkuYo0GKnE5qxyq7EztXZ5L+Ih8h9GkxaZoJE=";
        }
      ] ++ [{
        name = "Add ROG STRIX X570-E GAMING";
        patch = ./add_rog_strix_x570-e_gaming.patch;
      }];

    kernelModules = [ "corsaircpro" "k10temp" "nct6775" ];
  };

  hardware.fancontrol = {
    enable = true;

    # grep -H . /sys/class/hwmon/hwmon*/name
    # grep -H . /sys/class/hwmon/hwmon*/temp*_label
    # grep -H . /sys/class/hwmon/hwmon*/fan*_input

    # hwmon2/pwm(2) = cpu fans
    # hwmon5/pwm(1|2|3|6)   = case fans
    # UNKNOWN               = motherboard chip fan

    # hwmon1/temp1 = Tctl (cpu)
    # hwmon2/temp1 = SYSTIN (motherboard)

    config = ''
      INTERVAL=1
      DEVPATH=hwmon1=devices/pci0000:00/0000:00:18.3 hwmon2=devices/platform/nct6775.656 hwmon5=devices/pci0000:00/0000:00:01.2/0000:02:00.0/0000:03:08.0/0000:07:00.3/usb3/3-5/3-5.1/3-5.1:1.0/0003:1B1C:0C10.0005
      DEVNAME=hwmon1=k10temp hwmon2=nct6798 hwmon5=corsaircpro
      FCTEMPS= hwmon2/pwm2=hwmon1/temp1_input hwmon5/pwm1=hwmon2/temp1_input hwmon5/pwm2=hwmon2/temp1_input hwmon5/pwm3=hwmon2/temp1_input hwmon5/pwm6=hwmon2/temp1_input
      FCFANS=  hwmon2/pwm2=hwmon2/fan2_input  hwmon5/pwm1=hwmon5/fan1_input  hwmon5/pwm2=hwmon5/fan2_input  hwmon5/pwm3=hwmon5/fan3_input  hwmon5/pwm6=hwmon5/fan6_input
      MINTEMP= hwmon2/pwm2=40                 hwmon5/pwm1=45                 hwmon5/pwm2=45                 hwmon5/pwm3=45                 hwmon5/pwm6=45
      MAXTEMP= hwmon2/pwm2=80                 hwmon5/pwm1=60                 hwmon5/pwm2=60                 hwmon5/pwm3=60                 hwmon5/pwm6=60
      MINSTART=hwmon2/pwm2=20                 hwmon5/pwm1=30                 hwmon5/pwm2=30                 hwmon5/pwm3=30                 hwmon5/pwm6=30
      MINSTOP= hwmon2/pwm2=25                 hwmon5/pwm1=35                 hwmon5/pwm2=35                 hwmon5/pwm3=35                 hwmon5/pwm6=35
      MINPWM=  hwmon2/pwm2=25                 hwmon5/pwm1=35                 hwmon5/pwm2=35                 hwmon5/pwm3=35                 hwmon5/pwm6=35
      MAXPWM=  hwmon2/pwm2=160                hwmon5/pwm1=160                hwmon5/pwm2=160                hwmon5/pwm3=160                hwmon5/pwm6=160
    '';
  };
}
