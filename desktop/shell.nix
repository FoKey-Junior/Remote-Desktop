{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    cmake
    gcc
    gnumake
    pkg-config

    qt6.qtbase
    qt6.qttools

    openssl
  ];

  shellHook = ''
    export QT_PLUGIN_PATH=${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}
  '';
}
