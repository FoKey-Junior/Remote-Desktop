cmake_minimum_required(VERSION 3.25)
cmake_policy(SET CMP0167 NEW)

project(Remote_Desktop LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_PREFIX_PATH "/opt/homebrew/opt/boost" "/opt/homebrew/opt/libsodium" "/opt/homebrew/opt/libpqxx")
set(ENV{PKG_CONFIG_PATH} "/opt/homebrew/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")

find_package(Boost REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)
pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)

set(SOURCES
        src/main.cpp
        src/api/Router.cpp
        src/api/registration.cpp
        src/api/authorization.cpp
        src/Database.cpp
)

add_executable(Remote_Desktop ${SOURCES})
target_include_directories(Remote_Desktop PRIVATE include)

target_link_libraries(Remote_Desktop PRIVATE
        Boost::boost
        PkgConfig::SODIUM
        PkgConfig::PQXX
)
