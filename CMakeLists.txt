cmake_minimum_required(VERSION 3.25)
if (POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

project(Remote_Desktop LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20 CACHE STRING "C++ standard to use")
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Boost REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)
<<<<<<< HEAD


include(FetchContent)

FetchContent_Declare(
        libpqxx
        GIT_REPOSITORY https://github.com/jtv/libpqxx.git
        GIT_TAG 7.8.1
)
FetchContent_MakeAvailable(libpqxx)
set(PQXX_TARGET pqxx)

FetchContent_Declare(
        jwt-cpp
        GIT_REPOSITORY https://github.com/Thalhammer/jwt-cpp.git
        GIT_TAG v0.7.0
)
FetchContent_MakeAvailable(jwt-cpp)
set(JWT_TARGET jwt-cpp::jwt-cpp)

FetchContent_Declare(
        nlohmann_json
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v3.11.3
)
FetchContent_MakeAvailable(nlohmann_json)

set(CROW_BUILD_EXAMPLES OFF)
set(CROW_BUILD_TESTS OFF)
FetchContent_Declare(
        crow
        GIT_REPOSITORY https://github.com/CrowCpp/Crow.git
        GIT_TAG master
)
FetchContent_MakeAvailable(crow)
=======
include(FetchContent)
if (USE_SYSTEM_PQXX)
    if (libpqxx_FOUND)
        set(PQXX_TARGET libpqxx::pqxx)
    else()
        pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)
        set(PQXX_TARGET PkgConfig::PQXX)
    endif()
else()
    FetchContent_Declare(
            libpqxx
            GIT_REPOSITORY https://github.com/jtv/libpqxx.git
            GIT_TAG 7.8.1
    )
    FetchContent_MakeAvailable(libpqxx)
    set(PQXX_TARGET pqxx)
endif()
if (NOT jwt-cpp_FOUND)
    pkg_check_modules(JWT QUIET IMPORTED_TARGET jwt)
endif()
>>>>>>> 87e2565 (0.6.9)

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

<<<<<<< HEAD
=======
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

>>>>>>> 87e2565 (0.6.9)
target_link_libraries(Remote_Desktop PRIVATE
        Boost::boost
        nlohmann_json::nlohmann_json
        ${JWT_TARGET}
        Crow::Crow
        PkgConfig::SODIUM
        ${PQXX_TARGET}
)

target_compile_definitions(Remote_Desktop PRIVATE PQXX_DISABLE_SOURCE_LOCATION)
