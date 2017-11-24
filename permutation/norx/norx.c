
#include <stdint.h>
#include <limits.h>
 
#define NORX_W 8           /* Word size: 8, 16, 32 or 64 */
#define NORX_L 4           /* Round number: 4 or 6 */

#if NORX_W == 8
  typedef uint8_t norx_word_t;
  #define R0  1
  #define R1  3
  #define R2  5
  #define R3  7
#elif NORX_W == 16
  typedef uint16_t norx_word_t;
  #define R0  8
  #define R1 11
  #define R2 12
  #define R3 15
#elif NORX_W == 32
  typedef uint32_t norx_word_t;
  #define R0  8
  #define R1 11
  #define R2 16
  #define R3 31
#elif NORX_W == 64  
  typedef uint64_t norx_word_t;
  #define R0  8
  #define R1 19
  #define R2 40
  #define R3 63
#endif

typedef union _norx_state_t {
  norx_word_t w[16];
} norx_state;
  
#define BITS(x) (sizeof(x) * CHAR_BIT)
#define ROTL(x, c) ( ((x) << (c)) | ((x) >> (BITS(x) - (c))) )
#define ROTR(x, c) ( ((x) >> (c)) | ((x) << (BITS(x) - (c))) )

/* The non-linear primitive */
// same as addition without using modular ADD
#define H(A, B) ( ( (A) ^ (B) ) ^ ( ( (A) & (B) ) << 1) )

void norx_permute(void *state)
{
    int      i, j, idx;
    uint32_t a, b, c, d;
    norx_word_t *s=(norx_word_t*)state;
    
    uint16_t idx16[8]=
    { 0xC840, 0xD951, 0xEA62, 0xFB73,    // column index
      0xFA50, 0xCB61, 0xD872, 0xE943 };  // diagnonal index
    
    for (i=0; i<NORX_L; i++) {
      for (j=0; j<8; j++) {
        idx = idx16[j];
        
        a = (idx         & 0xF);
        b = ((idx >>  4) & 0xF);
        c = ((idx >>  8) & 0xF);
        d = ((idx >> 12) & 0xF);
    
         /* The quarter-round */
        s[a] = H(s[a], s[b]); 
        s[d] = ROTR(s[d] ^ s[a], R0);
        
        s[c] = H(s[c], s[d]); 
        s[b] = ROTR(s[b] ^ s[c], R1); 
        
        s[a] = H(s[a], s[b]); 
        s[d] = ROTR(s[d] ^ s[a], R2); 
        
        s[c] = H(s[c], s[d]); 
        s[b] = ROTR(s[b] ^ s[c], R3); 
      }
    }
}


#ifdef TEST

#include <stdio.h>

int main(void) {
  norx_word_t state[16];
  int         i;
  
  memset(state, 0, sizeof(state));
  for (i=0; i<16; i++) state[i] = i;
  
  norx_permute(state);
  
  for (i=0; i<16; i++) {
    printf ("%x ", state[i]);
  }
  return 0;
}  
#endif
 