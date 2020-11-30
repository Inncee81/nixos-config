{ config, lib, pkgs, unstable, ... }:

{
  # System-wide packages to install.
  environment.systemPackages = with pkgs;
    let
      common = [
        apktool
        bat
        bind
        ddgr
        dos2unix
        fd
        file
        git
        gitAndTools.delta
        gitAndTools.gh
        gnupg
        htop
        iw
        killall
        lm_sensors
        lolcat
        lshw
        lynx
        unstable.manix # TODO Remove "unstable." on 21.03.
        ncdu
        neofetch
        nix-index
        nix-linter
        nixfmt
        nixpkgs-review
        p7zip
        patchelf
        pciutils
        python3
        qrencode
        smartmontools
        strace
        sysstat
        trash-cli
        tree
        tuir
        units
        usbutils
        wget
        whois
        youtube-dl
      ];
      noX = [
        openjdk_headless
      ];
      X = [
        android-studio
        anki
        appimage-run
        ark
        caffeine-ng
        # TODO Keep this on the most stable channel with official build settings.
        # https://github.com/NixOS/nixpkgs/pull/101467
        unstable.chromium
        filezilla
        gimp
        gwenview
        imagemagick
        inkscape
        jetbrains.idea-community
        unstable.jpexs # TODO Remove "unstable." on 21.03.
        kate
        kdialog
        keepassxc
        kwin-dynamic-workspaces
        libreoffice
        lutris
        lxqt.pavucontrol-qt
        mangohud
        mpv
        multimc
        nix-prefetch-git
        nixos-artwork.wallpapers.nineish-dark-gray
        okular
        openjdk
        # partition-manager (currently fails to build)
        unstable.pcsx2
        protontricks
        steam
        steam-run
        torbrowser
        wineWowPackages.staging # Comes with both x64 and x86 Wine.
        winetricks
        xclip
        xorg.xev
      ];
    in common ++ (if config.services.xserver.enable then X else noX);

  # Select allowed unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "android-studio-stable"
    "mfcl2700dnlpr"
    "steam"
    "steam-original"
    "steam-runtime"
  ];

  # Don't install optional default packages.
  environment.defaultPackages = [ ];

  # Install ADB and fastboot.
  programs.adb.enable = true;

  # Install GnuPG agent.
  programs.gnupg.agent.enable = true;
}
