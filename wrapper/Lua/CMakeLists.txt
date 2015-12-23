CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(ArrayFire_Lib)

FIND_PACKAGE(ArrayFire REQUIRED)

# OS Definitions
IF(UNIX)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -pthread -Wno-comment")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC -pthread -Wno-comment")
    ADD_DEFINITIONS(-Wall -std=c++11 -fvisibility=hidden)
ELSE() #Windows
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /bigobj")
    SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /bigobj")
ENDIF()

FIND_PACKAGE(Lua QUIET)
IF(USE_LOCAL_LUA OR NOT LUA_FOUND)
    SET(USE_LOCAL_LUA ON)
    INCLUDE(${CMAKE_MODULE_PATH}/build_lua.cmake)
ELSE()
    ADD_DEFINITIONS(-DLUA_COMPAT_MODULE)
ENDIF()

FILE(GLOB src
    "*.hpp"
    "*.h"
    "*.cpp"
    )

FILE(GLOB funcs_src
    "funcs/*.cpp"
    )

SOURCE_GROUP(funcs FILES ${funcs_src})

FILE(GLOB graphics_src
    "graphics/*.cpp"
    )

SOURCE_GROUP(graphics FILES ${graphics_src})

FILE(GLOB methods_src
    "methods/*.cpp"
    )

SOURCE_GROUP(methods FILES ${methods_src})

FILE(GLOB template_src
    "template/*.cpp")

SOURCE_GROUP(template FILES ${template_src})

INCLUDE_DIRECTORIES(${ArrayFire_INCLUDE_DIRS})
INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})

ADD_LIBRARY(arrayfire_lib SHARED
           ${src}
           ${funcs_src}
           ${graphics_src}
           ${methods_src})

TARGET_LINK_LIBRARIES(arrayfire_lib
                      ${ArrayFire_Unified_LIBRARIES}
                      ${LUA_LIBRARIES}
                      )

SET_TARGET_PROPERTIES(arrayfire_lib PROPERTIES
                      PREFIX "")

########################################
# Installation
########################################
INSTALL(TARGETS arrayfire_lib EXPORT ARRAYFIRE_LIB
        DESTINATION "./"
        COMPONENT libraries)
