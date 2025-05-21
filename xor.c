#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* simplest and naive encryption with only xor operation */
void xorstr(char *str, int len, long randomkey)
{
    for (size_t i = 0; i < len; i++) {
        str[i] ^= randomkey;
    }
    
}

int main(void)
{
    char plain[] = "plaintext";
    long randomkey = rand();
    int msg_len = strlen(plain);
    char chipertext[255] = {0};
    char decrypted[255] = {0};
    strcpy(chipertext, plain);

    printf("random key: %d\n", randomkey);
    printf("plain text: %s\n", plain);

    xorstr(chipertext, msg_len, randomkey);
    printf("XORed text: ");
    for (size_t i = 0; i < msg_len; i++)
    {
        printf("0x%02X ", (unsigned char)chipertext[i]);
    }
    puts("");

    memcpy(decrypted, chipertext, msg_len);
    xorstr(decrypted, msg_len, randomkey);
    printf("decrypted ciphertext: %s\n", decrypted);
    return 0;
}