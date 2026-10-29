{
  lib,
  fetchFromGitHub,
  fetchurl,
  runCommand,
  writeText,
  patch,
  coreutils,
  glibc,
  libxkbcommon,
  libraspberrypi,
  janus-gateway,
  systemd,
  ustreamer,
  python3Packages,
  # hardware variant of the udev rules, `null` installs only the common ones
  variant ? null,
}:

let
  ustreamerPy = ustreamer.override { inherit python3Packages; };

  # kvmd reads this instead of /etc/fstab to find the MSD store
  fstab = writeText "kvmd-fstab" ''
    none /var/lib/kvmd/msd none rw,X-kvmd.otgmsd-root=/var/lib/kvmd/msd 0 0
  '';

  # janus browser client in the ES module form the PiKVM web UI expects
  janusJs =
    let
      esModulePatch =
        let
          owner = "pikvm";
          repo = "packages";
          rev = "a351061281024007d28fccc23250be7ddebb19c5";
          hash = "sha256-ppOuwsWyFDY+p2MYaKcvufroRxrWDR52MA5jB/rvxas=";
        in
        fetchurl {
          url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/packages/janus-gateway-pikvm/0001-js.patch";
          inherit hash;
        };

      adapterJs =
        let
          owner = "webrtcHacks";
          repo = "adapter";
          tag = "v9.0.1";
          hash = "sha256-qJ4ou0JzcZYb0z+094G11tQBAHOuYgP5G2qTTyYvzDw=";
        in
        fetchurl {
          url = "https://raw.githubusercontent.com/${owner}/${repo}/${tag}/release/adapter.js";
          inherit hash;
        };
    in
    runCommand "kvmd-janus-js" { nativeBuildInputs = [ patch ]; } ''
      mkdir -p html/demos $out
      cp ${janus-gateway.src}/html/demos/janus.js html/demos/janus.js
      chmod +w html/demos/janus.js

      patch -p1 -F3 < ${esModulePatch}
      cp html/demos/janus.js $out/janus.js

      cp ${adapterJs} $out/adapter.js
    '';
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "kvmd";
  version = "4.233";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pikvm";
    repo = "kvmd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u8eMsOuHlmDVKUh5qSlMCoeb85In4G/dk0rVOiLpmow=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = builtins.attrValues {
    inherit (python3Packages)
      aiofiles
      aiohttp
      async-lru
      dbus-next
      evdev
      libgpiod
      mako
      netifaces
      passlib
      pillow
      psutil
      pyotp
      pyserial
      ruamel-yaml
      setproctitle
      systemd-python
      xlib
      zstandard
      ;

    ustreamer = ustreamerPy;
  };

  postPatch = ''
    share=$out/share/kvmd

    substituteInPlace kvmd/libc.py \
      --replace-fail 'ctypes.util.find_library("c")' '"${glibc}/lib/libc.so.6"'

    substituteInPlace kvmd/keyboard/printer.py \
      --replace-fail \
        'ctypes.util.find_library("xkbcommon")' \
        '"${libxkbcommon}/lib/libxkbcommon.so.0"'

    substituteInPlace kvmd/fstab.py \
      --replace-fail 'f"{env.ETC_PREFIX}/etc/fstab"' '"${fstab}"'

    ${lib.optionalString (variant != null) ''
      substituteInPlace kvmd/apps/__init__.py \
        --replace-fail \
          '"/usr/lib/kvmd/main.yaml"' \
          "\"$share/configs.default/kvmd/main/${variant}.yaml\""
    ''}

    substituteInPlace kvmd/apps/_scheme.py \
      --replace-fail '"/usr/share/kvmd/extras"' "\"$share/extras\"" \
      --replace-fail \
        '"/usr/share/kvmd/keymaps/en-us"' \
        "\"$share/keymaps/en-us\"" \
      --replace-fail \
        '"/usr/bin/vcgencmd"' \
        '"${libraspberrypi}/bin/vcgencmd"' \
      --replace-fail '"/usr/bin/janus"' '"${janus-gateway}/bin/janus"' \
      --replace-fail \
        '--plugins-folder=/usr/lib/ustreamer/janus' \
        '--plugins-folder=${ustreamerPy}/lib/ustreamer/janus' \
      --replace-fail '"/bin/true"' '"${coreutils}/bin/true"'

    substituteInPlace configs/kvmd/main/*.yaml \
      --replace-fail '/usr/bin/ustreamer' '${ustreamerPy}/bin/ustreamer'

    substituteInPlace configs/os/udev/common.rules \
      --replace-fail '/usr/bin/systemd-escape' '${systemd}/bin/systemd-escape' \
      --replace-fail '/usr/bin/chgrp' '${coreutils}/bin/chgrp' \
      --replace-fail '/usr/bin/chmod' '${coreutils}/bin/chmod'

    # accept the capture dongle on any USB port
    substituteInPlace configs/os/udev/v2-hdmiusb-*.rules \
      --replace-fail \
        '/usr/lib/kvmd/kvmd-udev-hdmiusb-check' \
        '${coreutils}/bin/true'
  '';

  postInstall = ''
    share=$out/share/kvmd
    mkdir -p $share
    cp -r web extras $share/
    cp -r contrib/keymaps $share/keymaps
    cp -r configs $share/configs.default

    find $share/web -name '*.pug' -delete
    install -Dm444 configs/os/udev/common.rules \
      $out/lib/udev/rules.d/99-kvmd-common.rules

    ${lib.optionalString (variant != null) ''
      install -Dm444 configs/os/udev/${variant}.rules \
        $out/lib/udev/rules.d/99-kvmd.rules
    ''}

    # the web UI loads the Janus client from its own kvm folder
    install -m444 -t $share/web/share/js/kvm ${janusJs}/janus.js ${janusJs}/adapter.js
  '';

  pythonImportsCheck = [
    "kvmd"
    "kvmd.apps.kvmd"
    "kvmd.apps.otg"
    "kvmd.apps.janus"
    "kvmd.plugins.hid.otg"
    "kvmd.plugins.auth.htpasswd"
    "kvmd.plugins.atx.gpio"
    "kvmd.plugins.msd.otg"
    "kvmd.plugins.ugpio.locator"
  ];

  meta = {
    description = "The main PiKVM daemon";
    homepage = "https://github.com/pikvm/kvmd";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "kvmd";
  };
})
