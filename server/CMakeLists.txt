cmake_minimum_required(VERSION 3.25)

if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

project(Remote_Desktop LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(FETCHCONTENT_UPDATES_DISCONNECTED ON)

# --- Asio ---
set(ASIO_INCLUDE_DIR "" CACHE PATH "Standalone Asio include directory" FORCE)
file(GLOB _asio_headers "/nix/store/*-asio-*/include/asio.hpp")
if(_asio_headers)
    list(GET _asio_headers 0 _asio_header)
    get_filename_component(ASIO_INCLUDE_DIR "${_asio_header}" DIRECTORY)
endif()
if(NOT ASIO_INCLUDE_DIR)
    find_path(ASIO_INCLUDE_DIR NAMES asio.hpp PATH_SUFFIXES include)
endif()
if(NOT ASIO_INCLUDE_DIR)
    message(FATAL_ERROR "Could not find asio.hpp")
endif()

# --- pkg-config ---
if(NOT PKG_CONFIG_EXECUTABLE)
    find_program(_PKG_CONFIG_CANDIDATE NAMES pkg-config pkgconf)
    if(_PKG_CONFIG_CANDIDATE)
        set(PKG_CONFIG_EXECUTABLE "${_PKG_CONFIG_CANDIDATE}" CACHE FILEPATH "")
    endif()
endif()
find_package(PkgConfig REQUIRED)

# --- OpenSSL ---
find_package(OpenSSL QUIET)
set(REMOTE_DESKTOP_OPENSSL_INCLUDE_DIRS "")
if(OpenSSL_FOUND)
    set(OPENSSL_LINK_TARGETS OpenSSL::SSL OpenSSL::Crypto)
    list(APPEND REMOTE_DESKTOP_OPENSSL_INCLUDE_DIRS "${OPENSSL_INCLUDE_DIR}")
else()
    pkg_check_modules(OPENSSL REQUIRED IMPORTED_TARGET openssl)
    set(OPENSSL_LINK_TARGETS PkgConfig::OPENSSL)
    list(APPEND REMOTE_DESKTOP_OPENSSL_INCLUDE_DIRS "${OPENSSL_INCLUDE_DIRS}")
endif()

# --- PostgreSQL и Sodium ---
pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)
pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)

# --- FetchContent зависимости ---
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

# --- Источники ---
set(SOURCES
    src/main.cpp
    src/api/Router.cpp
    src/api/Registration.cpp
    src/api/Authorization.cpp
    src/services/Database.cpp
    src/services/StringHandler.cpp
    src/services/JWT.cpp
)

add_executable(Remote_Desktop ${SOURCES})

target_include_directories(Remote_Desktop PRIVATE
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
    PkgConfig::SODIUM
    PkgConfig::PQXX
)

target_compile_definitions(Remote_Desktop PRIVATE
    PQXX_DISABLE_SOURCE_LOCATION
)
