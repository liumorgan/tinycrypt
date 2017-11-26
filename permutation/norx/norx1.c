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
  
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "norx_util.h"
#include "norx.h"

#define XCHG(x, y) (t) = (x); (x) = (y); (y) = (t);
#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))

#define memcpy(x,y,z) __movsb(x,y,z)
#define memset(x,y,z) __stosb(x,y,z)

#define NORX_N (NORX_W *  4)     /* Nonce size */
#define NORX_K (NORX_W *  4)     /* Key size */
#define NORX_B (NORX_W * 16)     /* Permutation width */
#define NORX_C (NORX_W *  4)     /* Capacity */
#define NORX_R (NORX_B - NORX_C) /* Rate */

#define NORX_D 0
#define NORX_E 1

#if NORX_W == 32 /* NORX32 specific */

    /* Rotation constants */
    #define R0  8
    #define R1 11
    #define R2 16
    #define R3 31

#elif NORX_W == 64 /* NORX64 specific */

    /* Rotation constants */
    #define R0  8
    #define R1 19
    #define R2 40
    #define R3 63

#else
    #error "Invalid word size!"
#endif

/* The non-linear primitive */
// same as addition without using modular ADD
#define H(A, B) ( ( (A) ^ (B) ) ^ ( ( (A) & (B) ) << 1) )

void F(norx_word_t s[16])
{
    int         i;
    uint32_t    a, b, c, d, r, t, idx;
    
    uint16_t idx16[8]=
    { 0xC840, 0xD951, 0xEA62, 0xFB73,    // column index
      0xFA50, 0xCB61, 0xD872, 0xE943 };  // diagnonal index
    
    for (i=0; i<8; i++) {
      idx = idx16[i];
        
      a = (idx         & 0xF);
      b = ((idx >>  4) & 0xF);
      c = ((idx >>  8) & 0xF);
      d = ((idx >> 12) & 0xF);
  
      r = 0x1F100B08;
      
      /* The quarter-round */
      do {
        s[a] = H(s[a], s[b]); 
        s[d] = ROTR(s[d] ^ s[a], r & 0xFF);
        XCHG(c, a);
        XCHG(d, b);
        r >>= 8;
      } while (r != 0);
    }    
}

/* The core permutation */
void norx_permute(norx_state_t state)
{
    size_t i;
    norx_word_t * S = state->S;

    for (i = 0; i < NORX_L; ++i) {
        F(S);
    }
}

void norx_absorb_block(norx_state_t state, 
  norx_word_t *out, norx_word_t * in, 
  size_t inlen, tag_t tag)
{
    size_t i;
    norx_word_t * S = state->S;
    norx_word_t block[BYTES(NORX_R)];
    
    S[15] ^= tag;
    norx_permute(state);

    memset(block, 0, sizeof(block));
    memcpy(block, in, inlen);
    
    if (inlen < BYTES(NORX_R)) {
      ((uint8_t*)block)[inlen] = 0x01;
      ((uint8_t*)block)[BYTES(NORX_R) - 1] |= 0x80;
    }
    
    for (i = 0; i < WORDS(NORX_R); ++i) {
        S[i] ^= block[i];
    }
    if (tag==PAYLOAD_TAG) memcpy(out, S, inlen);
}

void norx_decrypt_block(norx_state_t state, 
  norx_word_t *out, const norx_word_t *in, int len)
{
    size_t      i;
    norx_word_t *S = state->S;
    norx_word_t block[BYTES(NORX_R)];
    norx_word_t t;
    
    S[15] ^= PAYLOAD_TAG;
    norx_permute(state);

    memcpy (block, S, BYTES(NORX_R));
    memcpy (block, in, len);
      
    if (len < BYTES(NORX_R)) {      
      ((uint8_t*)block)[len] ^= 0x01;
      ((uint8_t*)block)[BYTES(NORX_R) - 1] ^= 0x80;
    }
    
    for (i=0; i<WORDS(NORX_R); i++) {
      t = block[i];  
      block[i] ^= S[i];
      S[i] = t;
    }
    memcpy(out, block, len);
}

/* Low-level operations */
void norx_init(norx_state_t state, const unsigned char *key, const unsigned char *nonce)
{
    norx_word_t * S = state->S;
    size_t i;
    norx_word_t *k=(norx_word_t*)key;
    norx_word_t *n=(norx_word_t*)nonce;
    
    for (i=0; i<16; i++) {
      S[i] = i;
    }

    F(S); F(S);

    memcpy(&S[0], nonce, 16);
    memcpy(&S[4], key,   16);

    S[12] ^= NORX_W;
    S[13] ^= NORX_L;
    S[14] ^= NORX_P;
    S[15] ^= NORX_T;

    norx_permute(state);

    for (i=0; i<4; i++) S[i+12] ^= k[i];
}

void norx_absorb_data(norx_state_t state, 
  const unsigned char * in, size_t inlen, tag_t tag)
{
    int len;
    
    while (inlen) {
      len = MIN(inlen, BYTES(NORX_R));
      norx_absorb_block(state, 0, (norx_word_t*)in, len, tag);
      
      inlen -= len;
      in += len;
    }
}

void norx_encrypt_data(norx_state_t state, 
  unsigned char *out, const unsigned char * in, size_t inlen)
{
    int len;
    
    while (inlen) {
      len = MIN(inlen, BYTES(NORX_R));
      norx_absorb_block(state, (norx_word_t*)out, (norx_word_t*)in, len, PAYLOAD_TAG);
      
      inlen -= len;
      in    += len;
      out   += len;
    }
}

void norx_decrypt_data(norx_state_t state, 
  unsigned char *out, const unsigned char * in, size_t inlen)
{
    int len;
    
    while (inlen) {
      len = MIN(inlen, BYTES(NORX_R));
      norx_decrypt_block(state, (norx_word_t*)out, (norx_word_t*)in, len);
      
      inlen -= len;
      in    += len;
      out   += len;
    }
}

void norx_finalise(norx_state_t state, 
  unsigned char * tag, const unsigned char * key)
{
    norx_word_t * S = state->S;
    uint32_t lastblock[BYTES(NORX_C)];
    norx_word_t *k=(norx_word_t*)key;
    size_t i;
    
    S[15] ^= FINAL_TAG;

    norx_permute(state);

    for (i=0; i<4; i++) S[i+12] ^= k[i];

    norx_permute(state);

    for (i=0; i<4; i++) S[i+12] ^= k[i];

    for (i=0; i<4; i++) lastblock[i] = S[i+12];

    memcpy(tag, lastblock, BYTES(NORX_T));
}

/* Verify tags in constant time: 0 for success, -1 for fail */
int norx_verify_tag(const unsigned char * tag1, const unsigned char * tag2)
{
    size_t i;
    unsigned acc = 0;

    for (i = 0; i < BYTES(NORX_T); ++i) {
        acc |= tag1[i] ^ tag2[i];
    }

    return (((acc - 1) >> 8) & 1) - 1;
}

/* High-level operations */
void norx_aead_encrypt(
  unsigned char *c, size_t *clen,
  const unsigned char *a, size_t alen,
  const unsigned char *m, size_t mlen,
  const unsigned char *z, size_t zlen,
  const unsigned char *nonce,
  const unsigned char *key
)
{
    norx_state_t state;

    norx_init(state, key, nonce);
    norx_absorb_data(state, a, alen, HEADER_TAG);
    norx_encrypt_data(state, c, m, mlen);
    norx_absorb_data(state, z, zlen, TRAILER_TAG);
    norx_finalise(state, c + mlen, key);
    *clen = mlen + BYTES(NORX_T);
}

int norx_aead_decrypt(
  unsigned char *m, size_t *mlen,
  const unsigned char *a, size_t alen,
  const unsigned char *c, size_t clen,
  const unsigned char *z, size_t zlen,
  const unsigned char *nonce,
  const unsigned char *key
)
{
    unsigned char tag[BYTES(NORX_T)];
    norx_state_t state;
    int result = -1;

    if (clen < BYTES(NORX_T)) {
        return -1;
    }

    norx_init(state, key, nonce);
    norx_absorb_data(state, a, alen, HEADER_TAG);
    norx_decrypt_data(state, m, c, clen - BYTES(NORX_T));
    norx_absorb_data(state, z, zlen, TRAILER_TAG);
    norx_finalise(state, tag, key);
    *mlen = clen - BYTES(NORX_T);

    result = norx_verify_tag(c + clen - BYTES(NORX_T), tag);
    return result;
}
