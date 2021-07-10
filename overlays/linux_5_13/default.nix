_: prev:
with prev; {

  linux_5_13 = let

    # Force the use of lld and other LLVM tools for LTO.
    clangLld = (buildPackages.llvmPackages_12.override {
      bootBintools = null;
      bootBintoolsNoLibc = null;
    }).clangUseLLVM;

    stdenvClangLld = let stdenv = overrideCC prev.stdenv clangLld;
    in stdenv // {
      hostPlatform = stdenv.hostPlatform // {
        linux-kernel = stdenv.hostPlatform.linux-kernel // {
          makeFlags = [ "LLVM=1" "LLVM_IAS=1" ];
        };
      };
    };

    linuxLlvm = linux_5_13.override {
      argsOverride = rec {
        stdenv = stdenvClangLld;
        defconfig = "LLVM=1 LLVM_IAS=1 defconfig";
      };
    };

    /* Modifying the config file this way is ugly.
       This is done this way, because simply doing ```
         argsOverride = {
           structuredExtraConfig = with kernel; {
             LTO_CLANG_THIN = yes;
             CONFIG_LTO_NONE = yes;
           };
         };
       ```
       in the let statement above doesn't work for some reason.
    */
    configfileLto = stdenv.mkDerivation {
      pname = "linux-config-lto";
      version = linuxLlvm.version;

      src = linuxLlvm.configfile;

      dontUnpack = true;
      buildPhase = ''
        install -m644 $src .config
        cp ${linux_zen.src}/scripts/config config-script
        patchShebangs config-script

        ./config-script \
          -e CONFIG_LTO_CLANG_THIN \
          -d CONFIG_LTO_NONE \
      '';
      installPhase = "cp .config $out";
    };

    linuxLlvmLto = linuxManualConfig {
      inherit (linuxLlvm) stdenv version modDirVersion src kernelPatches isZen;
      inherit lib;
      configfile = configfileLto;
      allowImportFromDerivation = true;
    };

  in linuxLlvmLto.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ python3 ];

    postPatch = old.postPatch + ''
      patchShebangs scripts/jobserver-exec
      substituteInPlace Makefile \
        --replace '--build-id=none=sha1' '--build-id=none' \
        --replace \
          '--thinlto-cache-dir=$(extmod-prefix).thinlto-cache' \
          '--thinlto-cache-dir=/build/source/build/.thinlto-cache'
    '';
    dontStrip = true; # TODO Check if this is actually needed.

    /* Fix multiple evaluation errors caused by modules that check
       for kernel features, for example here:
       https://github.com/NixOS/nixpkgs/blob/ced04640c7acb871b9b4c5694f51726effa14cbe/nixos/modules/hardware/opengl.nix#L132
    */
    passthru = old.passthru // { inherit (linux_5_13) features; };
  });

}
