
// test unit for LEA-128 block cipher
// odzhan

#include <stdio.h>

#include "lea.h"

uint8_t key[16] = 
{0x0f, 0x1e, 0x2d, 0x3c, 0x4b, 0x5a, 0x69, 0x78, 
 0x87, 0x96, 0xa5, 0xb4, 0xc3, 0xd2, 0xe1, 0xf0};
 
uint8_t plain[16] = 
{0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 
 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f};
 
uint8_t cipher[16] = 
{0x9f, 0xc8, 0x4e, 0x35, 0x28, 0xc6, 0xc6, 0x18, 
 0x55, 0x32, 0xc7, 0xa7, 0x04, 0x64, 0x8b, 0xfd};
 
int main(void)
{
  uint8_t  buf[16];
  int      equ, i;
  uint32_t subkeys[LEA128_RNDS*4];
  
  memcpy (buf, plain, 16);
  
  #ifndef SINGLE
    lea128_setkey(key, subkeys);
    lea128_encrypt(subkeys, buf);
  #else  
    lea128_encrypt_single(key, buf);
  #endif  
  
  for (i=0; i<16; i++) printf ("%02x ", buf[i]);
  equ = memcmp (buf, cipher, 16) == 0;
  
  printf ("\nEncryption test %s\n", 
      equ ? "OK" : "FAILED");
      
  return 0;
}
  

