add_subdirectory(utils)
add_subdirectory(ast)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

set(BISON_OUTPUT_C ${CMAKE_CURRENT_BINARY_DIR}/tm.y.c)
set(BISON_OUTPUT_H ${CMAKE_CURRENT_BINARY_DIR}/tm.y.h)
if (BISON_FOUND)
    add_custom_command(
            OUTPUT ${BISON_OUTPUT_C} ${BISON_OUTPUT_H}
            COMMAND ${BISON_EXECUTABLE}
            --output=${BISON_OUTPUT_C}
            -d
            -Wcounterexamples
            ${CMAKE_CURRENT_SOURCE_DIR}/tm.y
            DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tm.y
            COMMENT "Generating tm.y.c and tm.y.h")
endif ()

set(FLEX_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/tm.l.c)
if (FLEX_FOUND)
    add_custom_command(
            OUTPUT ${FLEX_OUTPUT}
            COMMAND ${FLEX_EXECUTABLE}
            --outfile=${FLEX_OUTPUT}
            ${CMAKE_CURRENT_SOURCE_DIR}/tm.l
            DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/tm.l
            COMMENT "Generating tm.l.c")
endif ()

add_library(tm_l STATIC
        ${FLEX_OUTPUT}
        ${BISON_OUTPUT_H})

target_link_libraries(tm_l tm_utils tm_ast)

target_include_directories(tm_l PUBLIC
        ${CMAKE_CURRENT_BINARY_DIR})

add_library(tm_y STATIC
        ${BISON_OUTPUT_C}
        ${BISON_OUTPUT_H})

target_link_libraries(tm_y tm_l tm_ast)

add_subdirectory(ldb)
add_subdirectory(ydb)
add_subdirectory(jff)
add_subdirectory(repr)
