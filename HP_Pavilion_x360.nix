{ config, pkgs, ... }:

{
  # The 32-bit host ID of this machine, formatted as 8 hexadecimal characters.
  # generated via "head -c 8 /etc/machine-id"
  # this is required by ZFS
  networking.hostId = "52623593";

  # Install wifi kernel module
  boot.extraModulePackages = with pkgs; [ pkgs.linuxPackages.rtl8821ce ];

  # Blacklist sensor kernel modules
  boot.blacklistedKernelModules = [ "intel_ishtp_hid" "intel_ish_ipc" ];

  # Blacklist power management for wifi card as it may cause issues
  services.tlp.extraConfig = "RUNTIME_PM_BLACKLIST='02:00.0'";

  # Install alsa-tools because it is needed to fix audio crackling
  environment.systemPackages = with pkgs; [ alsaTools ];

  # Create a systemd service to fix audio crackling on startup/resume
  systemd.services.fixaudio = {
    description = "Fix audio crackling on Realtek ALC295";
    script = "${pkgs.alsaTools}/bin/hda-verb /dev/snd/hwC[[:print:]]*D0 0x20 SET_COEF_INDEX 0x67\
              ${pkgs.alsaTools}/bin/hda-verb /dev/snd/hwC[[:print:]]*D0 0x20 SET_PROC_COEF 0x3000";
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "post-resume.target" ];
  };
}
