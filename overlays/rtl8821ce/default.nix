# from https://github.com/acowley/dotfiles/blob/master/nix/rtl8821ce/default.nix
{ stdenv, fetchurl, fetchFromGitHub, fetchpatch, bc, kernel }:

stdenv.mkDerivation rec {
  name = "rtl8821ce";
  version = "${kernel.version}-20200224";

  src = fetchFromGitHub {
    owner = "tomaspinho";
    repo = "rtl8821ce";
    rev = "df0c98c00d27508381eb280d568602bd85cd8f69";
    sha256 = "1zmyxfkrzgrjh7xzfn1j1hy08321x3vrz1ih931g1q7g40wzi6zd";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = [ bc ];
  buildInputs = kernel.moduleBuildDependencies;

  prePatch = ''
    substituteInPlace ./Makefile \
      --replace /lib/modules/ "${kernel.dev}/lib/modules/" \
      --replace '$(shell uname -r)' "${kernel.modDirVersion}" \
      --replace /sbin/depmod \# \
      --replace '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  meta = {
    description = "Kernel module driver for Realtek 8821ce wireless card";
    platforms = stdenv.lib.platforms.linux;
    license = stdenv.lib.licenses.gpl2;
  };
}
