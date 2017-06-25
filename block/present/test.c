
// test unit for PRESENT-128
// odzhan

#include "present.h"

size_t hex2bin (void *bin, char hex[]) {
  size_t len, i;
  int x;
  uint8_t *p=(uint8_t*)bin;
  
  len = strlen (hex);
  
  if ((len & 1) != 0) {
    return 0; 
  }
  
  for (i=0; i<len; i++) {
    if (isxdigit((int)hex[i]) == 0) {
      return 0; 
    }
  }
  
  for (i=0; i<len / 2; i++) {
    sscanf (&hex[i * 2], "%2x", &x);
    p[i] = (uint8_t)x;
  } 
  return len / 2;
}

// print digest
void bin2hex (uint8_t dgst[], size_t len)
{
  size_t i;
  for (i=0; i<len; i++) {
    printf ("%02x", dgst[i]);
  }
  putchar ('\n');
}

int test(char inputStr[16], char expectedOutputStr[16], char keyStr[32]) {
  uint8_t output[8];
  uint8_t input[8];
  uint8_t expectedOutput[8];
  uint8_t key[10];
  int     i;
  
  hex2bin(input, inputStr);
  hex2bin(expectedOutput, expectedOutputStr);
  hex2bin(key, keyStr);

  present128_encryptx(key, input);

  for(i = 0; i < 8; i++) {
    if(input[i] != expectedOutput[i]) {
      printf("%i, %02X, %02X\n", i, input[i], expectedOutput[i]);
      return 0;
    }
  }  
  return 1;
}

int main(void)
{
  printf("Test e128-k00_t00.txt: %i\n", test("0000000000000000", "96db702a2e6900af", "00000000000000000000000000000000"));
  printf("Test e128-k00_tff.txt: %i\n", test("ffffffffffffffff", "3c6019e5e5edd563", "00000000000000000000000000000000"));
  printf("Test e128-kff_t00.txt: %i\n", test("0000000000000000", "13238c710272a5d8", "ffffffffffffffffffffffffffffffff"));
  printf("Test e128-kff_tff.txt: %i\n", test("ffffffffffffffff", "628d9fbd4218e5b4", "ffffffffffffffffffffffffffffffff"));
  return 0;
}
