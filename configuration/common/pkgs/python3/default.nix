{ python3 }:
python3.override {
  packageOverrides = self: super: {
    pymdstat = super.callPackage ./pymdstat.nix { };
    pysmart_smartx = super.callPackage ./pysmart_smartx.nix { };
    wifi = super.callPackage ./wifi.nix { };
  };
}
