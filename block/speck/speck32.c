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

#include "speck.h"

#ifndef SINGLE
void speck32_setkey(const void *in, void *out)
{
    uint16_t i, t, k0, k1, k2, k3;
    uint16_t *k=(uint16_t*)in;
    uint16_t *ks=(uint16_t*)out;
    
    // copy 64-bit key to local space
    k0 = k[0]; k1 = k[1];
    k2 = k[2]; k3 = k[3];

    // expand 64-bit key into round keys
    for (i=0; i<22; i++)
    {
      ks[i] = k0;
      
      k1 = (ROTR16(k1, 7) + k0) ^ i;
      k0 = ROTL16(k0, 2) ^ k1;
      
      // rotate left 32-bits
      XCHG(k3, k2);
      XCHG(k3, k1);
    }
}

void speck32_encrypt(const void *keys, int enc, void *data)
{
    uint16_t i, x0, x1;
    uint16_t *ks=(uint16_t*)keys;
    uint16_t *x=(uint16_t*)data;
    
    // copy input to local space
    x0 = x[0]; x1 = x[1];
    
    for (i=0; i<22; i++)
    {   
      if (enc == SPECK_DECRYPT)
      {
        x1  = ROTR16(x1  ^ x0, 2); 
        x0 ^= ks[22-1-i];
        x0 -= x1;
        x0  = ROTL16(x0, 7);        
      } else {     
        x0  = (ROTR16(x0, 7) + x1) ^ ks[i];
        x1  =  ROTL16(x1, 2) ^ x0;
      }  
    }
    // save result
    x[0] = x0; x[1] = x1;
}

#endif

void speck32_encryptx(const void *key, void *data)
{
    uint16_t i, t, k0, k1, k2, k3, x0, x1;
    uint16_t *k=(uint16_t*)key;
    uint16_t *x=(uint16_t*)data;
    
    // copy 128-bit key to local space
    k0 = k[0]; k1 = k[1];
    k2 = k[2]; k3 = k[3];
    
    // copy input to local space
    x0 = x[0]; x1 = x[1];
    
    for (i=0; i<22; i++)
    {
      // encrypt block
      x0 = (ROTR16(x0, 7) + x1) ^ k0;
      x1 =  ROTL16(x1, 2) ^ x0;
      
      // create next subkey
      k1 = (ROTR16(k1, 7) + k0) ^ i;
      k0 =  ROTL16(k0, 2) ^ k1;
      
      XCHG(k3, k2);
      XCHG(k3, k1);    
    }
    // save result
    x[0] = x0; x[1] = x1;
}
