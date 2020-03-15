{ config, lib, ... }:

with lib;

{
  options.channels = {
    stable = mkOption {
      type = types.attrs;
      default = builtins.fetchGit {
        name = "nixos-20.03";
        url = https://github.com/nixos/nixpkgs-channels.git;
        ref = "refs/heads/nixos-20.03";
        rev = "730453919bdc191496eb5dda04d69c4c99c724b9";
      };
    };

    unstable = mkOption {
      type = types.attrs;
      default = builtins.fetchGit {
        name = "nixos-unstable";
        url = https://github.com/nixos/nixpkgs-channels.git;
        ref = "refs/heads/nixos-unstable";
        rev = "434ff94e73ac8a16e69f2893d7d5365d6a92bbd4";
      };
    };

    home-manager = mkOption {
      type = types.attrs;
      default = builtins.fetchGit {
        name = "home-manager";
        url = https://github.com/rycee/home-manager.git;
        ref = "refs/heads/master";
        rev = "cc386e4b3b3dbb6fb5d02e657afeacf218911d96";
      };
    };
  };

  # https://discourse.nixos.org/t/variables-for-a-system/2342/12
  config._module.args.channels = config.channels;
}
