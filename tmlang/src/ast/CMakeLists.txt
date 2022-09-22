add_library(tm_ast STATIC
    tm_ast_destroy.c
    tm_ast_print.c
    tm_ast_bind.c
    tm_ast_jff.c
    tm_vm.c)
target_link_libraries(tm_ast tm_utils)
target_include_directories(tm_ast PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR})
