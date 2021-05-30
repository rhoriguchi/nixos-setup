{
  imports = [
    (let
      commit = "0e329cee4c17fa0b7df32233513b9cb2236d382b";
      sha256 = "04vzs0ixpcckjbzs6sr012l6qw78qrj3w29jskqkw211b6zw8qwy";
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

    users.rhoriguchi = {
      news.display = "silent";

      manual = {
        html.enable = false;
        json.enable = false;
      };
    };
  };
}
