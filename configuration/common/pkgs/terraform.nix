{ terraform_0_14, installShellFiles }:
terraform_0_14.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ installShellFiles ];

  postInstall = oldAttrs.postInstall + ''
    touch ~/.bashrc
    mkdir -p ~/.config/fish && touch ~/.config/fish/config
    touch ~/.zshrc

    $out/bin/terraform -install-autocomplete

    installShellCompletion --cmd terraform \
      --bash ~/.bashrc \
      --fish ~/.config/fish/completions/terraform.fish \
      --zsh <(sed '/bashcompinit/d' ~/.zshrc)
  '';

  # TODO might help https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/web/deno/default.nix#L59-L62

  # > cat ~/.bashrc
  # complete -C /nix/store/w59ayb7msikg2hglkbvqc6n177y2sd8a-terraform-0.14.4/bin/terraform terraform

  # > cat ~/.zshrc
  # autoload -U +X bashcompinit && bashcompinit
  # complete -o nospace -C /nix/store/w59ayb7msikg2hglkbvqc6n177y2sd8a-terraform-0.14.4/bin/terraform terraform

  # > cat ~/.config/fish/completions/terraform.fish
  # function __complete_terraform
  #     set -lx COMP_LINE (string join ' ' (commandline -o))
  #     test (commandline -ct) = ""
  #     and set COMP_LINE "$COMP_LINE "
  #     /nix/store/w59ayb7msikg2hglkbvqc6n177y2sd8a-terraform-0.14.4/bin/terraform
  # end
  # complete -c terraform -a "(__complete_terraform)"
})
