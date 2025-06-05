{
  boot = {
    kernelModules = [ "i915" ];

    kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  };

  services.hardware.bolt.enable = true;
}
