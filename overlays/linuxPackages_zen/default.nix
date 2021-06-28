_: prev:
with prev; {

  linuxPackagesFor = kernel:
    (linuxPackagesFor kernel).extend (_: lprev: {

      zfsStable = lprev.zfsStable.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ lprev.stdenv.cc ];

        # Debugging
        configureFlags = old.configureFlags ++ [ "MAKEFLAGS=V=1" ];
        preConfigure = "set -x";
      });

    });

}
