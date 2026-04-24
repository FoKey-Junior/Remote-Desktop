cmake_minimum_required(VERSION 3.25)

project(Remote_Desktop_Client LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_AUTOUIC_SEARCH_PATHS ${CMAKE_SOURCE_DIR}/ui)

find_package(Qt6 REQUIRED COMPONENTS Widgets Network)
find_package(OpenSSL REQUIRED)

file(GLOB_RECURSE SRC_FILES CONFIGURE_DEPENDS
        ${CMAKE_SOURCE_DIR}/src/*.cpp
)

file(GLOB_RECURSE HEADER_FILES CONFIGURE_DEPENDS
        ${CMAKE_SOURCE_DIR}/include/*.h
)

file(GLOB_RECURSE UI_FILES CONFIGURE_DEPENDS
        ${CMAKE_SOURCE_DIR}/ui/*.ui
)

add_executable(Remote_Desktop_Client
        ${SRC_FILES}
        ${HEADER_FILES}
        ${UI_FILES}
)

target_include_directories(Remote_Desktop_Client PRIVATE
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/include
)

target_link_libraries(Remote_Desktop_Client PRIVATE
        Qt6::Widgets
        Qt6::Network
        OpenSSL::SSL
        OpenSSL::Crypto
)

if(APPLE)
    message(STATUS "Building on macOS")
elseif(UNIX)
    message(STATUS "Building on Linux (NixOS compatible)")
endif()