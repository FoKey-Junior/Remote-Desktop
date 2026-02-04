cmake_minimum_required(VERSION 3.25)
cmake_policy(SET CMP0167 NEW)

project(Remote_Desktop LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ---- Boost (headers only) ----
find_package(Boost CONFIG REQUIRED)

# ---- libsodium ----
find_package(PkgConfig REQUIRED)
pkg_check_modules(SODIUM REQUIRED libsodium)

add_executable(Remote_Desktop
        src/main.cpp
        src/api/Api.cpp
)

add_library(Sodium::Sodium INTERFACE IMPORTED)
set_target_properties(Sodium::Sodium PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${SODIUM_INCLUDE_DIRS}"
        INTERFACE_LINK_LIBRARIES      "${SODIUM_LIBRARIES}"
        INTERFACE_LINK_DIRECTORIES    "${SODIUM_LIBRARY_DIRS}"
)

target_link_libraries(Remote_Desktop PRIVATE
        Boost::boost
        Sodium::Sodium
)
