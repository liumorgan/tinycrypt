/**
  Copyright � 2017 Odzhan. All Rights Reserved.

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

#include "speck.h"
#include "lightmac.h"
 
typedef union _bc_blk_t {
  uint32_t ctr;
  uint32_t w[BLOCK_LENGTH/sizeof(uint32_t)];
  uint8_t  b[BLOCK_LENGTH];
} bc_blk;
 
void speck64_encryptx(
    const void *key, 
    void *in)
{
  uint32_t i, t, k0, k1, k2, k3, x0, x1;
  bc_blk   *x=(bc_blk*)in;
  bc_blk   *k=(bc_blk*)key;
  
  // copy 128-bit key to local registers
  k0 = k->w[0]; k1 = k->w[1];
  k2 = k->w[2]; k3 = k->w[3];
  
  // copy M to local space
  x0 = x->w[0]; x1 = x->w[1];
  
  for (i=0; i<27; i++)
  {
    // encrypt block
    x0 = (ROTR32(x0, 8) + x1) ^ k0;
    x1 =  ROTL32(x1, 3) ^ x0;
    
    // create next subkey
    k1 = (ROTR32(k1, 8) + k0) ^ i;
    k0 =  ROTL32(k0, 3) ^ k1;
    
    XCHG(k3, k2, t);
    XCHG(k3, k1, t);    
  }
  // save result
  x->w[0] = x0; x->w[1] = x1;
}

#define ENCRYPT(x, y) speck64_encryptx(x, y)

void lightmac_tag(const void *msg, uint32_t msglen, 
    void *tag, void* mkey) 
{
  uint8_t  *data=(uint8_t*)msg;
  uint8_t  *key=(uint8_t*)mkey;
  uint32_t idx, ctr, i;
  bc_blk   m;
  bc_blk   *t=(bc_blk*)tag;
  
  // zero initialize T
  t->w[0] = 0; t->w[1] = 0;

  // set counter + index to zero
  ctr = 0; idx = 0;
  
  // while we have msg data
  while (msglen) {
    // add byte to M
    m.b[COUNTER_LENGTH + idx++] = *data++;
    // M filled?
    if (idx == (BLOCK_LENGTH - COUNTER_LENGTH)) {
      // add S counter in big endian format
      ctr++;
      m.ctr = SWAP32(ctr);
      // encrypt M with E using K1
      ENCRYPT(key, &m);
      // update T
      t->w[0] ^= m.w[0];
      t->w[1] ^= m.w[1];
      // reset index      
      idx = 0;
    }
    // decrease length
    msglen--;
  }
  // add the end bit
  m.b[COUNTER_LENGTH + idx++] = 0x80;  
  // update T with anything remaining
  for (i=0; i<idx; i++) {
    t->b[i] ^= m.b[COUNTER_LENGTH + i];
  }
  // advance key to K2
  key += BC_KEY_LENGTH;
  // encrypt T with E using K2
  ENCRYPT(key, t);
}

