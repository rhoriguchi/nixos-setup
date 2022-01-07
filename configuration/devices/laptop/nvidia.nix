{ pkgs, ... }: {
  hardware.nvidia = {
    modesetting.enable = true;

    # TODO needed?
    # powerManagement.enable = true;

    prime = {
      offload.enable = true;

      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec -a "$0" "$@"
    '')
  ];

  # TODO commented debug option, remove when works
  # services.xserver.logFile = "/var/log/Xorg.0.log";
}
