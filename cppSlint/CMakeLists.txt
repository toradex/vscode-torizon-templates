cmake_minimum_required(VERSION 3.21)
project(__change__ LANGUAGES CXX)

find_package(Slint QUIET)
if (NOT Slint_FOUND)
  message("Slint could not be located in the CMake module search path. Downloading it from Git and building it locally")
  include(FetchContent)
  FetchContent_Declare(
    Slint
    GIT_REPOSITORY https://github.com/slint-ui/slint.git
    # `release/1` will auto-upgrade to the latest Slint >= 1.0.0 and < 2.0.0
    # `release/1.0` will auto-upgrade to the latest Slint >= 1.0.0 and < 1.1.0
    GIT_TAG release/1
    SOURCE_SUBDIR api/cpp
  )
  FetchContent_MakeAvailable(Slint)
endif (NOT Slint_FOUND)

# Enable referenced images into the binary by default, so that deployment into docker
# is just copying the application binary.
set(DEFAULT_SLINT_EMBED_RESOURCES "embed-files")

add_executable(__change__ src/main.cpp)
target_link_libraries(__change__ PRIVATE Slint::Slint)
slint_target_sources(__change__ ui/appwindow.slint)
# On Windows, copy the Slint DLL next to the application binary so that it's found.
if (WIN32)
    add_custom_command(TARGET __change__ POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:__change__> $<TARGET_FILE_DIR:__change__> COMMAND_EXPAND_LISTS)
endif()
