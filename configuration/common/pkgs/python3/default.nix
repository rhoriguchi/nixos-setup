{ python3 }:
python3.override {
  packageOverrides = self: super: {
    pymdstat = super.callPackage ./pymdstat.nix { };
  };
}
