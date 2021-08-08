{
  imports = [
    (let
      commit = "59be1f4983ee3689de3172716a6c7e95a6a37bb7";
      sha256 = "1q9q5aagmhmnjdx0smf7x5jw7m8fp0vxb948xn9946vkxxya7d4c";
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
