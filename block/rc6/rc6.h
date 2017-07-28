

// RC6 in C
// Odzhan

#ifndef RC6_H
#define RC6_H

#include "../../macros.h"

#define RC6_ROUNDS 20
#define RC6_KR     (2*(RC6_ROUNDS+2))
#define RC6_P      0xB7E15163
#define RC6_Q      0x9E3779B9

#define RC6_ENCRYPT 1
#define RC6_DECRYPT 0

typedef struct _RC6_KEY {
  uint32_t x[RC6_KR];
} RC6_KEY;

typedef union _rc6_blk_t {
  uint8_t v8[16];
  uint16_t v16[8];
  uint32_t v32[4];
  uint64_t v64[2];
} rc6_blk;

#ifdef __cplusplus
extern "C" {
#endif

  // asm prototype
  void rc6_setkeyx (RC6_KEY*, void*, uint32_t);
  void rc6_cryptx (RC6_KEY*, void*, void*, int);
  
  // C prototype
  void rc6_setkey (RC6_KEY*, void*, uint32_t);
  void rc6_crypt (RC6_KEY*, void*, void*, int);

#ifdef __cplusplus
}
#endif

#endif