{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  # Read the release notes before changing this.
  home.stateVersion = "20.03";

  # Needed to get the GPG password dialog to work.
  # https://github.com/NixOS/nixpkgs/issues/73332
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "curses";
  };

  # Set Git configuration.
  programs.git = {
    enable = true;
    userName = "Samuel Gräfenstein";
    userEmail = "git@samuelgrf.com";
    signing.key = "FF2458328FAF466018C6186EEF76A063F15C63C8";
    signing.signByDefault = true;
  };
}
