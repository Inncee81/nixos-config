{ avahi, binPaths, config, flakes, lib, ... }:

with binPaths; {

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

  # Enable and configure PipeWire audio server.
  services.pipewire = let
    defaults.bluez-monitor = __fromJSON (__readFile
      "${flakes.nixpkgs}/nixos/modules/services/desktops/pipewire/bluez-monitor.conf.json");
  in {
    enable = true;
    pulse.enable = true;

    # Enable volume control via Bluetooth.
    media-session.config.bluez-monitor.rules = defaults.bluez-monitor.rules
      ++ [{
        matches = [{ "device.name" = "~bluez_card.*"; }];
        actions.update-props."bluez5.hw-volume" =
          [ "hfp_hf" "hsp_hs" "a2dp_sink" "hfp_ag" "hsp_ag" "a2dp_source" ];
      }];
  };

  # Enable NetworkManager daemon.
  networking.networkmanager.enable = true;

  # Enable and configure Avahi daemon for zero-configuration networking.
  services.avahi = {
    enable = true;
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
      weekly = 4;
      monthly = 0;
    };

    # Scrub ZFS pools to verify and restore filesystem integrity.
    autoScrub = {
      enable = true;
      interval = "Mon";
    };

    # To activate trimming for a LUKS device set
    # `boot.initrd.luks.devices.<name>.allowDiscards = true`.
    trim = {
      enable = true;
      interval = "Wed";
    };
  };

  # Wait for running ZFS operations to end before scrub & trim.
  systemd.services.zfs-scrub.serviceConfig.ExecStart =
    let scrubCfg = config.services.zfs.autoScrub;
    in lib.mkForce (lib.mkSystemdScript "zfs-scrub" ''
      for pool in ${
        if scrubCfg.pools != [ ] then
          (concatStringsSep " " scrubCfg.pools)
        else
          "$(${zpool} list -H -o name)"
      }; do
        echo Waiting for ZFS operations running on $pool to end...
        ${zpool} wait $pool
        echo Starting ZFS scrub for $pool...
        ${zpool} scrub $pool
      done
    '');

  systemd.services.zpool-trim.serviceConfig = {
    ExecStart = lib.mkForce (lib.mkSystemdScript "zpool-trim" ''
      for pool in $(${zpool} list -H -o name); do
        echo Waiting for ZFS operations running on $pool to end...
        ${zpool} wait $pool
        echo Starting TRIM operation for $pool...
        ${zpool} trim $pool
      done
    '');
    Type = "oneshot";
  };

  # Ensure one of the timers waits if run simultaneously.
  systemd.timers = {
    zfs-scrub.timerConfig.RandomizedDelaySec = 1;
    zpool-trim.timerConfig.RandomizedDelaySec = 1;
  };

  # Run Nix garbage collector automatically.
  nix.gc = {
    automatic = true;
    dates = "Fri";
    options = "--delete-old";
  };

  systemd.services.nix-gc.serviceConfig = {

    # Remove stray garbage collector roots before GC.
    ExecStartPre = lib.mkSystemdScript "nix-gc-pre" ''
      echo removing stray garbage collector roots...
      ${rm} -v $(
        ${nix-store} --gc --print-roots |
          ${cut} -f 1 -d " " |
          ${grep} '/result-\?[^-]*$'
      ) || :
    '';

    # Delete inaccessible boot entries after GC.
    ExecStopPost = lib.mkSystemdScript "nix-gc-post" ''
      echo deleting old boot entries...
      /nix/var/nix/profiles/system/bin/switch-to-configuration boot
    '';
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
  users.users = {
    samuel.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDwTxBMRYCd0AKW5vDWbOuyfevl+VH/ntDwrvFw5rbzt samuel@amethyst"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnGnsUmj08UT8r8nDfStCgDpo0e2KrhTb+69e2QKZvA samuel@beryl"
    ];
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC68A6rSbE4UeZgTLJKiIVbTgZRgeeVy8P2BWWgVbWp6 root@amethyst"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeWZ1+Yxu0qcL131/4M3o0++qNgFXANrTxSJe8JbzZa root@beryl"
    ];
  };

  # Enable GnuPG agent.
  programs.gnupg.agent.enable = true;

  # Enable unclutter-xfixes to hide the mouse cursor when inactive.
  services.unclutter-xfixes.enable = true;

}
