#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

void xorstr(unsigned char *bytes, int len, int randomkey)
{
	for (size_t i = 0; i < len; i++)
		bytes[i] ^= randomkey;
}

/*
* convert ascii-hex into actual byte represented by these hex
* credit: https://stackoverflow.com/a/35452093/22382954
*/
uint8_t *datahex(char *string)
{
	size_t slength = strlen(string);
	if ((slength % 2) != 0) // must be even
		return NULL;

	size_t dlength = slength / 2;

	uint8_t *data = malloc(dlength);
	memset(data, 0, dlength);

	size_t index = 0;
	while (index < slength) {
		char c = string[index];
		int value = 0;
		if (c >= '0' && c <= '9')
			value = (c - '0');
		else if (c >= 'A' && c <= 'F')
			value = (10 + (c - 'A'));
		else if (c >= 'a' && c <= 'f')
			value = (10 + (c - 'a'));
		else {
			free(data);
			return NULL;
		}

		data[(index / 2)] += value << (((index + 1) % 2) * 4);

		index++;
	}

	return data;
}
