
/**
  Copyright © 2015, 2017 Odzhan. All Rights Reserved.

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

#include "aes.h"

#define RotWord(x) ROTR32(x, 8)

uint32_t gf_mul2 (uint32_t w) {
    uint32_t t = w & 0x80808080;
    
    return ((w ^ t ) << 1) ^ (( t >> 7) * 0x0000001B);
}
// ------------------------------------
// multiplicative inverse
// ------------------------------------
uint8_t gf_mulinv (uint8_t x)
{
    uint8_t y=x, i;

    if (x) {
      // calculate logarithm gen 3
      for (y=1, i=0; ;i++) {
        y ^= gf_mul2 (y);
        if (y==x) break;
      }
      i+=2;
      // calculate anti-logarithm gen 3
      for (y=1; i; i++) {
        y ^= gf_mul2(y);
      }
    }
    return y;
}
// ------------------------------------
// substitute byte
// ------------------------------------
uint8_t SubByte (uint8_t x)
{
    uint8_t i, y=0, sb;

    sb = y = gf_mulinv (x);

    for (i=0; i<4; i++) {
      y   = ROTL8(y, 1);
      sb ^= y;
    }
    return sb ^ 0x63;
}
// ------------------------------------
// substitute 4 bytes
// ------------------------------------
uint32_t SubWord (uint32_t x)
{
    uint8_t  i;
    uint32_t r=0;

    for (i=0; i<4; i++) {
      r |= SubByte(x & 0xFF);
      r  = ROTR32(r, 8);
      x >>= 8;
    }
    return r;
}
// ------------------------------------
// shift rows + sub bytes combined
// ------------------------------------
void SBSR (aes_blk *s)
{
    uint8_t  *buf=(uint8_t*)s->b;
    uint8_t  i, j;
    uint32_t x;
    
    i = buf[1], 
    buf[1]  = buf[5], 
    buf[5]  = buf[9], 
    buf[9]  = buf[13], 
    buf[13] = i;  

    i = buf[10], 
    buf[10] = buf[2], 
    buf[2]  = i;
    
    i = buf[3], 
    buf[3]  = buf[15], 
    buf[15] = buf[11], 
    buf[11] = buf[7], 
    buf[7]  = i;
    
    i = buf[14], 
    buf[14] = buf[6], 
    buf[6]  = i;
    
    for (i=0; i<16; i++) {
      buf[i] = SubByte(buf[i]);
    }
}
// ------------------------------------
// mix columns in state
// ------------------------------------
void MixColumns (uint32_t *s)
{
    uint32_t i, w;

    for (i=0; i<4; i++) {
      w = s[i];
      s[i] = ROTR32(w,  8) ^ 
             ROTR32(w, 16) ^ 
             ROTR32(w, 24) ^ 
             gf_mul2(ROTR32(w, 8) ^ w);
    }
}
// ------------------------------------
// add 16 bytes of key to state
// ------------------------------------
void AddRoundKey (aes_ctx *c, aes_blk *s, int rnd)
{
    uint32_t i;

    for (i=0; i<4; i++) {
      s->w[i] ^= c->w[4*rnd+i];
    }
}
// ------------------------------------
// create AES-256 key
// ------------------------------------
void aes_setkey (aes_ctx *c, void *key)
{
    int      i;
    uint32_t x;
    uint32_t *w=(uint32_t*)c->w;
    uint32_t rcon=1;

    for (i=0; i<Nk; i++) {
      w[i]=((uint32_t*)key)[i];
    }

    for (i=Nk; i<Nb*(Nr+1); i++)
    {
      x = w[i-1];
      if ((i % Nk)==0) {
        x = RotWord(x);
        x = SubWord(x) ^ rcon;
        rcon=gf_mul2(rcon);
      } else if ((Nk > 6) && ((i % Nk) == 4)) {
        x = SubWord(x);
      }
      w[i] = w[i-Nk] ^ x;
    }
}
// ------------------------------------
// encrypt 16 bytes of state
// ------------------------------------
void aes_enc (aes_ctx *c, void *s)
{
    uint32_t r;
    
    AddRoundKey (c, s, 0);
    
    for (r=1; r<Nr; r++) {
      SBSR (s);
      MixColumns (s);
      AddRoundKey (c, s, r);     
    }
    SBSR (s);
    AddRoundKey (c, s, r);   
}
