cmake_minimum_required(VERSION 3.28)

if(NOT DEFINED CMAKE_EXPORT_COMPILE_COMMANDS)
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endif()

project(from_python LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/out)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/out)

find_package(fmt CONFIG REQUIRED)
find_path(BEXT_DI_INCLUDE_DIR NAMES boost/di.hpp REQUIRED)

add_library(demo
    src/greeter.cpp
    src/math.cpp
)

target_include_directories(demo PUBLIC include)
target_link_libraries(demo PUBLIC fmt::fmt)

add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE demo)
target_include_directories(app SYSTEM PRIVATE "${BEXT_DI_INCLUDE_DIR}")
if(MINGW)
    target_link_options(app PRIVATE -static-libgcc -static-libstdc++)
endif()

add_custom_command(TARGET app POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy -t $<TARGET_FILE_DIR:app> $<TARGET_RUNTIME_DLLS:app>
    COMMAND_EXPAND_LISTS
)