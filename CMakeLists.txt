cmake_minimum_required(VERSION 3.5)

project(GraphBlocksAndTest)

set(CMAKE_MODULE_PATH
    ${PROJECT_SOURCE_DIR}/cmake
    ${CMAKE_MODULE_PATH}
)

include(FindProcessorCount)
message(STATUS "used number of processor cores: " ${PROCESSOR_COUNT})

add_subdirectory(graphblockslib)
add_subdirectory(graphblockstest)

set(GRAPHBLOCKS_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/graphblockslib/include PARENT_SCOPE)
