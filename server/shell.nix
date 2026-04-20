{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    cmake
    gcc
    gnumake
    pkg-config
    openssl
    libsodium
    asio
    libpqxx
    postgresql
    yaml-cpp
    nlohmann_json
    boost.dev
  ];
}
