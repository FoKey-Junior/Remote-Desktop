cmake_minimum_required(VERSION 3.25)

set(CMAKE_POLICY_VERSION_MINIMUM 3.5)

if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

project(Remote_Desktop LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON)

if(APPLE)
    message(STATUS "Building on macOS")
elseif(UNIX)
    message(STATUS "Building on Linux")
endif()

if(APPLE)
    list(APPEND CMAKE_PREFIX_PATH
            /opt/homebrew
            /usr/local
    )
endif()

find_path(ASIO_INCLUDE_DIR
        NAMES asio.hpp
        PATH_SUFFIXES include
)

if(NOT ASIO_INCLUDE_DIR AND UNIX)
    file(GLOB _asio_headers "/nix/store/*-asio-*/include/asio.hpp")
    if(_asio_headers)
        list(GET _asio_headers 0 _asio_header)
        get_filename_component(ASIO_INCLUDE_DIR "${_asio_header}" DIRECTORY)
    endif()
endif()

if(NOT ASIO_INCLUDE_DIR)
    message(FATAL_ERROR "Could not find asio.hpp")
endif()

find_program(PKG_CONFIG_EXECUTABLE NAMES pkg-config pkgconf)

if(PKG_CONFIG_EXECUTABLE)
    find_package(PkgConfig)
endif()

find_package(OpenSSL QUIET)

if(OpenSSL_FOUND)
    set(OPENSSL_LINK_TARGETS OpenSSL::SSL OpenSSL::Crypto)
    set(REMOTE_DESKTOP_OPENSSL_INCLUDE_DIRS ${OPENSSL_INCLUDE_DIR})
else()
    if(PKG_CONFIG_EXECUTABLE)
        pkg_check_modules(OPENSSL REQUIRED IMPORTED_TARGET openssl)
        set(OPENSSL_LINK_TARGETS PkgConfig::OPENSSL)
        set(REMOTE_DESKTOP_OPENSSL_INCLUDE_DIRS ${OPENSSL_INCLUDE_DIRS})
    else()
        message(FATAL_ERROR "OpenSSL not found")
    endif()
endif()

if(PKG_CONFIG_EXECUTABLE)
    pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)
    pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)
else()
    find_package(PostgreSQL REQUIRED)
    find_library(SODIUM_LIBRARY sodium REQUIRED)

    add_library(SODIUM::SODIUM UNKNOWN IMPORTED)
    set_target_properties(SODIUM::SODIUM PROPERTIES
            IMPORTED_LOCATION ${SODIUM_LIBRARY}
    )
endif()

include(FetchContent)

FetchContent_Declare(
        nlohmann_json
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v3.11.3
)
FetchContent_MakeAvailable(nlohmann_json)

FetchContent_Declare(
        jwt-cpp
        GIT_REPOSITORY https://github.com/Thalhammer/jwt-cpp.git
        GIT_TAG v0.7.0
)
set(JWT_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(JWT_BUILD_TESTS OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(jwt-cpp)

set(CROW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(CROW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
FetchContent_Declare(
        crow
        GIT_REPOSITORY https://github.com/CrowCpp/Crow.git
        GIT_TAG master
)
FetchContent_MakeAvailable(crow)

FetchContent_Declare(
        yaml-cpp
        GIT_REPOSITORY https://github.com/jbeder/yaml-cpp.git
        GIT_TAG 0.8.0
)
FetchContent_MakeAvailable(yaml-cpp)

file(GLOB_RECURSE SOURCES
        src/*.cpp
)

add_executable(Remote_Desktop ${SOURCES})

target_include_directories(Remote_Desktop PRIVATE
        src
        include
        ${ASIO_INCLUDE_DIR}
        ${REMOTE_DESKTOP_OPENSSL_INCLUDE_DIRS}
        ${PQXX_INCLUDE_DIRS}
        ${jwt-cpp_SOURCE_DIR}/include
)

target_link_libraries(Remote_Desktop PRIVATE
        ${OPENSSL_LINK_TARGETS}
        nlohmann_json::nlohmann_json
        jwt-cpp::jwt-cpp
        Crow::Crow
        yaml-cpp
)

if(PKG_CONFIG_EXECUTABLE)
    target_link_libraries(Remote_Desktop PRIVATE
            PkgConfig::SODIUM
            PkgConfig::PQXX
    )
else()
    target_link_libraries(Remote_Desktop PRIVATE
            SODIUM::SODIUM
            PostgreSQL::PostgreSQL
    )
endif()

target_compile_definitions(Remote_Desktop PRIVATE
        PQXX_DISABLE_SOURCE_LOCATION
)
