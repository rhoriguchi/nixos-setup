{ pkgs, ... }: {
  services.dnsmasq.settings.port = 5353;

  systemd.services.libvirtd-network = rec {
    after = [ "libvirtd.service" ];
    requires = after;
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.coreutils-full pkgs.gnugrep pkgs.gnused pkgs.libvirt ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };

    script = let
      xmlConfig = pkgs.writeTextFile {
        name = "libvirtd-network.xml";
        text = ''
          <network>
            <name>default</name>

            <uuid>UUID</uuid>

            <bridge name='virbr0'/>

            <forward mode='nat'/>

            <mac address="52:54:00:2d:33:8f"/>

            <port isolated='yes'/>

            <ip address='172.16.1.1' netmask='255.255.255.0'>
              <dhcp>
                <range start='172.16.1.2' end='172.16.1.254'/>
              </dhcp>
            </ip>

            <ip family='ipv6' address='2001:db8:ca2:2::1' prefix='64'>
              <dhcp>
                <range start='2001:db8:ca2:2::2' end='2001:db8:ca2:2::ff'/>
              </dhcp>
            </ip>
          </network>
        '';
        checkPhase = ''
          ${pkgs.gnused}/bin/sed "s/UUID/$(${pkgs.util-linux}/bin/uuidgen)/" $out > xmlConfig
          ${pkgs.libvirt}/bin/virt-xml-validate xmlConfig network
        '';
      };

      # TODO improve virsh net-start "${network}" || virsh net-update "${network}" modify SECTION <(sed "s/UUID/$uuid/" ${xmlFile}) --live
    in ''
      uuid="$(virsh net-uuid "default" || true)"
      virsh net-define <(sed "s/UUID/$uuid/" ${xmlConfig})

      virsh net-destroy "default" || true
      virsh net-start "default"
      virsh net-autostart --disable "default"
    '';

    preStop = ''
      while true; do
        if [ "$(virsh list --name | wc -l)" -gt 1 ]; then
          virsh net-destroy "default"
        else
          sleep 0.5
        fi
      done
    '';
  };
}
