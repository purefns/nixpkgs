{ stdenv
, fetchurl
, cmake
, bash
, unzip
, glibc
, openssl
, gcc
, libGLU
, libGL
, freetype
, xorg
, alsaLib
, cairo
, libuuid
, makeWrapper
, ... }:

{ name, src, ... }:

stdenv.mkDerivation rec {

  inherit name src;

  pharo-share = import ./share.nix { inherit stdenv fetchurl unzip; };

  hardeningDisable = [ "format" "pic" ];

  nativeBuildInputs = [ unzip cmake gcc makeWrapper ];

  buildInputs = [ bash glibc openssl libGLU libGL freetype
                  xorg.libX11 xorg.libICE xorg.libSM alsaLib cairo pharo-share ];

  LD_LIBRARY_PATH = stdenv.lib.makeLibraryPath
    [ cairo libGLU libGL freetype openssl libuuid alsaLib
      xorg.libICE xorg.libSM ];

  preConfigure = ''
    cd build/
  '';

  installPhase = ''
    mkdir -p "$prefix/lib/$name"

    cd ../../results

    mv vm-display-null vm-display-null.so
    mv vm-display-X11 vm-display-X11.so
    mv vm-sound-null vm-sound-null.so
    mv vm-sound-ALSA vm-sound-ALSA.so
    mv pharo pharo-vm

    cp * "$prefix/lib/$name"

    mkdir $prefix/bin

    chmod u+w $prefix/bin
    cat > $prefix/bin/pharo-cog <<EOF
    #!${bash}/bin/bash
    # disable parameter expansion to forward all arguments unprocessed to the VM
    set -f
    exec $prefix/lib/$name/pharo-vm "\$@"
    EOF

    chmod +x $prefix/bin/pharo-cog

    # Add cairo library to the library path.
    wrapProgram $prefix/bin/pharo-cog --prefix LD_LIBRARY_PATH : ${LD_LIBRARY_PATH}

    ln -s "${pharo-share}/lib/"*.sources $prefix/lib/$name
  '';

  meta = with stdenv.lib; {
    description = "Clean and innovative Smalltalk-inspired environment";
    homepage = "https://pharo.org";
    longDescription = ''
      Pharo's goal is to deliver a clean, innovative, free open-source
      Smalltalk-inspired environment. By providing a stable and small core
      system, excellent dev tools, and maintained releases, Pharo is an
      attractive platform to build and deploy mission critical applications.

      This package provides the executable VM. You should probably not care
      about this package (which represents a packaging detail) and have a
      look at the pharo-vm-core package instead.

      Please fill bug reports on http://bugs.pharo.org under the 'Ubuntu
      packaging (ppa:pharo/stable)' project.
    '';
    license = licenses.mit;
    maintainers = [ maintainers.lukego ];
    # Pharo VM sources are packaged separately for darwin (OS X)
    platforms = stdenv.lib.filter
      (system: with stdenv.lib.systems.elaborate { inherit system; };
         isUnix && !isDarwin)
      stdenv.lib.platforms.mesaPlatforms;
  };
}
