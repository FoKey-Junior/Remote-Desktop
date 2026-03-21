cmake_minimum_required(VERSION 3.25)

if (POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

project(Remote_Desktop LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if (NOT PKG_CONFIG_EXECUTABLE)
    find_program(_PKG_CONFIG_CANDIDATE NAMES pkg-config pkgconf)
    if (_PKG_CONFIG_CANDIDATE)
        set(PKG_CONFIG_EXECUTABLE "${_PKG_CONFIG_CANDIDATE}" CACHE FILEPATH "Path to pkg-config executable")
    endif()
endif()

find_package(PkgConfig REQUIRED)
find_package(OpenSSL QUIET)

if (OpenSSL_FOUND)
    set(OPENSSL_LINK_TARGETS OpenSSL::SSL OpenSSL::Crypto)
else()
    pkg_check_modules(OPENSSL REQUIRED IMPORTED_TARGET openssl)
    set(OPENSSL_LINK_TARGETS PkgConfig::OPENSSL)
endif()

pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)
pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)

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
FetchContent_MakeAvailable(jwt-cpp)

set(CROW_BUILD_EXAMPLES OFF)
set(CROW_BUILD_TESTS OFF)
FetchContent_Declare(
        crow
        GIT_REPOSITORY https://github.com/CrowCpp/Crow.git
        GIT_TAG master
)
FetchContent_MakeAvailable(crow)

set(SOURCES
        src/main.cpp
        src/api/Router.cpp
        src/api/Registration.cpp
        src/api/Authorization.cpp
        src/Database.cpp
        src/StringUtils.cpp
        src/JwtService.cpp
)

add_executable(Remote_Desktop ${SOURCES})

target_include_directories(Remote_Desktop PRIVATE include ${ASIO_INCLUDE_DIR})

target_link_libraries(Remote_Desktop PRIVATE
        ${OPENSSL_LINK_TARGETS}
        nlohmann_json::nlohmann_json
        jwt-cpp::jwt-cpp
        Crow::Crow
        PkgConfig::SODIUM
        PkgConfig::PQXX
)

target_compile_definitions(Remote_Desktop PRIVATE PQXX_DISABLE_SOURCE_LOCATION)