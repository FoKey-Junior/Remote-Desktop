cmake_minimum_required(VERSION 3.25)
if (POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

project(Remote_Desktop LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if (APPLE)
    list(APPEND CMAKE_PREFIX_PATH
            "/opt/homebrew/opt/boost"
            "/opt/homebrew/opt/libsodium"
            "/opt/homebrew/opt/libpqxx"
            "/opt/homebrew/opt/jwt-cpp"
            "/opt/homebrew/opt/nlohmann-json"
    )
    set(ENV{PKG_CONFIG_PATH} "/opt/homebrew/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
endif()

find_package(Boost REQUIRED)
find_package(PkgConfig REQUIRED)
find_package(jwt-cpp CONFIG QUIET)
find_package(nlohmann_json CONFIG QUIET)
find_package(Crow CONFIG QUIET)
pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)
pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)
if (NOT jwt-cpp_FOUND)
    pkg_check_modules(JWT QUIET IMPORTED_TARGET jwt)
endif()

set(SOURCES
        src/main.cpp
        src/api/Router.cpp
        src/api/Registration.cpp
        src/api/Authorization.cpp
        src/Database.cpp
        src/StringUtils.cpp
)

add_executable(Remote_Desktop ${SOURCES})
target_include_directories(Remote_Desktop PRIVATE include)

include(FetchContent)

if (jwt-cpp_FOUND)
    set(JWT_TARGET jwt-cpp::jwt-cpp)
elseif (JWT_FOUND)
    set(JWT_TARGET PkgConfig::JWT)
else()
    FetchContent_Declare(
            jwt-cpp
            GIT_REPOSITORY https://github.com/Thalhammer/jwt-cpp.git
            GIT_TAG v0.7.0
    )
    FetchContent_MakeAvailable(jwt-cpp)
    set(JWT_TARGET jwt-cpp::jwt-cpp)
endif()

if (NOT nlohmann_json_FOUND)
    FetchContent_Declare(
            nlohmann_json
            GIT_REPOSITORY https://github.com/nlohmann/json.git
            GIT_TAG v3.11.3
    )
    FetchContent_MakeAvailable(nlohmann_json)
endif()

if (NOT Crow_FOUND)
    set(CROW_BUILD_EXAMPLES OFF)
    set(CROW_BUILD_TESTS OFF)
    FetchContent_Declare(
            crow
            GIT_REPOSITORY https://github.com/CrowCpp/Crow.git
            GIT_TAG master
    )
    FetchContent_MakeAvailable(crow)
endif()

target_link_libraries(Remote_Desktop PRIVATE
        Boost::boost
        nlohmann_json::nlohmann_json
        ${JWT_TARGET}
        Crow::Crow
        PkgConfig::SODIUM
        PkgConfig::PQXX
)
