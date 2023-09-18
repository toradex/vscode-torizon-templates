cmake_minimum_required(VERSION 3.0.0)

project(__change__ VERSION 1.0 LANGUAGES CXX C)

add_executable(__change__ src/main.cpp)

set(CMAKE_SYSTEM_NAME Linux)

set_target_properties(__change__ PROPERTIES RUNTIME_OUTPUT_DIRECTORY "debug" ARCHIVE_OUTPUT_DIRECTORY "debug" LIBRARY_OUTPUT_DIRECTORY "debug")
