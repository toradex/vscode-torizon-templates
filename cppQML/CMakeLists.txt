cmake_minimum_required(VERSION 3.16)
project(__change__ LANGUAGES CXX C)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_add_executable(__change__ WIN32
    main.cpp
)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(qttesting PRIVATE QT_QML_DEBUG)
endif()

set_target_properties(__change__ PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "debug"
    ARCHIVE_OUTPUT_DIRECTORY "debug"
    LIBRARY_OUTPUT_DIRECTORY "debug"
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(__change__ PRIVATE
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
)

qt6_add_qml_module(__change__
    URI __change__
    VERSION 1.0
    QML_FILES
        "QML/main.qml"
        "QML/Scene.ui.qml"
    RESOURCES
        "QML/assets/torizon-logo.png"
)


