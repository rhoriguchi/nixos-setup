{ pkgs, config, ... }:
let
  home = config.users.users.rhoriguchi.home;

  configFile = pkgs.writeText "config" ''
    Host github.com
      User git
      IdentityFile ${home}/.ssh/github_rsa

    Host gitlab.com
      User git
      IdentityFile ${home}/.ssh/gitlab_rsa

    Host *
      User xxlpitu
      AddKeysToAgent yes
      AddressFamily any
      Compression yes
      ConnectionAttempts 3
      HashKnownHosts no
      IdentityFile ${home}/.ssh/id_rsa
      NumberOfPasswordPrompts 3
      PubkeyAuthentication yes
      ServerAliveCountMax 3
      ServerAliveInterval 10
  '';

  coreutils = pkgs.coreutils;
  openssh = pkgs.openssh;
in {
  system.activationScripts.rhoriguchiGenerateSSHConfig = ''
    ${coreutils}/bin/mkdir -pm 0700 ${home}/.ssh


    ${coreutils}/bin/cp -f ${configFile} ${home}/.ssh/config
    ${coreutils}/bin/chmod 0700 ${home}/.ssh/config


    ${coreutils}/bin/cp -f ${./keys/id_rsa} ${home}/.ssh/id_rsa
    ${coreutils}/bin/chmod 0600 ${home}/.ssh/id_rsa

    ${openssh}/bin/ssh-keygen -y -f ${home}/.ssh/id_rsa > ${home}/.ssh/id_rsa.pub
    ${coreutils}/bin/chmod 0644 ${home}/.ssh/id_rsa.pub


    ${coreutils}/bin/cp -f ${./keys/github_rsa} ${home}/.ssh/github_rsa
    ${coreutils}/bin/chmod 0600 ${home}/.ssh/github_rsa

    ${openssh}/bin/ssh-keygen -y -f ${home}/.ssh/github_rsa > ${home}/.ssh/github_rsa.pub
    ${coreutils}/bin/chmod 0644 ${home}/.ssh/github_rsa.pub


    ${coreutils}/bin/cp -f ${./keys/gitlab_rsa} ${home}/.ssh/gitlab_rsa
    ${coreutils}/bin/chmod 0600 ${home}/.ssh/gitlab_rsa

    ${openssh}/bin/ssh-keygen -y -f ${home}/.ssh/gitlab_rsa > ${home}/.ssh/gitlab_rsa.pub
    ${coreutils}/bin/chmod 0644 ${home}/.ssh/gitlab_rsa.pub


    ${coreutils}/bin/chown -R rhoriguchi:users ${home}/.ssh
  '';
}
