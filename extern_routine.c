#include <stddef.h>

void xorstr(unsigned char *bytes, int len, int randomkey)
{
	for (size_t i = 0; i < len; i++)
		bytes[i] ^= randomkey;
}

