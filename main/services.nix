{ avahi, pulseaudio-modules-bt, ... }: {

  # Enable and configure desktop environment.
  services.xserver = {

    # Enable KDE Plasma with Display Data Channel support.
    desktopManager.plasma5 = {
      enable = true;
      supportDDC = true;
    };

    # Enable SDDM session manager and log in automatically.
    displayManager = {
      sddm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "samuel";
    };
  };

  # Enable and configure PulseAudio server.
  hardware.pulseaudio = {
    enable = true;

    # TODO Remove when https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/merge_requests/473
    # is merged and in nixpkgs.
    extraModules = [ pulseaudio-modules-bt ]; # Support more Bluetooth codecs.
  };

  # Enable NetworkManager daemon.
  networking.networkmanager.enable = true;

  # Enable and configure Avahi daemon for zero-configuration networking.
  services.avahi = {
    enable = true;
    nssmdns = true;
    extraServiceFiles.ssh = "${avahi}/etc/avahi/services/ssh.service";
  };

  # Enable and configure ZFS services.
  services.zfs = {

    # To activate auto-snapshotting for a dataset run
    # `sudo zfs set com.sun:auto-snapshot=true <DATASET>`.
    autoSnapshot = {
      enable = true;
      frequent = 4; # 15 minutes
      hourly = 24;
      daily = 7;
      weekly = 0;
      monthly = 0;
    };

    # Scrub ZFS pools to verify and restore filesystem integrity.
    autoScrub = {
      enable = true;
      interval = "weekly";
    };

    # To activate trimming for a LUKS device set
    # `boot.initrd.luks.devices.<name>.allowDiscards = true`.
    trim = {
      enable = true;
      interval = "weekly";
    };
  };

  # Enable Early OOM deamon.
  services.earlyoom.enable = true;

  # Enable and configure Emacs daemon.
  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  # Enable and configure OpenSSH utilities.
  services.openssh.enable = true;
  programs.ssh = {
    startAgent = true; # Enable key manager.
    askPassword = ""; # Disable GUI password prompt.
  };

  # Enable GnuPG agent.
  programs.gnupg.agent.enable = true;

  # Enable unclutter-xfixes to hide the mouse cursor when inactive.
  services.unclutter-xfixes.enable = true;

}
