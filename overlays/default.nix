[
  (_: prev: {
    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=450661
    superfile = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "8bb3076ef969c704ab8eb4acef2362337d55a0e7";
        sha256 = "sha256-UtTOiPZ32o7Xmy0byCRkrt4taBnc0O/F3LG50PsTJA0=";
      }
    }/pkgs/by-name/su/superfile/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=467867
    gamedig = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "f51a8cbcfca0c5668c0c95b98b5a5921a8e88776";
        sha256 = "sha256-XyfwZpc79a+uqKx41bzCvK0UKJWlGkYqtqhAKPZbDus=";
      }
    }/pkgs/by-name/ga/gamedig/package.nix") { };

    # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=557709
    tautulli = prev.callPackage (import "${
      prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "47b032747c3efa00dcbb50704465d095241abcd5";
        sha256 = "sha256-OhrsaGD2f0FUHMr3hAqBHSI+e66ecLHSYPxqQ1c9d8Y=";
      }
    }/pkgs/by-name/ta/tautulli/package.nix") { };

    # TODO remove when fixed upstream https://github.com/NixOS/nixpkgs/issues/558302
    flashrom = prev.flashrom.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        # tests/chip.c: setup_bad_chip() stores a pointer to a stack-local
        # `mock_chip` into flashctx->chip; it dangles once the helper
        # returns, corrupting later stack allocations and causing spurious
        # test failures on aarch64-linux.
        (prev.writeText "flashrom-fix-dangling-chip-bad-pointer.patch" (
          prev.lib.concatStringsSep "\n" [
            "--- a/tests/chip.c"
            "+++ b/tests/chip.c"
            "@@ -781,7 +781,8 @@ static void setup_bad_chip(struct flashrom_flashctx *flashctx)"
            " \tg_test_write_injector = NULL;"
            " \tg_test_read_injector = NULL;"
            " \tg_test_erase_injector[0] = NULL;"
            " "
            "-\tstruct flashchip mock_chip = chip_bad;"
            "+\tstatic struct flashchip mock_chip;"
            "+\tmock_chip = chip_bad;"
            " \tconst char *param = \"\"; /* Default values for all params. */"
            " "
            " \tsetup_chip(flashctx, &mock_chip, param, NULL);"
            ""
          ]
        ))
      ];
    });

    # TODO remove when fixed upstream https://github.com/NixOS/nixpkgs/issues/560776
    vscode = prev.vscode.overrideAttrs (old: {
      postPatch = old.postPatch + ''
        ln -s node_modules resources/app/node_modules.asar.unpacked
      '';
    });
  })

  # TODO remove when resolved
  (_: prev: {
    # - This version of IDEA has multiple known security vulnerabilities, see NIXPKGS-2026-2269: https://tracker.security.nixos.org/issues/NIXPKGS-2026-2269.
    #   The package `jetbrains.idea-oss` is currently not receiving updates in nixpkgs, consider using `jetbrains.pycharm`.
    # - This version of PyCharm has multiple known security vulnerabilities, see NIXPKGS-2026-2269: https://tracker.security.nixos.org/issues/NIXPKGS-2026-2269.
    #   The package `jetbrains.pycharm-oss` is currently not receiving updates in nixpkgs, consider using `jetbrains.pycharm`.
    jetbrains = prev.jetbrains // {
      idea-oss = prev.jetbrains.idea;
      pycharm-oss = prev.jetbrains.pycharm;
    };
  })

  (_: prev: {
    wallpaper = prev.callPackage ./wallpaper { };
  })
]
