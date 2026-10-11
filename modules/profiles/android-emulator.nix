{ pkgs, ... }:
let
  androidSdk =
    (pkgs.androidenv.composeAndroidPackages {
      platformVersions = [ "36" ];
      includeEmulator = true;
      includeSystemImages = true;
      systemImageTypes = [ "google_apis_playstore" ];
      abiVersions = [ "x86_64" ];
      includeNDK = false;
      includeCmake = false;
    }).androidsdk;
in
{
  nixpkgs.config.android_sdk.accept_license = true;

  environment = {
    variables.ANDROID_HOME = "${androidSdk}/libexec/android-sdk";

    systemPackages = [ androidSdk ];
  };
}
