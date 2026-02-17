cmake_minimum_required(VERSION 3.25)
if (POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

project(Remote_Desktop LANGUAGES CXX)

# -------------------------------
# C++20
# -------------------------------
set(CMAKE_CXX_STANDARD 20 CACHE STRING "C++ standard to use")
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# -------------------------------
# Найти системные библиотеки
# -------------------------------
find_package(Boost REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)

# -------------------------------
# FetchContent для сторонних библиотек
# -------------------------------
include(FetchContent)

# libpqxx
FetchContent_Declare(
        libpqxx
        GIT_REPOSITORY https://github.com/jtv/libpqxx.git
        GIT_TAG 7.8.1
)
FetchContent_MakeAvailable(libpqxx)
set(PQXX_TARGET pqxx)

# jwt-cpp
FetchContent_Declare(
        jwt-cpp
        GIT_REPOSITORY https://github.com/Thalhammer/jwt-cpp.git
        GIT_TAG v0.7.0
)
FetchContent_MakeAvailable(jwt-cpp)
set(JWT_TARGET jwt-cpp::jwt-cpp)

# nlohmann-json
FetchContent_Declare(
        nlohmann_json
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v3.11.3
)
FetchContent_MakeAvailable(nlohmann_json)

# Crow
set(CROW_BUILD_EXAMPLES OFF)
set(CROW_BUILD_TESTS OFF)
FetchContent_Declare(
        crow
        GIT_REPOSITORY https://github.com/CrowCpp/Crow.git
        GIT_TAG master
)
FetchContent_MakeAvailable(crow)

# -------------------------------
# Исходники проекта
# -------------------------------
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

# -------------------------------
# Линковка библиотек
# -------------------------------
target_link_libraries(Remote_Desktop PRIVATE
        Boost::boost
        nlohmann_json::nlohmann_json
        ${JWT_TARGET}
        Crow::Crow
        PkgConfig::SODIUM
        ${PQXX_TARGET}
)

# -------------------------------
# Отключение std::source_location для libpqxx
# -------------------------------
target_compile_definitions(Remote_Desktop PRIVATE PQXX_DISABLE_SOURCE_LOCATION)
