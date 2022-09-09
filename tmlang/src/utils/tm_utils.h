#ifndef tm_utils_h
#define tm_utils_h

#include <stddef.h>
#include <stdio.h>

/* Utility functions */

int tm_get_lineno();

void* tm_memdup(
	const void* mem,
	size_t size);


#define warn(s, ...) \
	fprintf(stderr, __FILE__ ":%d: " s "\n", __LINE__, __VA_ARGS__)

#endif
