#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

cmake_minimum_required(VERSION 3.3)
project("thrift_code" VERSION ${PACKAGE_VERSION})
include_directories("src/thrift")
include_directories("pybind11/include")
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}  -fPIC -std=c++11") # set C++ 11
#    set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS}  -fPIC -std=c99 -Isrc ")
elseif(COMPILER_SUPPORTS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
    message( STATUS "The comipler ${CMAKE_CXX_COMIPLER} has no C++ 11 suport. Please use a different C++ comipler.")
endif()

#include_directories("thrift")
# version.h now handled via veralign.sh
#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/thrift/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/thrift/version.h)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

# create directory for thrifty and thriftl
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thrift/)

# Create flex and bison files and build the lib parse static library
BISON_TARGET(thrifty ${CMAKE_CURRENT_SOURCE_DIR}/src/thrift/thrifty.yy ${CMAKE_CURRENT_BINARY_DIR}/thrift/thrifty.cc)
FLEX_TARGET(thriftl ${CMAKE_CURRENT_SOURCE_DIR}/src/thrift/thriftl.ll ${CMAKE_CURRENT_BINARY_DIR}/thrift/thriftl.cc)
ADD_FLEX_BISON_DEPENDENCY(thriftl thrifty)

set(parse_SOURCES
        ${CMAKE_CURRENT_BINARY_DIR}/thrift/thrifty.cc
        ${CMAKE_CURRENT_BINARY_DIR}/thrift/thriftl.cc
        ${CMAKE_CURRENT_BINARY_DIR}/thrift/thrifty.hh
        )

add_library(parse STATIC ${parse_SOURCES})

# Create the thrift compiler
set(compiler_core
        src/thrift/common.cc
        src/thrift/generate/t_generator.cc
        src/thrift/parse/t_typedef.cc
        src/thrift/parse/parse.cc
        src/thrift/version.h
        )

set(thrift_SOURCES
        src/thrift/main.cc
        src/thrift/audit/t_audit.cpp
        src/thrift/thrift_generate.cpp)

set(thrift_compiler_LANGS
        )

# This macro adds an option THRIFT_COMPILER_${NAME}
# that allows enabling or disabling certain languages
macro(THRIFT_ADD_COMPILER name description initial)
    string(TOUPPER "THRIFT_COMPILER_${name}" enabler)
    set(src "src/thrift/generate/t_${name}_generator.cc")
    option(${enabler} ${description} ${initial})
    if(${enabler})
        list(APPEND thrift_SOURCES ${src})
        list(APPEND thrift_compiler_LANGS ${name})
    endif()
endmacro()

# The following compiler can be enabled or disabled
THRIFT_ADD_COMPILER(c_glib  "Enable compiler for C with Glib" ON)
THRIFT_ADD_COMPILER(cl      "Enable compiler for Common LISP" ON)
THRIFT_ADD_COMPILER(cpp     "Enable compiler for C++" ON)
THRIFT_ADD_COMPILER(d       "Enable compiler for D" ON)
THRIFT_ADD_COMPILER(dart    "Enable compiler for Dart" ON)
THRIFT_ADD_COMPILER(delphi  "Enable compiler for Delphi" ON)
THRIFT_ADD_COMPILER(erl     "Enable compiler for Erlang" ON)
THRIFT_ADD_COMPILER(go      "Enable compiler for Go" ON)
THRIFT_ADD_COMPILER(gv      "Enable compiler for GraphViz" ON)
THRIFT_ADD_COMPILER(haxe    "Enable compiler for Haxe" ON)
THRIFT_ADD_COMPILER(html    "Enable compiler for HTML Documentation" ON)
THRIFT_ADD_COMPILER(markdown "Enable compiler for Markdown Documentation" ON)
THRIFT_ADD_COMPILER(java    "Enable compiler for Java"   ON)
THRIFT_ADD_COMPILER(javame  "Enable compiler for Java ME" ON)
THRIFT_ADD_COMPILER(js      "Enable compiler for JavaScript" ON)
THRIFT_ADD_COMPILER(json    "Enable compiler for JSON" ON)
THRIFT_ADD_COMPILER(lua     "Enable compiler for Lua" ON)
THRIFT_ADD_COMPILER(netstd  "Enable compiler for .NET Standard" ON)
THRIFT_ADD_COMPILER(ocaml   "Enable compiler for OCaml" ON)
THRIFT_ADD_COMPILER(perl    "Enable compiler for Perl" ON)
THRIFT_ADD_COMPILER(php     "Enable compiler for PHP" ON)
THRIFT_ADD_COMPILER(py      "Enable compiler for Python 2.0" ON)
THRIFT_ADD_COMPILER(rb      "Enable compiler for Ruby" ON)
THRIFT_ADD_COMPILER(rs      "Enable compiler for Rust" ON)
THRIFT_ADD_COMPILER(st      "Enable compiler for Smalltalk" ON)
THRIFT_ADD_COMPILER(swift   "Enable compiler for Cocoa Swift" ON)
THRIFT_ADD_COMPILER(xml     "Enable compiler for XML" ON)
THRIFT_ADD_COMPILER(xsd     "Enable compiler for XSD" ON)

# Thrift is looking for include files in the src directory
# we also add the current binary directory for generated files
include_directories(${CMAKE_CURRENT_BINARY_DIR} src)


list(APPEND thrift_SOURCES ${compiler_core})

#add_executable(thrift ${thrift_SOURCES})
#add_library(thrift SHARED ${thrift_SOURCES})


#target_link_libraries (thrift
#        boost_python3
#        ${PYTHON_LIBRARIES}
#        ${Boost_LIBRARIES}
#        )

#include_directories("/root/miniconda3/include/python3.8/")
include_directories(${CMAKE_CURRENT_BINARY_DIR} src)
add_subdirectory(pybind11)
#add_library(thrift_code SHARE thrift_SOURCES)
pybind11_add_module(thrift_code src/thrift/main.cc ${thrift_SOURCES})
#include_directories("/usr/local/anaconda3/include/python3.8/")


set_target_properties(thrift_code PROPERTIES RUNTIME_OUTPUT_DIRECTORY bin/)
set_target_properties(thrift_code PROPERTIES OUTPUT_NAME thrift_code)

target_link_libraries(thrift_code PRIVATE parse)

add_custom_command(OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/thrift${CMAKE_EXECUTABLE_SUFFIX}"
        DEPENDS thrift_code
        COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:thrift_code>" "${CMAKE_CURRENT_SOURCE_DIR}/"
        COMMENT "Copying the thrift compiler to the source tree for use by downstream targets")
add_custom_target(copy-thrift
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/thrift${CMAKE_EXECUTABLE_SUFFIX}")

install(TARGETS thrift_code DESTINATION bin)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()


target_compile_definitions(thrift_code  PRIVATE VERSION_INFO=${EXAMPLE_VERSION_INFO})