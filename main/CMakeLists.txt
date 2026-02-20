# Register the app as an IDF component (putchar for print + Swift)
idf_component_register(
  SRCS "putchar.c"
  PRIV_INCLUDE_DIRS "."
)

idf_build_get_property(target IDF_TARGET)
idf_build_get_property(arch IDF_TARGET_ARCH)

if("${arch}" STREQUAL "xtensa")
  message(FATAL_ERROR "Not supported target: ${target}. Use RISC-V (esp32p4, esp32c6, etc.).")
endif()

# ESP32-P4 RISC-V: rv32imafc_zicsr_zifencei, ilp32f
set(march_flag "-march=rv32imafc_zicsr_zifencei")
set(mabi_flag "-mabi=ilp32f")

# Method 1: Read from IDF's cflags response file (IDF 6.0+)
if(DEFINED IDF_TOOLCHAIN_BUILD_DIR AND EXISTS "${IDF_TOOLCHAIN_BUILD_DIR}/cflags")
  file(STRINGS "${IDF_TOOLCHAIN_BUILD_DIR}/cflags" cflags_lines)
  foreach(line IN LISTS cflags_lines)
    if(line MATCHES "^-march=")
      set(march_flag "${line}")
    elseif(line MATCHES "^-mabi=")
      set(mabi_flag "${line}")
    endif()
  endforeach()
endif()

# Strip Espressif custom extensions not supported by Swift
if(march_flag)
  string(REGEX REPLACE "_x[^ ]*" "" march_flag "${march_flag}")
endif()

# Clear default COMPILE_OPTIONS (C/C++ flags Swift won't accept)
get_target_property(var ${COMPONENT_LIB} COMPILE_OPTIONS)
set_target_properties(${COMPONENT_LIB} PROPERTIES COMPILE_OPTIONS "")

# -Xcc flags for bridging header (C/IDF include paths)
set(SWIFT_INCLUDES "")
foreach(dir ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})
  string(CONCAT SWIFT_INCLUDES ${SWIFT_INCLUDES} "-Xcc " "-I${dir} ")
endforeach()
foreach(dir ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
  string(CONCAT SWIFT_INCLUDES ${SWIFT_INCLUDES} "-Xcc " "-I${dir} ")
endforeach()

# Embedded Swift: -enable-experimental-feature Embedded, optimize for size, riscv32 target
target_compile_options(${COMPONENT_LIB} PUBLIC "$<$<COMPILE_LANGUAGE:Swift>:SHELL:
  -target riscv32-none-none-eabi
  -Xfrontend -function-sections
  -enable-experimental-feature Embedded
  -wmo
  -parse-as-library
  -Osize
  -Xcc ${march_flag}
  -Xcc ${mabi_flag}
  -Xcc -fno-pic
  -Xcc -fno-pie
  -pch-output-dir ${CMAKE_BINARY_DIR}/swift_pch
  -Xfrontend -enable-single-module-llvm-emission
  ${SWIFT_INCLUDES}
  -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
>")

set(CMAKE_Swift_COMPILER_WORKS YES)
set(CMAKE_Swift_COMPILATION_MODE_DEFAULT wholemodule)
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
enable_language(Swift)

target_sources(${COMPONENT_LIB}
  PRIVATE
  main.swift
)

# Remove .swift_modhash section to avoid linker issues
add_custom_command(
  TARGET ${COMPONENT_LIB}
  POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} --remove-section .swift_modhash $<TARGET_FILE:${COMPONENT_LIB}> $<TARGET_FILE:${COMPONENT_LIB}>
)
