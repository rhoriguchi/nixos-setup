{
  imports = [
    (let
      commit = "ad04237d5142f53dcba258942b78e2d2bbf210c8";
      sha256 = "08szl9a4g4xyzkvqsrrm1a0fzv05pwr97nax9hhhzhwm5vwimfcw";
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
