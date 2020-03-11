{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/qemu-user.nix
  ];

  # Configure systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 1;

  # networking.hostName = "nixos"; # Define your hostname.

  # Enable CPU microcode updates
  hardware.cpu.amd.updateMicrocode = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.autorun = true;

  # The 32-bit host ID of this machine, formatted as 8 hexadecimal characters.
  # generated via "head -c 8 /etc/machine-id"
  # this is required by ZFS
  networking.hostId = "db43f9bb";

  # Enable Bluetooth support
  hardware.bluetooth.enable = true;

  # Use full PulseAudio package for Bluetooth support
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable weekly TRIM on ZFS
  services.zfs.trim.enable = true;

  # Use the amdgpu video driver
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable Freesync
  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  # Use ACO shader compiler globally
  environment.variables = {
    "RADV_PERFTEST" = "aco";
  };

  # Setup qemu user
  qemu-user.aarch64 = true;
  qemu-user.arm = true;
}
