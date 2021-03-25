{
  imports = [
    "${
      fetchTarball {
        url =
          "https://github.com/nix-community/home-manager/archive/ddcd476603dfd3388b1dc8234fa9d550156a51f5.tar.gz";
        sha256 = "0amckzfnpldw8hpzgcdp8qqbd91g15dhgaw8mkkb3sghvig0380k";
      }
    }/nixos"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
