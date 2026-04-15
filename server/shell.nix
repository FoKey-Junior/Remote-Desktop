{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    cmake
    gcc
    gnumake
    pkg-config

    yaml-cpp
    boost
    openssl
    yaml-cpp
    libsodium
    crow
    asio

    libpqxx
    postgresql
  ];
}
