{ unstable, ... }: {

  # Use Zen kernel for better interactive performance.
  # TODO Remove "unstable." on 21.05.
  boot.kernelPackages = unstable.linuxPackages_zen;

  # Enable support for additional filesystems.
  boot.supportedFilesystems = [ "exfat" "ntfs" "zfs" ];

  # Enable zram and use faster lzo compression.
  zramSwap.enable = true;
  zramSwap.algorithm = "lzo";

}
