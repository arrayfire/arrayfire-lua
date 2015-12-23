CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(ArrayFire-Lua)

SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)

OPTION(USE_LOCAL_LUA "Build Lua as external project" OFF)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules")

ADD_SUBDIRECTORY(wrapper/Lua)

########################################
# Installation
########################################
INSTALL(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/examples/"
        DESTINATION "examples"
        COMPONENT examples)

INSTALL(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/wrapper/arrayfire/"
        DESTINATION "arrayfire"
        COMPONENT scripts)
