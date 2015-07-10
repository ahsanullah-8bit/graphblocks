project(GraphBlocksTest)
cmake_minimum_required(VERSION 2.8)
aux_source_directory(. SRC_LIST)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

include(FindProcessorCount)
message(STATUS "used number of processor cores: " ${PROCESSOR_COUNT})

find_package(Qt5Qml 5.5 REQUIRED)
find_package(Qt5Widgets 5.5 REQUIRED)
find_package(Qt5Quick 5.5 REQUIRED)

include_directories(${PROJECT_SOURCE_DIR}/src/ ${GRAPHBLOCKS_INCLUDE})

QT5_ADD_RESOURCES(GraphBlockTestResources qml.qrc)

file(GLOB_RECURSE GRAPHBLOCKS_QMLFILES ${PROJECT_SOURCE_DIR}/qml/*)

file(GLOB_RECURSE ECS_SOURCES ${PROJECT_SOURCE_DIR}/src/*.cpp)

add_executable(${PROJECT_NAME} ${SRC_LIST} ${ECS_SOURCES} ${GraphBlockTestResources} )

target_link_libraries(${PROJECT_NAME} GraphBlocks Qt5::Qml Qt5::Widgets Qt5::Quick )
add_custom_target(${PROJECT_NAME}_ADDITIONAL_PROJECT_FILES ALL ${CMAKE_COMMAND} -E echo "Add qml files to project" SOURCES ${GRAPHBLOCKS_QMLFILES})

