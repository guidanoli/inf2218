add_library(tm_ast STATIC
    tm_ast_destroy.c)
target_link_libraries(tm_ast tm_utils)
target_include_directories(tm_ast PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR})
