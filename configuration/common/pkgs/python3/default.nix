{ python3 }:
python3.override {
  packageOverrides = self: super: {
    pySMART_smartx = super.callPackage ./pySMART_smartx.nix { };
    pymdstat = super.callPackage ./pymdstat.nix { };
  };
}
