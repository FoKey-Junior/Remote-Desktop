{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    cmake
    gcc
    gnumake
    pkg-config

    boost
    openssl
    libpqxx
    libsodium
    asio
  ];
}