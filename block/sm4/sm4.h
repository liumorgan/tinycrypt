/**
  Copyright (C) 2017 Odzhan. All Rights Reserved.

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

#ifndef SM4_H
#define SM4_H

#include "../../macros.h"

#define SM4_ROUNDS 32

#define SM4_ENCRYPT 0
#define SM4_DECRYPT 1

// 32-bit type
typedef union {
    uint8_t  b[4];
    uint32_t w;
} w32_t;

// 128-bit type
typedef union {
    uint8_t  b[16];
    uint32_t w[4];
} w128_t;
   
typedef struct sm4_ctx_t {
    uint32_t rk[SM4_ROUNDS];
} sm4_ctx;

#ifdef __cplusplus
extern "C" {
#endif

void sm4_setkey(sm4_ctx*,const void*, int);
void sm4_setkeyx(sm4_ctx*,const void*, int);

void sm4_encrypt(sm4_ctx*,void*);
void sm4_encryptx(sm4_ctx*,void*);

#ifdef __cplusplus  
}
#endif

#endif