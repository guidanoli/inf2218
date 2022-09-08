#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tm_utils.h"

void* tm_memdup(
	const void* mem,
	size_t size)
{
	void* new_mem = malloc(size);
	memcpy(new_mem, mem, size);
	return new_mem;
}
