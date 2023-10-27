{ pkgs, ... }: {
  environment = {
    variables.KUBE_EDITOR = "nano";

    systemPackages = [ pkgs.k9s pkgs.kubectl pkgs.kubectx pkgs.kubernetes-helm pkgs.kubeseal pkgs.nano ];
  };
}
