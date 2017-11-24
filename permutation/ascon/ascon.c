
#include <stdio.h>
#include <stdint.h>

#define ROTR(x,n) (((x)>>(n))|((x)<<(64-(n))))

void ascon_permute(void *state, int rnds) {
    int      i;
    uint64_t x0, x1, x2, x3, x4;
    uint64_t t0, t1, t2, t3, t4;
    
    uint64_t *x=(uint64_t*)state;
    
    // load 320-bit state
    x0 = x[0]; x1 = x[1];
    x2 = x[2]; x3 = x[3];
    x4 = x[4];

    for (i=0; i<rnds; i++) {
      // addition of round constant
      x2 ^= ((0xfull - i) << 4) | i;

      // substitution layer
      x0 ^= x4;    x4 ^= x3;    x2 ^= x1;
      t0  = x0;    t1  = x1;    t2  = x2;    t3  =  x3;    t4  = x4;
      t0  = ~t0;   t1  = ~t1;   t2  = ~t2;   t3  = ~t3;    t4  =~ t4;
      t0 &= x1;    t1 &= x2;    t2 &= x3;    t3 &=  x4;    t4 &= x0;
      x0 ^= t1;    x1 ^= t2;    x2 ^= t3;    x3 ^=  t4;    x4 ^= t0;
      x1 ^= x0;    x0 ^= x4;    x3 ^= x2;    x2  = ~x2;

      // linear diffusion layer
      x0 ^= ROTR(x0, 19) ^ ROTR(x0, 28);
      x1 ^= ROTR(x1, 61) ^ ROTR(x1, 39);
      x2 ^= ROTR(x2,  1) ^ ROTR(x2,  6);
      x3 ^= ROTR(x3, 10) ^ ROTR(x3, 17);
      x4 ^= ROTR(x4,  7) ^ ROTR(x4, 41);

    }
    // save 320-bit state
    x[0] = x0; x[1] = x1;
    x[2] = x2; x[3] = x3;
    x[4] = x4;
}
