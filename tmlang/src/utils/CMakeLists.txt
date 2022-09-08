add_library(tm_utils STATIC tm_utils.c)

target_include_directories(tm_utils PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR})
