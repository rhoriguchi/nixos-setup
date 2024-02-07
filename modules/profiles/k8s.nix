{ pkgs, ... }: { environment.systemPackages = [ pkgs.k9s pkgs.kubectl pkgs.kubectx pkgs.kubernetes-helm pkgs.kubeseal ]; }
