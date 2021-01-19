{ terraform, installShellFiles }:
terraform.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ installShellFiles ];

  postInstall = oldAttrs.postInstall + ''
    echo "complete -C $out/bin/terraform terraform" > terraform.bash
    installShellCompletion --bash terraform.bash

    # TODO does not work

    # > terraform -install-autocomplete
    
    # > cat ~/.zshrc
    # autoload -U +X bashcompinit && bashcompinit        
    # complete -o nospace -C /usr/bin/terraform terraform

    # > cat ~/.config/fish/completions/terraform.fish
    # function __complete_terraform
    #   set -lx COMP_LINE (string join ' ' (commandline -o))
    #   test (commandline -ct) = ""
    #   and set COMP_LINE "$COMP_LINE "
    #   /usr/bin/terraform
    # end
    # complete -c terraform -a "(__complete_terraform)"

    # echo "complete -o nospace -C $out/bin/terraform terraform" > terraform.zsh
    # installShellCompletion --zsh terraform.zsh
  '';
})
