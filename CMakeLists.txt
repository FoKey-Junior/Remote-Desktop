cmake_minimum_required(VERSION 3.25)
project(remote_desktop LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ===== Boost (CONFIG mode, Nix-style) =====
find_package(Boost CONFIG REQUIRED COMPONENTS system)

# ===== libsodium =====
find_package(PkgConfig REQUIRED)
pkg_check_modules(SODIUM REQUIRED libsodium)

add_executable(remote_desktop
        src/main.cpp
        src/api/Api.cpp
)

target_include_directories(remote_desktop PRIVATE
        ${SODIUM_INCLUDE_DIRS}
)

target_link_libraries(remote_desktop PRIVATE
        Boost::system
        ${SODIUM_LIBRARIES}
        pthread
)
