# Качает clang-format в ./tools. Не трогает сборку.
# Запуск: cmake -P scripts/install-dev.cmake

cmake_minimum_required(VERSION 3.28)

get_filename_component(ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(TOOLS "${ROOT}/tools")
file(MAKE_DIRECTORY "${TOOLS}")

set(CLANG_TOOLS_TAG "2026.07.02-e6fa8f6a")
set(CLANG_TOOLS_VERSION "22")

if(WIN32)
    set(EXE ".exe")
    set(TOOL_SUFFIX "_windows-amd64.exe")
else()
    set(EXE "")
    set(TOOL_SUFFIX "_linux-amd64")
endif()

set(FORMAT_ASSET "clang-format-${CLANG_TOOLS_VERSION}${TOOL_SUFFIX}")
set(FORMAT_EXE "${TOOLS}/clang-format${EXE}")

function(download_file url destination)
    if(EXISTS "${destination}")
        message(STATUS "Already have ${destination}")
        return()
    endif()
    message(STATUS "Downloading ${url}")
    file(DOWNLOAD "${url}" "${destination}" SHOW_PROGRESS STATUS download_status TLS_VERIFY ON)
    list(GET download_status 0 download_code)
    if(NOT download_code EQUAL 0)
        list(GET download_status 1 download_error)
        file(REMOVE "${destination}")
        message(FATAL_ERROR "Download failed: ${download_error}")
    endif()
endfunction()

set(base "https://github.com/cpp-linter/clang-tools-static-binaries/releases/download/${CLANG_TOOLS_TAG}")
download_file("${base}/${FORMAT_ASSET}" "${FORMAT_EXE}")
file(CHMOD "${FORMAT_EXE}" PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

message(STATUS "Dev tools ready in ${TOOLS}")
