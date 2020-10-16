{ pkgs, ... }:

{
  # Use X keyboard configuration on console.
  console.useXkbConfig = true;

  # Set Zsh as default shell.
  users.defaultUserShell = pkgs.zsh;

  # Configure Zsh.
  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.plugins = [ "git" ];
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Add entries to zshrc.
    interactiveShellInit = ''
      # Use powerlevel10k theme.
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Use Zsh instead of bash for nix-shell.
      source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh

      # Automatically generate completions based on `--help` output.
      source <(cod init $$ zsh)

      # Disable less history.
      export LESSHISTFILE=/dev/null

      # Define Nix & NixOS functions.
      nrs () { sudo nixos-rebuild switch "$@" && exec zsh }
      nrt () { sudo nixos-rebuild test "$@" && exec zsh }
      nsh () { nix shell nixpkgs#"$@" }
      nshm () { nix shell nixpkgs-master#"$@" }
      nshu () { nix shell nixpkgs-unstable#"$@" }
      nus () { cd /etc/nixos && nix flake update --commit-lock-file && sudo nixos-rebuild switch "$@" && exec zsh }
      nut () { cd /etc/nixos && nix flake update --commit-lock-file && sudo nixos-rebuild test "$@" && exec zsh }
      nw () { readlink $(where "$@") }
      run () { nix run nixpkgs#"$@" }
      runm () { nix run nixpkgs-master#"$@" }
      runu () { nix run nixpkgs-unstable#"$@" }

      # Define other functions.
      e () { emacsclient -c "$@" > /dev/null & disown }
      et () { emacsclient -t "$@" }
      smart () { sudo smartctl -a "$@" | less }
    '';

    # Set shell aliases.
    shellAliases = {
      # Nix & NixOS
      n = "nix";
      nb = "nix build";
      nf = "nix flake";
      nfc = "nix flake check";
      nfu = "nix flake update";
      ng = "nix-collect-garbage";
      ngd = "sudo nix-collect-garbage -d";
      nlo = "nix-locate";
      np = "nix repl";
      nrb = "sudo nixos-rebuild boot";
      nrbu = "nixos-rebuild build";
      nse = "nix search nixpkgs";
      nsem = "nix search nixpkgs-master";
      nseu = "nix search nixpkgs-unstable";
      nsr = ''
        nix-store --gc --print-roots | \
          grep -Ev "^(/nix/var|/run/\w+-system|\{memory|\{censored)"\
      '';
      nub = "cd /etc/nixos && nix flake update --commit-lock-file && sudo nixos-rebuild boot";
      nubu = "cd /etc/nixos && nix flake update --commit-lock-file && sudo nixos-rebuild build";
      nv = "nixos-version";
      nvr = "nixos-version --revision";

      # Other
      grl = "git reflog";
      inc = ''
        if [ -n "$HISTFILE" ]; then
          echo "Enabled incognito mode" &&
          unset HISTFILE
        else
          echo "Disabled incognito mode" &&
          exec zsh
        fi\
      '';
      lvl = "echo $SHLVL";
      msg = "kdialog --msgbox";
      o = "xdg-open";
      qr = "qrencode -t UTF8";
      rb = "shutdown -r";
      rbc = "shutdown -c";
      rbn = "shutdown -r now";
      rld = "exec zsh";
      sd = "shutdown";
      sdc = "shutdown -c";
      sdn = "shutdown now";
      wtr = "curl wttr.in";
      ztr = "sudo zpool trim rpool && watch zpool status -t rpool";
    };

    # Set Zsh options.
    setOptions = [
      "HIST_FCNTL_LOCK"
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
    ];
  };

  # Override Oh My Zsh defaults.
  environment.extraInit = "export LESS='-i -F -R'";
}
