cmake_minimum_required(VERSION 3.25)

cmake_policy(SET CMP0091 NEW)

if(LINUX)       
    # if we are building on linux check if minGW is installed 
    find_program(MINGW_GCC_PATH i686-w64-mingw32-gcc)
    if(NOT MINGW_GCC_PATH)
        message(FATAL_ERROR "You dont have the minGW library on your machine!!! \n install it to be able to compile this repository")
    else()
        set(CMAKE_SYSTEM_NAME Windows)
        set(CMAKE_SYSTEM_PROCESSOR i686)
        set(CMAKE_C_COMPILER i686-w64-mingw32-gcc)
        set(CMAKE_ASM_COMPILER i686-w64-mingw32-gcc)
    endif()    
endif()  

project(sh3proxy C ASM)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)

include_directories(include)

option(WRAP_DINPUT "if enabled build the target dinput8.dll" OFF)

set(SRC_C 
    src/anim.c
    src/get_path.c
    src/main.c
    src/patch.c
    src/sync.c
    src/video.c
)

set(SRC_ASM
    src/anim_trampl.S
    src/fov.S
    src/shadows.S
    src/sync_trampl.S
    src/video_init.S
)

add_library(d3d8 SHARED ${SRC_C} ${SRC_ASM})

if(WRAP_DINPUT)
    set_target_properties(d3d8 PROPERTIES OUTPUT_NAME "dinput8")
    target_compile_definitions(d3d8 PRIVATE WRAP_DINPUT)
else()
    set_target_properties(d3d8 PROPERTIES OUTPUT_NAME "d3d8")
endif()

target_compile_definitions(d3d8 PRIVATE -D_WIN32_WINNT=0x0600)
target_compile_options(d3d8 PRIVATE 
    $<$<COMPILE_LANGUAGE:C>:-Os -mmmx -m32 -Wall -fdiagnostics-color=auto>
    $<$<COMPILE_LANGUAGE:ASM>:-m32>
)
target_link_options(d3d8 PRIVATE 
    -m32 
    -Wl,--enable-auto-import 
    -Wl,--enable-stdcall-fixup 
    -e_DllMainCRTStartup@12 
    -static-libgcc
)
target_link_libraries(d3d8 PRIVATE winmm)

# delete the generated "lib" prefix
set_target_properties(d3d8 PROPERTIES PREFIX "")