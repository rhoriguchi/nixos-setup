{ terraform, installShellFiles }:
terraform.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ installShellFiles ];

  postInstall = oldAttrs.postInstall + ''
    echo "complete -C $out/bin/terraform terraform" > terraform.bash
    installShellCompletion --bash terraform.bash

    # TODO does not work
    # echo "complete -o nospace -C $out/bin/terraform terraform" > terraform.zsh
    # installShellCompletion --zsh terraform.zsh
  '';
})
