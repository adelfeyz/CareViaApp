# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(smartring_plugin_library VERSION 0.0.1 LANGUAGES C)

add_library(smartring_plugin SHARED
  "smartring_plugin.c"
)

set_target_properties(smartring_plugin PROPERTIES
  PUBLIC_HEADER smartring_plugin.h
  OUTPUT_NAME "smartring_plugin"
)

target_include_directories(smartring_plugin PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/lib)

target_link_libraries(smartring_plugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/lib/${ANDROID_ABI}/libringoem.so)
target_link_libraries(smartring_plugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/lib/${ANDROID_ABI}/libringalgorithm.so)
target_link_libraries(smartring_plugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/lib/${ANDROID_ABI}/libsleepstaging.so)
# target_link_libraries(smartring_plugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/lib/${ANDROID_ABI}/libnexringsleepstaging.so)
target_compile_definitions(smartring_plugin PUBLIC DART_SHARED_LIB)
