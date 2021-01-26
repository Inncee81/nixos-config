{ config, pkgs, ... }:

{
  ##############################################################################
  ## General
  ##############################################################################

  # Set hostname.
  networking.hostName = "HPx";

  # The 32-bit host ID of this machine, formatted as 8 hexadecimal characters.
  # This is generated via `head -c 8 /etc/machine-id` and required by ZFS.
  networking.hostId = "97e4f3b3";

  # Enable systemd-boot and set timeout.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 1;

  # Enable weekly TRIM on ZFS.
  services.zfs.trim.enable = true;


  ##############################################################################
  ## Xorg & Services
  ##############################################################################

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.autorun = true;

  # Configure TLP.
  services.tlp.enable = true;
  services.tlp.settings.RUNTIME_PM_BLACKLIST = "02:00.0"; # Blacklist wifi card

  # Configure undervolting service for Intel CPUs.
  services.undervolt = {
    enable = true;
    coreOffset = -100;
    gpuOffset = -70;
    uncoreOffset = -100;
    analogioOffset = -100;
  };


  ##############################################################################
  ## Kernel & Modules
  ##############################################################################

  # Install wifi kernel module.
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821ce ];

  # Blacklist sensor kernel modules.
  boot.blacklistedKernelModules = [ "intel_ishtp_hid" "intel_ish_ipc" ];


  ##############################################################################
  ## GPU & Audio
  ##############################################################################

  # Only enable modesetting video driver, if this isn't set other unused drivers
  # are also installed.
  services.xserver.videoDrivers = [ "modesetting" ];

  # Create a systemd service to fix audio crackling on startup/resume.
  # https://bugs.launchpad.net/ubuntu/+source/alsa-driver/+bug/1648183/comments/31
  systemd.services.fixaudio = {
    description = "Audio crackling fix for Realtek ALC295";
    script = ''
      ${pkgs.alsaTools}/bin/hda-verb /dev/snd/hwC[[:print:]]*D0 0x20 SET_COEF_INDEX 0x67
      ${pkgs.alsaTools}/bin/hda-verb /dev/snd/hwC[[:print:]]*D0 0x20 SET_PROC_COEF 0x3000
    '';
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "post-resume.target" ];
  };


  ##############################################################################
  ## Other hardware
  ##############################################################################

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable Bluetooth support.
  hardware.bluetooth.enable = true;

  # Install libraries for VA-API.
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel ];
  hardware.opengl.extraPackages32 = with pkgs.driversi686Linux; [ vaapiIntel ];

  # Enable CPU microcode updates.
  hardware.cpu.intel.updateMicrocode = true;
}
