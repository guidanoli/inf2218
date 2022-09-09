#ifndef tm_utils_h
#define tm_utils_h

#include <stddef.h>

/* Utility functions */

int tm_get_lineno();

void* tm_memdup(
	const void* mem,
	size_t size);

#endif
