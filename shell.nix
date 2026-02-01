{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.cmake
    pkgs.ninja
    pkgs.gcc
    pkgs.boost.dev
    pkgs.libsodium.dev
  ];

  shellHook = ''
    export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:${pkgs.boost.dev}/lib/cmake/Boost-1.87.0
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${pkgs.libsodium.dev}/lib/pkgconfig
  '';
}
