cmake_minimum_required(VERSION 3.25)
project(remote_desktop LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Boost 1.87 REQUIRED COMPONENTS system)

find_package(PkgConfig REQUIRED)
pkg_check_modules(SODIUM REQUIRED libsodium)

add_executable(remote_desktop
        src/main.cpp
        src/api/Api.cpp
)

target_include_directories(remote_desktop PRIVATE
        ${Boost_INCLUDE_DIRS}
        ${SODIUM_INCLUDE_DIRS}
)


target_link_libraries(remote_desktop PRIVATE
        Boost::system
        ${SODIUM_LIBRARIES}
        /nix/store/3d0pz2rax1v3b05lwjqlm4zi6dklnhs5-libsodium-1.0.20/lib/libsodium.so
        pthread
)
