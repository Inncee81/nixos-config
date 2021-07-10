{ nixpkgs-unstable }: [

  # gimpPlugins.bimp: Init
  (import ./gimpPlugins)

  # linux_5_13: Build with LLVM and enable LTO.
  (import ./linux_5_13)

  # linuxPackages*: Overlay needed for building ZFS with LLVM.
  (import ./linuxPackages)

  # TODO Remove once https://github.com/NixOS/nixpkgs/pull/126960 is merged.
  # nixos-rebuild: Fix creating ./result symlink for flakes.
  (import ./nixos-rebuild { inherit nixpkgs-unstable; })

  # pdfsizeopt: Init
  (import ./pdfsizeopt)

  # ungoogled-chromium: Add command line arguments.
  (import ./ungoogled-chromium)

]
