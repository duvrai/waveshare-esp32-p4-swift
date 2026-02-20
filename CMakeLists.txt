cmake_minimum_required(VERSION 3.29)

# Use your exact Swift 6.3-dev toolchain
set(CMAKE_Swift_COMPILER "$ENV{HOME}/.swiftly/bin/swiftc" CACHE PATH "Swift compiler for Embedded Swift")

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
idf_build_set_property(MINIMAL_BUILD ON)
project(main)
