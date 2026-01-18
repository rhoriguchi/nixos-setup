{
  services.gnome-keyring = {
    enable = true;

    components = [
      "pkcs11"
      "secrets"
    ];
  };

  programs.vscode.argvSettings.password-store = "gnome-libsecret";
}
