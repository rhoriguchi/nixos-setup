{ pkgs, ... }: {
  environment = {
    variables.KUBE_EDITOR = "nano";

    systemPackages = [ pkgs.k9s pkgs.kubernetes pkgs.kubeseal pkgs.nano ];
  };
}
