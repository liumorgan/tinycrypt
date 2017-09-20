
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

/* inverse modulus (extended euclidean algorithm) */
uint64_t mod_inverse(uint64_t A, uint64_t p)
{
	uint64_t a, b, q, t, x, y;
	a = p;
	b = A;
	x = 1;
	y = 0;
  
	while (b != 0)
	{
		t = b;
		q = a/t;
		b = a - q*t;
		a = t;
		t = x;
		x = y - q*t;
		y = t;
	}
	return ((int64_t)y < 0) ? y+p : y;
}

int main(void)
{
  printf ("%llx\n", mod_inverse(0x85ebca6b, 0xFFFFFFFFFFFFFFFF));
  return 0;
}
