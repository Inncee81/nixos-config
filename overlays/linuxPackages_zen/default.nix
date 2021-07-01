_: prev:
with prev; {

  linuxPackagesFor = kernel:
    (linuxPackagesFor kernel).extend (_: lprev:
      let
        mkCommonOverride = pkg:
          pkg.overrideAttrs (old: {
            buildInputs = old.buildInputs ++ [ lprev.stdenv.cc ];

            # Debugging
            configureFlags = old.configureFlags ++ [ "MAKEFLAGS=V=1" ];
            preConfigure = "set -x";
          });
      in {

        zfsStable = mkCommonOverride lprev.zfsStable;

        zfsUnstable = mkCommonOverride (lprev.zfsUnstable.overrideAttrs

          # TODO Remove this override when updating flakes.
          (_: rec {
            version = "2.1.0-rc8";

            src = fetchFromGitHub {
              owner = "zfsonlinux";
              repo = "zfs";
              rev = "zfs-${version}";
              hash = "sha256-TN0gtaVDYmevd22GXsiZHvthvN8VijUgGCyV1o1iozA=";
            };

            meta.broken = false;
          }));

      });

}
