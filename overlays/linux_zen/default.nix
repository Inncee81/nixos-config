_: prev:
with prev; {

  linux_zen = let

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

    zenCustom = linux_zen.override {
      argsOverride = rec {
        version = "5.12.13";
        modDirVersion = "${version}-zen1";

        src = fetchFromGitHub {
          owner = "zen-kernel";
          repo = "zen-kernel";
          rev = "v${modDirVersion}";
          sha256 = "sha256-rQLrC441bfknmmIR1qVvJ+x+K1xRSdmaP/QuZ1WAFqw=";
        };

        structuredExtraConfig = with lib.kernel; {

          # Preemptive kernel
          PREEMPT = lib.mkForce yes;
          PREEMPT_VOLUNTARY = lib.mkForce no;

          # Additional CPU optimizations
          #CC_OPTIMIZE_FOR_PERFORMANCE_O3 = yes;

          # BBRv2 TCP congestion control
          TCP_CONG_BBR2 = yes;
          DEFAULT_BBR2 = yes;

          # FQ-PIE packet scheduling
          NET_SCH_DEFAULT = yes;
          DEFAULT_FQ_PIE = yes;
        };

        extraMeta.branch = "${lib.versions.majorMinor version}/master";

        stdenv = stdenvClangLld;
        defconfig = "LLVM=1 LLVM_IAS=1 defconfig";
      };
    };

    configfileLto = stdenv.mkDerivation {
      pname = "linux-config-lto";
      version = zenCustom.version;

      src = zenCustom.configfile;

      dontUnpack = true;
      # TODO Test if CONFIG_EFI_MIXED is needed.
      buildPhase = ''
        install -m644 $src .config
        cp ${linux_zen.src}/scripts/config config-script
        patchShebangs config-script

        ./config-script \
          -e CONFIG_EFI_STUB \
          -e CONFIG_EFI_MIXED \
          -e CONFIG_LTO_CLANG_THIN \
          -d CONFIG_LTO_NONE \
      '';
      installPhase = "cp .config $out";
    };

    zenCustomLto = linuxManualConfig {
      inherit (zenCustom) stdenv version modDirVersion src kernelPatches isZen;
      inherit lib;
      configfile = configfileLto;
      allowImportFromDerivation = true;
    };

  in zenCustomLto.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ python3 ];

    postPatch = old.postPatch + ''
      patchShebangs scripts/jobserver-exec
      substituteInPlace Makefile \
        --replace '--build-id=none=sha1' '--build-id=none' \
        --replace \
          '--thinlto-cache-dir=$(extmod-prefix).thinlto-cache' \
          '--thinlto-cache-dir=/build/source/build/.thinlto-cache'
    '';
    dontStrip = true;

    passthru = old.passthru // { inherit (linux_zen) features; };
  });

}
