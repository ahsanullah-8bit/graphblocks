project(GraphBlocksAndTest)
cmake_minimum_required(VERSION 2.8)

set (CMAKE_PREFIX_PATH "/home/dbulla/Qt5.5.0/5.5/gcc_64")

set(CMAKE_MODULE_PATH
    ${PROJECT_SOURCE_DIR}/cmake
    ${CMAKE_MODULE_PATH}
)

include(FindProcessorCount)
message(STATUS "used number of processor cores: " ${PROCESSOR_COUNT})

add_subdirectory(graphblockslib)
add_subdirectory(graphblockstest)

set(GRAPHBLOCKS_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/graphblockslib/include PARENT_SCOPE)
