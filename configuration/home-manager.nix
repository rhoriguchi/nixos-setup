{
  imports = [
    (let
      commit = "f911ebbec927e8e9b582f2e32e2b35f730074cfc";
      sha256 = "07qa2qkbjczj3d0m03jpw85hfj35cbjm48xhifz3viy4khjw88vl";
    in "${
      fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/${commit}.tar.gz";
        inherit sha256;
      }
    }/nixos")
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
