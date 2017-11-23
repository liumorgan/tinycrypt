/**
  Copyright © 2017 Odzhan. All Rights Reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */

#include "keccak.h"

void k200_permute (void *state)
{
    uint32_t i, j, rnd;
    uint8_t  t, r, u, bc[5];
    uint8_t  *st = (uint8_t*)state;
  
    uint8_t rc[18]=
    { 0x01, 0x82, 0x8a, 0x00, 0x8b, 0x01, 0x81, 0x09, 0x8a,
      0x88, 0x09, 0x0a, 0x8b, 0x8b, 0x89, 0x03, 0x02, 0x80 };
      
    uint8_t p[24] = 
    { 10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4, 
      15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1  };
      
    uint8_t m[9] = 
    { 0, 1, 2, 3, 4, 0, 1, 2, 3};
  
    for (rnd=0; rnd<18; rnd++) {
      // Theta
      for (i=0; i<5; i++) {
        t  = st[i   ];
        t ^= st[i+ 5];      
        t ^= st[i+10];      
        t ^= st[i+15];      
        t ^= st[i+20];
        bc[i] = t;
      }
      for (i=0; i<5; i++) {
        t  = bc[m[(i + 4)]]; 
        t ^= ROTL8(bc[m[(i + 1)]], 1);
        for (j=i; j<25; j+=5) {
          st[j] ^= t;
        }
      }
      // Rho + Pi
      u = st[1];
      for (i=0, r=0; i<24; i++) {
        r += i + 1;
        u  = ROTL8(u, r & 7);
        XCHG(st[p[i]], u);
        bc[0] = u;
      }
      // Chi
      for (i=0; i<25; i+=5) {
        memcpy(&bc, &st[i], 5);
        for (j=0; j<5; j++) {
          t  = ~bc[m[(j + 1)]];
          t &=  bc[m[(j + 2)]];
          st[j + i] ^= t;
        }
      }
      // Iota
      st[0] ^= rc[rnd];
    }
}

#ifdef TEST

#include <stdio.h>

void bin2hex(uint8_t x[], int len) {
    int i;
    for (i=0; i<len; i++) {
      if ((i & 7)==0) putchar('\n');
      printf ("0x%02x,", x[i]);
    }
    putchar('\n');
}

// Keccak-f[200, 18] permutation function
// 210 bytes of x86 assembly

uint8_t tv1[]={
  0x3c,0x28,0x26,0x84,0x1c,0xb3,0x5c,0x17,
  0x1e,0xaa,0xe9,0xb8,0x11,0x13,0x4c,0xea,
  0xa3,0x85,0x2c,0x69,0xd2,0xc5,0xab,0xaf,
  0xea };

uint8_t tv2[]={
  0x1b,0xef,0x68,0x94,0x92,0xa8,0xa5,0x43,
  0xa5,0x99,0x9f,0xdb,0x83,0x4e,0x31,0x66,
  0xa1,0x4b,0xe8,0x27,0xd9,0x50,0x40,0x47,
  0x9e };
 
int main(void)
{
    uint8_t  out[25];
    int      equ;
    
    memset(out, 0, sizeof(out));
    
    k200_permute(out);
    equ = memcmp(out, tv1, sizeof(tv1))==0;
    printf("Test 1 %s\n", equ ? "OK" : "Failed"); 
    //bin2hex(out, 25);

    k200_permute(out);
    equ = memcmp(out, tv2, sizeof(tv2))==0;
    printf("Test 2 %s\n", equ ? "OK" : "Failed");
    //bin2hex(out, 25);
    
    return 0;
}
#endif