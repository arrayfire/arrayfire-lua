INCLUDE(ExternalProject)

SET(prefix ${CMAKE_BINARY_DIR}/third_party/lua)

SET(lua_location "${prefix}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}lua${CMAKE_STATIC_LIBRARY_SUFFIX}")
IF(CMAKE_VERSION VERSION_LESS 3.2)
    IF(CMAKE_GENERATOR MATCHES "Ninja")
        MESSAGE(WARNING "Building forge with Ninja has known issues with CMake older than 3.2")
    endif()
    SET(byproducts)
ELSE()
    SET(byproducts BYPRODUCTS ${lua_location})
ENDIF()

IF(WIN32)
    ADD_DEFINITIONS("-DLUA_DL_DLL")
ENDIF()

# FIXME Tag forge correctly during release
ExternalProject_Add(
    lua-ext
    GIT_REPOSITORY https://github.com/LuaDist/lua.git
    GIT_TAG 5.3.2
    PATCH_COMMAND patch -p1 -t -N < ${CMAKE_MODULE_PATH}/lua_MSVC.patch
    PREFIX "${prefix}"
    INSTALL_DIR "${prefix}"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -Wno-dev "-G${CMAKE_GENERATOR}" <SOURCE_DIR>
    -DCMAKE_SOURCE_DIR:PATH=<SOURCE_DIR>
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
    -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DBUILD_SHARED_LIBS=OFF
    -DLUA_BUILD_AS_DLL=OFF
    ${byproducts}
    )

ExternalProject_Get_Property(lua-ext install_dir)
ADD_LIBRARY(lua IMPORTED STATIC)
SET_TARGET_PROPERTIES(lua PROPERTIES IMPORTED_LOCATION ${lua_location})
ADD_DEPENDENCIES(lua lua-ext)
SET(LUA_INCLUDE_DIR ${install_dir}/include)
SET(LUA_LIBRARIES lua)
SET(LUA_FOUND ON)

########################################
# Installation
########################################
INSTALL(DIRECTORY "${prefix}/bin"
        DESTINATION "lua/"
        USE_SOURCE_PERMISSIONS
        COMPONENT lua_bin)
INSTALL(DIRECTORY "${prefix}/lib"
        DESTINATION "lua/"
        USE_SOURCE_PERMISSIONS
        COMPONENT lua_lib)
INSTALL(DIRECTORY "${prefix}/include"
        DESTINATION "lua/"
        USE_SOURCE_PERMISSIONS
        COMPONENT lua_include)
