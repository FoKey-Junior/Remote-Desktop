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

set(CMAKE_AUTOUIC_SEARCH_PATHS ${CMAKE_SOURCE_DIR}/ui)

find_package(Qt6 REQUIRED COMPONENTS Widgets Network)
find_package(OpenSSL REQUIRED)

set(src_files
        src/main.cpp
        src/start_window.cpp
        src/main_window.cpp
)

set(header_files
        include/start_window.h
        include/main_window.h
)

set(ui_files
        ui/start_window.ui
        ui/main_window.ui
)

add_executable(Remote_Desktop_Client
        ${src_files}
        ${header_files}
        ${ui_files}
)

target_include_directories(Remote_Desktop_Client PRIVATE
        src
        include
)

target_link_libraries(Remote_Desktop_Client PRIVATE
        Qt6::Widgets
        Qt6::Network
        OpenSSL::SSL
        OpenSSL::Crypto
)
