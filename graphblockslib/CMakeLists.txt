project(GraphBlocks)
cmake_minimum_required(VERSION 2.8)
aux_source_directory(. SRC_LIST)

set(CMAKE_AUTOMOC ON)
#set(CMAKE_AUTORCC ON)

find_package(Qt5Qml 5.5 REQUIRED)
find_package(Qt5Widgets 5.5 REQUIRED)
find_package(Qt5Quick 5.5 REQUIRED)

file(GLOB MyResources ${PROJECT_SOURCE_DIR}/graphblocks.qrc)
QT5_ADD_RESOURCES(MyResources_RCC ${MyResources})

#set(GRAPHBLOCKS_INCLUDE ${PROJECT_SOURCE_DIR}/include PARENT_SCOPE)
#set(GRAPHBLOCKS_INCLUDE ${PROJECT_SOURCE_DIR}/include)

file(GLOB_RECURSE GRAPHBLOCKS_QMLFILES ${PROJECT_SOURCE_DIR}/qml/*)

file(GLOB_RECURSE GRAPHBLOCKS_SOURCES ${PROJECT_SOURCE_DIR}/src/*.cpp ${PROJECT_SOURCE_DIR}/src/*.h)

add_library(${PROJECT_NAME} ${SRC_LIST} ${GRAPHBLOCKS_SOURCES} ${MyResources_RCC} )

target_link_libraries(${PROJECT_NAME} Qt5::Qml Qt5::Widgets Qt5::Quick)
target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_SOURCE_DIR}/include
                                           PRIVATE ${PROJECT_SOURCE_DIR}/src)

add_custom_target(${PROJECT_NAME}_ADDITIONAL_PROJECT_FILES ALL ${CMAKE_COMMAND} -E echo "Add qml files to project" SOURCES ${GRAPHBLOCKS_QMLFILES})
