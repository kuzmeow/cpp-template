# Качает ninja и vcpkg в ./tools. Компилятор и CMake не трогает.
# Если vcpkg уже есть (образ с VCPKG_ROOT), второй раз не качает.
# Запуск: cmake -P scripts/install.cmake

cmake_minimum_required(VERSION 3.28)

get_filename_component(ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(TOOLS "${ROOT}/tools")
file(MAKE_DIRECTORY "${TOOLS}")

function(download_archive url dest marker)
    if(EXISTS "${marker}")
        message(STATUS "Already have ${marker}")
        return()
    endif()
    file(MAKE_DIRECTORY "${dest}")
    get_filename_component(name "${url}" NAME)
    set(archive "${dest}/${name}")
    message(STATUS "Downloading ${url}")
    file(DOWNLOAD "${url}" "${archive}" SHOW_PROGRESS STATUS download_status TLS_VERIFY ON)
    list(GET download_status 0 download_code)
    if(NOT download_code EQUAL 0)
        list(GET download_status 1 download_error)
        file(REMOVE "${archive}")
        message(FATAL_ERROR "Download failed: ${download_error}")
    endif()
    file(ARCHIVE_EXTRACT INPUT "${archive}" DESTINATION "${dest}")
    file(REMOVE "${archive}")
    if(NOT EXISTS "${marker}")
        message(FATAL_ERROR "Archive ${url} did not contain ${marker}")
    endif()
endfunction()

set(NINJA_VERSION "1.13.2")

if(WIN32)
    set(NINJA_URL "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-win.zip")
    set(NINJA_EXE "${TOOLS}/ninja.exe")
else()
    set(NINJA_URL "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip")
    set(NINJA_EXE "${TOOLS}/ninja")
endif()

download_archive("${NINJA_URL}" "${TOOLS}" "${NINJA_EXE}")
file(CHMOD "${NINJA_EXE}" PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

message(STATUS "Ninja ready: ${NINJA_EXE}")

set(VCPKG_TAG "2026.07.29")
# Мелкий клон в образе devcontainers не содержит baseline. Добираем историю
# с этой даты, а не весь репозиторий с 2016 года.
set(VCPKG_SHALLOW_SINCE "2026-07-01")

# SKIP_VCPKG=1 — не качать vcpkg. Если VCPKG_ROOT уже задан, берётся он.
if(DEFINED ENV{SKIP_VCPKG} AND NOT "$ENV{SKIP_VCPKG}" STREQUAL "" AND NOT "$ENV{SKIP_VCPKG}" STREQUAL "0")
    set(SKIP_VCPKG ON)
else()
    set(SKIP_VCPKG OFF)
endif()

if(SKIP_VCPKG AND DEFINED ENV{VCPKG_ROOT} AND NOT "$ENV{VCPKG_ROOT}" STREQUAL "")
    set(VCPKG_DIR "$ENV{VCPKG_ROOT}")
elseif(NOT SKIP_VCPKG)
    set(VCPKG_DIR "${TOOLS}/vcpkg")
endif()

if(DEFINED VCPKG_DIR)
if(WIN32)
    set(VCPKG_EXE "${VCPKG_DIR}/vcpkg.exe")
else()
    set(VCPKG_EXE "${VCPKG_DIR}/vcpkg")
endif()

if(EXISTS "${VCPKG_EXE}")
    execute_process(
        COMMAND git -C "${VCPKG_DIR}" rev-parse --is-shallow-repository
        OUTPUT_VARIABLE VCPKG_SHALLOW
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    if(VCPKG_SHALLOW STREQUAL "true")
        message(STATUS "Shallow vcpkg, fetching history since ${VCPKG_SHALLOW_SINCE}")
        execute_process(
            COMMAND git -C "${VCPKG_DIR}" fetch --shallow-since=${VCPKG_SHALLOW_SINCE} origin
            RESULT_VARIABLE fetch_code
        )
        if(NOT fetch_code EQUAL 0)
            message(FATAL_ERROR "git fetch --shallow-since failed")
        endif()
    endif()
else()
    message(STATUS "Cloning vcpkg ${VCPKG_TAG}")
    execute_process(
        COMMAND git clone --filter=blob:none --single-branch --branch ${VCPKG_TAG}
                https://github.com/microsoft/vcpkg.git "${VCPKG_DIR}"
        RESULT_VARIABLE clone_code
    )
    if(NOT clone_code EQUAL 0)
        message(FATAL_ERROR "git clone vcpkg failed")
    endif()
    if(WIN32)
        execute_process(
            COMMAND cmd /c bootstrap-vcpkg.bat -disableMetrics
            WORKING_DIRECTORY "${VCPKG_DIR}"
            RESULT_VARIABLE boot_code
        )
    else()
        execute_process(
            COMMAND ./bootstrap-vcpkg.sh -disableMetrics
            WORKING_DIRECTORY "${VCPKG_DIR}"
            RESULT_VARIABLE boot_code
        )
    endif()
    if(NOT boot_code EQUAL 0 OR NOT EXISTS "${VCPKG_EXE}")
        message(FATAL_ERROR "vcpkg bootstrap failed")
    endif()
endif()

message(STATUS "vcpkg ready: ${VCPKG_EXE}")
else()
    message(STATUS "vcpkg skipped")
endif()
