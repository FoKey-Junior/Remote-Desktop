cmake_minimum_required(VERSION 3.25)

set(CMAKE_POLICY_VERSION_MINIMUM 3.5)

if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

project(Remote_Desktop_Client LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

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

find_package(Qt6 REQUIRED COMPONENTS Widgets Network)

file(GLOB_RECURSE SOURCES
        src/*.cpp
)

add_executable(Remote_Desktop_Client ${SOURCES})

target_include_directories(Remote_Desktop_Client PRIVATE
        src
        include
        ${REMOTE_DESKTOP_OPENSSL_INCLUDE_DIRS}
)

target_link_libraries(Remote_Desktop_Client PRIVATE
        Qt6::Widgets
        Qt6::Network
        ${OPENSSL_LINK_TARGETS}
)

target_compile_definitions(Remote_Desktop_Client PRIVATE
        QT_NO_KEYWORDS
)