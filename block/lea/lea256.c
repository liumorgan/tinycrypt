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
  
#include "lea.h"

#define p0 blk[0]
#define p1 blk[1]
#define p2 blk[2]
#define p3 blk[3]

#ifndef SINGLE
void lea_setkey(void *key, void *roundKeys)
{
  uint32_t *rk;
  uint32_t k0, k1, k2, k3, k4, k5, k6, k7, i, t;
  uint32_t td[8]= 
      {0xc3efe9db, 0x44626b02, 0x79e27c8a, 0x78df30ec,
       0x715ea49e, 0xc785da0a, 0xe04ef22a, 0xe5c40957};

  rk = (uint32_t*)roundKeys;
  
  k0 = ((uint32_t*)key)[0]; k1 = ((uint32_t*)key)[1];
  k2 = ((uint32_t*)key)[2]; k3 = ((uint32_t*)key)[3];
  k4 = ((uint32_t*)key)[4]; k5 = ((uint32_t*)key)[5];
  k6 = ((uint32_t*)key)[6]; k7 = ((uint32_t*)key)[7];
  
  td[1] = ROTL32(td[1], 1);
  td[2] = ROTL32(td[2], 2);
  td[3] = ROTL32(td[3], 3);
  
  for (i=0; i<LEA256_RNDS; i++, rk += 4) {
    t         = td[i & 7];
    td[i & 7] = ROTL32(t, 4);
    
    k0 = ROTL32(k0 + t, 1);
    k1 = ROTL32(k1 + ROTL32(t, 1),  3);
    k2 = ROTL32(k2 + ROTL32(t, 2),  6);
    k3 = ROTL32(k3 + ROTL32(t, 3), 11);

    rk[0] = k0; rk[1] = k1;
    rk[2] = k2; rk[3] = k3;
  }
}

void lea_encrypt(void *roundKeys, void *block)
{
  uint32_t* blk = (uint32_t*) block;
  uint32_t* rk  = (uint32_t*) roundKeys;
  uint32_t tmp;
  int8_t i;
  
  for (i=0; i<LEA128_RNDS; ++i, rk += 4) {
    p3 = ROTR32((p2 ^ rk[3]) + (p3 ^ rk[1]), 3);
    p2 = ROTR32((p1 ^ rk[2]) + (p2 ^ rk[1]), 5);
    p1 = ROTL32((p0 ^ rk[0]) + (p1 ^ rk[1]), 9);
    // rotate block 32-bits
    XCHG(p0, p1);
    XCHG(p1, p2);
    XCHG(p2, p3);
  }
}

#else
  
void lea128_encrypt(void *key, void *block) {
  uint32_t k0, k1, k2, k3, i, t;
  uint32_t *blk=(uint32_t*)block;
  uint32_t td[4]= 
      {0xc3efe9db, 0x44626b02, 0x79e27c8a, 0x78df30ec};
      
  k0 = ((uint32_t*)key)[0]; k1 = ((uint32_t*)key)[1];
  k2 = ((uint32_t*)key)[2]; k3 = ((uint32_t*)key)[3];
  
  td[1] = ROTL32(td[1], 1);
  td[2] = ROTL32(td[2], 2);
  td[3] = ROTL32(td[3], 3);
  
  for (i=0; i<LEA128_RNDS; i++) {
    t         = td[i & 3];
    td[i & 3] = ROTL32(t, 4);
    // create subkey
    k0 = ROTL32(k0 + t, 1);
    k1 = ROTL32(k1 + ROTL32(t, 1),  3);
    k2 = ROTL32(k2 + ROTL32(t, 2),  6);
    k3 = ROTL32(k3 + ROTL32(t, 3), 11);
    // encrypt block
    p3 = ROTR32((p2 ^ k3) + (p3 ^ k1), 3);
    p2 = ROTR32((p1 ^ k2) + (p2 ^ k1), 5);
    p1 = ROTL32((p0 ^ k0) + (p1 ^ k1), 9);
    // rotate block 32-bits
    XCHG(p0, p1);
    XCHG(p1, p2);
    XCHG(p2, p3);
  }
}

#endif  
