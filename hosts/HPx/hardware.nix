{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.luksroot =
    { device = "/dev/disk/by-uuid/97e06f70-899d-44cf-baff-d09e5a2daa59";
      allowDiscards = true;
    };

  fileSystems."/" =
    { device = "rpool/root/nixos";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/E7F8-95F0";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-partuuid/c4114437-3b41-41c3-b005-ce9f8171815f";
        randomEncryption.enable = true;
      }
    ];

  nix.maxJobs = lib.mkDefault 8; # TODO Remove on 20.09
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
