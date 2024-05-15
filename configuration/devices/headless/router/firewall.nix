let serverIp = "192.168.2.2";
in {
  # TODO add firewall rules that only allows forwarded traffic to 192.168.2.0/24
  networking.nat.forwardPorts = [
    {
      proto = "tcp";
      destination = serverIp;
      sourcePort = 25565; # Minecraft
    }
    {
      proto = "tcp";
      destination = serverIp;
      sourcePort = 32400; # Plex
    }
  ];
}
