cmake_minimum_required(VERSION 3.25)
project(remote_desktop)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Пути к Homebrew Boost
set(BOOST_INCLUDEDIR "/opt/homebrew/include")
set(BOOST_LIBRARYDIR "/opt/homebrew/lib")

include_directories(${BOOST_INCLUDEDIR})
link_directories(${BOOST_LIBRARYDIR})

add_executable(remote_desktop
        src/main.cpp
        src/api/Api.cpp
)

# Линкуем boost_system через имя, без поиска файла
target_link_libraries(remote_desktop PRIVATE
        boost_system
        pthread
)

# libsodium
find_package(PkgConfig REQUIRED)
pkg_check_modules(SODIUM REQUIRED libsodium)

target_include_directories(remote_desktop PRIVATE
        ${SODIUM_INCLUDE_DIRS}
)

target_link_directories(remote_desktop PRIVATE
        ${SODIUM_LIBRARY_DIRS}
)

target_link_libraries(remote_desktop PRIVATE
        ${SODIUM_LIBRARIES}
)
