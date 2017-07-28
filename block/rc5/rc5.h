/**
  Copyright © 2015 Odzhan. All Rights Reserved.

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

#ifndef RC5_H
#define RC5_H

#include "../../macros.h"

#define RC5_ENCRYPT 1
#define RC5_DECRYPT 0

#define RC5_BLK_LEN 8
#define RC5_ROUNDS  12
#define RC5_KEYLEN  16

#define RC5_KR      (2*(RC5_ROUNDS+1))
#define RC5_P       0xB7E15163
#define RC5_Q       0x9E3779B9

#pragma pack(push, 1)
typedef struct _RC5_CTX {
  uint32_t x[RC5_KR];
} RC5_CTX;

typedef union _rc5_blk {
  uint8_t v8[RC5_BLK_LEN];
  uint32_t v32[RC5_BLK_LEN/4];
  uint64_t v64[RC5_BLK_LEN/8];
} rc5_blk;
#pragma pack(pop)

#ifdef __cplusplus
extern "C" {
#endif
  void rc5_setkey (RC5_CTX*, void*);
  void rc5_setkeyx (RC5_CTX*, void*);
  
  void rc5_crypt (RC5_CTX*, void*, void*, int);
  void rc5_cryptx (RC5_CTX*, void*, void*, int);
#ifdef __cplusplus
}
#endif

#endif