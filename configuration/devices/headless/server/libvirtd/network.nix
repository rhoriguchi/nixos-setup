{ pkgs, ... }: {
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

            <mac address='52:54:00:2d:33:8f'/>

            <port isolated='yes'/>

            <ip address='172.16.1.1' netmask='255.255.255.0'>
              <dhcp>
                <range start='172.16.1.2' end='172.16.1.254'/>
              </dhcp>
            </ip>

            <dnsmasq:options xmlns:dnsmasq='http://libvirt.org/schemas/network/dnsmasq/1.0'>
              <dnsmasq:option value='port=9053'/>
              <dnsmasq:option value='dhcp-option=option:dns-server,172.16.1.1'/>
            </dnsmasq:options>
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
