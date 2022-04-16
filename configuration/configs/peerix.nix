{
  imports = [
    (let
      commit = "4ada6bfb74ab46740adce091271e3bd7c8ade827";
      sha256 = "13z3k77m338ls5kwf2z1hj3dka2zvc5y6hi5z8armci4r1fpwb12";
    in "${
      fetchTarball {
        url = "https://github.com/cid-chan/peerix/archive/${commit}.tar.gz";
        inherit sha256;
      }
    }/module.nix")
  ];

  services.peerix = {
    enable = true;

    openFirewall = true;
    user = "peerix";
    group = "peerix";
  };

  users = {
    users.peerix = {
      isSystemUser = true;
      group = "peerix";
    };

    groups.peerix = { };
  };
}
