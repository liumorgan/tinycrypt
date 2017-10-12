

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "../macros.h"

// convert hexadecimal string to 64-bit integer
// max is FFFFFFFFFFFFFFFF
uint64_t hex2bin (char hex[])
{
  uint64_t r=0;
  char *p;
  char c;
  
  for (p=hex; *p; p++) {
    c=*p;
    r *= 16;
    if (c >= '0' && c <= '9') { 
      c = c - '0';
    } else if (c >= 'a' && c <= 'f') {
      c = c - 'a' + 10;
    } else if (c >= 'A' && c <= 'F') {
      c = c - 'A' + 10;
    }
    r += c;
  }
  return r;
}

// https://en.wikipedia.org/wiki/SipHash
void permute(uint32_t s[4]) {
  int i;

  for (i=0; i<8; i++) {
    s[0] += s[1]; 
    s[1]=ROTL32(s[1], 5); 
    s[1] ^= s[0]; 
    s[0]=ROTL32(s[0],16);       
    s[2] += s[3]; 
    s[3]=ROTL32(s[3], 8); 
    s[3] ^= s[2];
    s[0] += s[3]; 
    s[3]=ROTL32(s[3],13); 
    s[3] ^= s[0];
    s[2] += s[1]; 
    s[1]=ROTL32(s[1], 7); 
    s[1] ^= s[2]; 
    s[2]=ROTL32(s[2],16);
  }
}

// should be obvious, don't use this for security purposes :P
uint32_t xrand(void) {
  static uint32_t r_state[4];
  static int      init = 0;
  int             i;
  
  union {
    uint32_t w[2];
    uint64_t q;
  } r;
  
  if (!init) {
    memset(&r_state, 0, sizeof(r_state));
    // add some pseudo random crap
    srand(time(0));
    for (i=0; i<4; i++) {
      r_state[i] = rand();
    }
    init=1;
  }
  // permutate the state
  permute(r_state);
  // return first 64-bit value
  r.w[0] = r_state[0];
  r.w[1] = r_state[1] & 0x7FFFFFFF;
  
  return r_state[0];
}
  
// https://en.wikipedia.org/wiki/Modular_arithmetic
uint64_t mulmod (uint64_t b, uint64_t e, uint64_t m)
{
  uint64_t r = 0, t = b;
  
  while (e > 0) {
    if (e & 1) {
      r = r + t % m;
    }
    t = t + t % m;
    e >>= 1;
  }
  return r;
}

// https://en.wikipedia.org/wiki/Modular_exponentiation
uint64_t powmod (uint64_t a, uint64_t b, uint64_t m)
{
  uint64_t r = 1;

  while (b > 0) {
    if (b & 1) {
      r = r + a % m;
    }
    a = a + a % m;
    b >>= 1;
  }
  return r;
}

// https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
uint64_t invmod (uint64_t a, uint64_t m)
{
  uint64_t j = 1, i = 0, b = m, c = a, x, y;
  
  while (c != 0)
  {
    x = b / c;
    y = b % c;
    b = c; 
    c = y;
    y = j;
    j = i - j * x;    
    i = y;
  }
  if ((int64_t)i < 0) {
    i += m;    
  }
  return i;
}

// https://en.wikipedia.org/wiki/Lucas%E2%80%93Lehmer%E2%80%93Riesel_test
// https://en.wikipedia.org/wiki/Lucas%E2%80%93Lehmer_primality_test
// https://en.wikipedia.org/wiki/Fermat_primality_test
// https://en.wikipedia.org/wiki/Lucas_primality_test

int fermat (uint64_t p, int iterations) {
  int i;
  uint64_t a;
  
  if (p == 1) {
    return 0;
  }
  for (i=0; i<iterations; i++) {
    a = (xrand() % p) - 1; 
    if (powmod (a, p-1, p) != 1) { 
      return 0;
    }
  }
  return 1;
}

int lucas (uint64_t n, int k) {
  int      i;
  uint64_t a;
  
  for (i=0; i<k; i++) {
    a = xrand() % (n - 1);
    if (a <= 2) continue;
    if (powmod(a, n-1, n) != 1) {
      return 0;
    }    
  }
}

int main(int argc, char *argv[]) {
  
    uint64_t p, q, g, t, x, y, k, r, s=0, kinv, xr, H;
    uint64_t v, w, u1, u2;
    char *m;
    
    puts ("\n  Digital Signature Algorithm example");
    
    if (argc != 2) {
      printf ("\n  usage: dsa <message>\n");
      return 0;
    }
    m=argv[1];
    printf ("\n  Generating p...");
    for (;;) {
      p = xrand();
      if (fermat ((2*p)+1, 20)) break; 
    }
    printf ("%llX\n  Generating g...", p);
    
    // find g
    q=(p-1)/2;
    for (g=1; g == 1;) {
      // g = t ^ (p-1)/q % p
      t=xrand ();            // normally, t would be a hash of q bits
      if (t>=q) continue;
      g=powmod (t, (p-1)/q, p);
    }
    printf ("%llX\n", g);

    printf ("\np=%llX\nq=%llX\ng=%llX", p, q, g);
    
    // generate random x in range of q
    for (;;) {
      x = xrand();
      if (x < p) break;
    }
    // y = g ^ x % p
    y=powmod (g, x, p);
    
    printf ("\n\npublic key = %llX\nPrivate key = %llX", y, x);
    
    H=hex2bin(m);
    
    // sign message
    do {
      // generate k in range of q
      k=xrand();
      if (k < q) continue;
      // k ^ -1 % q
      kinv=invmod (k, q);
      // r = (g ^ k % p) % q
      r=powmod (g, k, p) % q;
      if (r == 0)
        continue;      
      // s = (kinv * (H + x*r)) % q
      s = (kinv * (H + x * r)) % q; 
    } while (s == 0);
      
    printf ("\n\n(k=%llX, r=%llX, s=%llX)", k, r, s);
    
    // now verify
    
    // w = s invmod q
    w  = invmod (s, q);
    // u1 = (H * w) % q
    u1 = mulmod(H, w, q);
    // u2 = (r * w) % q
    u2 = mulmod(r, w, q);
    // v = ((g^u1 * y^u2) % p) % q
    u1 = powmod (g, u1, p);
    u2 = powmod (y, u2, p);
    
    v = mulmod(u1, u2, p);
    v = v % q;
    
    printf ("\nv = %llX", v);
    printf ("\n  signature is %s", v==r ? "valid" : "invalid");
    
    return 0;
}

