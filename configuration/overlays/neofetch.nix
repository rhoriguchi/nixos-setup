{ neofetch, fetchurl }:
neofetch.overrideAttrs (_: {
  patches = [
    (fetchurl {
      url = "https://patch-diff.githubusercontent.com/raw/dylanaraps/neofetch/pull/1873.patch";
      sha256 = "1awdm0fqp0ix6vbdx5h4llr7w23xaapvvnkn1aazc8x9lf0rg1ky";
    })
  ];
})

