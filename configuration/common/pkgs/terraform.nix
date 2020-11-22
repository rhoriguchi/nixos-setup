{ terraform, coreutils, installShellFiles }:
terraform.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ installShellFiles ];

  postInstall = oldAttrs.postInstall + ''
    ${coreutils}/bin/echo "complete -C $out/bin/terraform terraform" > terraform.bash
    installShellCompletion --bash terraform.bash

    # TODO does not work
    # ${coreutils}/bin/echo "complete -o nospace -C $out/bin/terraform terraform" > terraform.zsh
    # installShellCompletion --zsh terraform.zsh
  '';
})
