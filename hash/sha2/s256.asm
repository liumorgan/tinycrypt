;
;  Copyright © 2015 Odzhan. All Rights Reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions are
;  met:
;
;  1. Redistributions of source code must retain the above copyright
;  notice, this list of conditions and the following disclaimer.
;
;  2. Redistributions in binary form must reproduce the above copyright
;  notice, this list of conditions and the following disclaimer in the
;  documentation and/or other materials provided with the distribution.
;
;  3. The name of the author may not be used to endorse or promote products
;  derived from this software without specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
;  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
;  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
;
; -----------------------------------------------
; SHA-256 stream cipher in x86 assembly
;
; size: 675 bytes, 653 using dynamic constants
;
; global calls use cdecl convention
;
; -----------------------------------------------
    bits 32

SHA256_CBLOCK         EQU 64
SHA256_DIGEST_LENGTH  EQU 32
SHA256_LBLOCK         EQU SHA256_DIGEST_LENGTH/4

struc sha256_ctx
  len    resd 2
  state  resb SHA256_DIGEST_LENGTH
  buffer resb SHA256_CBLOCK
endstruc
    
SHA256:
    pushad

    push   eax
    fstcw  [esp]            ; store control word
    pop    eax
    or     ax, 00400H       ; set round down bit
    and    ax, 0F7FFH       ; clear bit
    push   eax
    fldcw  [esp]            ; load control word
    pop    eax

    mov    ebx, esp          ; 
    sub    esp, 4+64+8*4     ; alloc space for ctx
    mov    edi, esp
    push   edi               ; save ptr to ctx
    
    push   8                 ; load 8 32-bit words
    pop    ecx
    call   load_iv
  dd 06a09e667h, 0bb67ae85h 
  dd 03c6ef372h, 0a54ff53ah
  dd 0510e527fh, 09b05688ch
  dd 01f83d9abh, 05be0cd19h
load_iv:
    pop    esi
    rep    movsd
    
    xor    eax, eax
    stosd                    ; ctx.len = 0
    cdq                      ; idx = 0
    
    mov    ebp, [ebx+32+ 4]  ; ecx = inlen
    mov    esi, [ebx+32+ 8]  ; esi = in
    mov    ebx, [ebx+32+12]  ; ebx = out
chk_len:
    test   ebp, ebp
    jnz    upd_buf
    
    push   edi
    add    edi, edx
    mov    ecx, edx
    mov    al, 80h           ; ctx.buffer[idx++] = 0x80;
    stosb
    xor    eax, eax
    neg    ecx
    add    ecx, 63
    rep    stosb
    pop    edi
    
    ; if (edx >= 56)
    cmp    edx, 56
    jb     add_bits
    
    call   SHA256_Transform
    
    push   edi               ; zero ctx.buffer
    mov    cl, 64
    rep    stosb
    pop    edi
    
add_bits:
    mov    eax, [edi-4]      ; eax = ctx.len
    shl    eax, 3            ; multiply by 8
    bswap  eax               ; convert to big endian
    mov    [edi+60], eax     ; save in buffer
    jmp    upd_ctx
upd_buf:
    lodsb                    ; al = *p++
    mov    [edi+edx], al
    inc    dword [edi-4]  ; ctx.len++
    inc    edx               ; idx++
    cmp    edx, 64           ; buffer full?
    jnz    upd_len
upd_ctx:
    call   SHA256_Transform
    xor    edx, edx          ; idx=0
upd_len:
    dec    ebp               ; while (--inlen >= 0)
    jns    chk_len

    mov   edi, ebx           ; edi = out
    pop   esi                ; esi = ctx.state
    push  8                  ; save 256-bit state/hash
    pop   ecx
ret_state:
    lodsd                    ; load word
    bswap  eax               ; convert to little endian
    stosd                    ; save in out buffer
    loop   ret_state
    add    esp, 4+64+8*4     ; fix up stack
    popad
    ret

%define _a dword[edi+0*4]
%define _b dword[edi+1*4]
%define _c dword[edi+2*4]
%define _d dword[edi+3*4]
%define _e dword[edi+4*4]
%define _f dword[edi+5*4]
%define _g dword[edi+6*4]
%define _h dword[edi+7*4]

%define s0 eax
%define s1 ebx
%define i  ecx
%define t1 edx
%define t2 esi
%define t3 ebp

SHA256_Transform:
    pushad
    
    lea    esi, [ebx+state]
    push   esi
    
    push   64
    pop    ecx
    shl    ecx, 3
    
    ; allocate work space
    sub    esp, ecx
    
    ; Initialize working variables to current hash value:
    mov    edi, esp
    push   8
    pop    ecx
    rep    movsd
    
    ; convert 16 words to big endian
    mov    cl, 16
swap_bytes:
    lodsd
    bswap  eax
    stosd
    loop   swap_bytes

    ; Extend the first 16 words into the remaining 48 words w[16..63] of 
    ; the message schedule array:
    mov    cl, 48
expand:
    ; s0 := (w[i-15] rightrotate 7) xor 
    ;       (w[i-15] rightrotate 18) xor 
    ;       (w[i-15] rightshift 3)
    mov    s0, [edi - 15*4]
    mov    t1, s0
    mov    t2, s0
    ror    s0, 7
    ror    t1, 18
    shr    t2, 3
    xor    s0, t1
    xor    s0, t2
    ; s1 := (w[i-2] rightrotate 17) xor 
    ;       (w[i-2] rightrotate 19) xor 
    ;       (w[i-2] rightshift 10)
    mov    s1, [edi - 2*4]
    mov    t1, s1
    mov    t2, s1
    ror    s1, 17
    ror    t1, 19
    shr    t2, 10
    xor    s1, t1
    xor    s1, t2
    ; w[i] := w[i-16] + s0 + w[i-7] + s1
    add    s0, [edi - 16*4]
    add    s1, [edi -  7*4]
    add    s0, s1
    stosd
    loop   expand
    
    ; update context
update_loop:
    mov    edi, esp
    ; S1 := EP1(e)
    ; S1 := (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
    mov    s1, _e
    mov    t1, s1
    ror    s1, 25
    ror    t1, 6
    xor    s1, t1
    ror    t1, 11-6
    xor    s1, t1
    ; CH(e, f, g)
    ; ch := (e and f) xor ((not e) and g)
    mov    t1, _f
    xor    t1, _g
    and    t1, _e
    xor    t1, _g
    ; temp1 := h + S1 + ch + k[i] + w[i]
    add    t1, s1
    add    t1, _h
%ifdef DYNAMIC
    call   cbr2int
    add    t1, eax
%else
    call   ld_k
ld_k:
    pop    t2
    lea    t2, [t2+(_k-ld_k)]
    add    t1, dword [t2+4*i]
%endif
    add    t1, dword [edi+4*i+32]
    ; S0 := EP0(a)
    ; S0 := (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
    mov    s0, _a
    mov    t2, s0
    ror    s0, 22
    ror    t2, 2
    xor    s0, t2
    ror    t2, 13-2
    xor    s0, t2
    ; MAJ(a, b, c)
    ; maj := (a and b) xor (a and c) xor (b and c)
    mov    t2, _a
    mov    t3, _a
    or     t2, _b
    and    t2, _c
    and    t3, _b
    or     t2, t3
    ; temp2 := S0 + maj
    add    t2, s0
    ; d = d + temp1
    add    _d, t1
    ; h = temp1 + temp2
    mov    _h, t1
    add    _h, t2
    ; shift state
    mov    esi, edi  
    push   i
    push   edi
    mov    cl, 7
    lodsd                   ; load a
shift_state:
    scasd                   ; skip a
    xchg   eax, [edi]       ; a becomes b, eax then has b to swap with c and so on
    loop   shift_state
    pop    edi
    stosd
    pop    i
    
    ; i++
    inc    i
    cmp    i, 64
    jne    update_loop
    
    ; Produce the final hash value (big-endian):
    ; digest := hash := h0 append h1 append h2 append h3 append 
    ; h4 append h5 append h6 append h7
    mov    esi, esp
    lea    esp, [esi+ecx*8]

    pop    edi
    mov    cl, 8
save_state:
    lodsd
    add    eax, [edi]
    stosd
    loop   save_state
    ; restore registers
    popad
    ret

%ifdef DYNAMIC
    ; get cubic root of number 
    ; return 32-bit fractional part as integer
cbr2int:
    pushad
    call   cbr_primes
cbr_primes:
    pop    esi
    lea    esi, [esi+(primes-cbr_primes)]
    push   1
    push   0
    fild   qword[esp]   ; load 2^32
    push   1
    fild   dword[esp]
    push   3
    fild   dword[esp]
    fdivp                   ; 1.0/3.0
    movzx  eax, word[esi+2*i]
    push   eax
    fild   dword[esp]   ;
    fyl2x                   ; ->log2(Src1)*exponent
    fld    st0               ; copy the logarithm
    frndint                 ; keep only the characteristic
    fsub   st1, st0        ; keeps only the mantissa
    fxch   st1                 ; get the mantissa on top
    f2xm1                   ; ->2^(mantissa)-1
    fscale
    fstp   st1            ; copy result over and "pop" it
    fmulp  st1, st0                 ; * 2^32
    fistp  qword[esp]   ; save integer
    pop    eax
    add    esp, 4*4         ; release stack
    mov    [esp+1ch], eax
    popad
    ret

primes dw 2, 3, 5, 7, 11, 13, 17, 19, 
       dw 23, 29, 31, 37, 41, 43, 47, 53
       dw 59, 61, 67, 71, 73, 79, 83, 89
       dw 97, 101, 103, 107, 109, 113, 127, 131
       dw 137, 139, 149, 151, 157, 163, 167, 173 
       dw 179, 181, 191, 193, 197, 199, 211, 223 
       dw 227, 229, 233, 239, 241, 251, 257, 263
       dw 269, 271, 277, 281, 283, 293, 307, 311
primes_len equ $-primes
    
%else

_k dd 0428a2f98h, 071374491h, 0b5c0fbcfh, 0e9b5dba5h
   dd 03956c25bh, 059f111f1h, 0923f82a4h, 0ab1c5ed5h
   dd 0d807aa98h, 012835b01h, 0243185beh, 0550c7dc3h
   dd 072be5d74h, 080deb1feh, 09bdc06a7h, 0c19bf174h
   dd 0e49b69c1h, 0efbe4786h, 00fc19dc6h, 0240ca1cch
   dd 02de92c6fh, 04a7484aah, 05cb0a9dch, 076f988dah 
   dd 0983e5152h, 0a831c66dh, 0b00327c8h, 0bf597fc7h
   dd 0c6e00bf3h, 0d5a79147h, 006ca6351h, 014292967h 
   dd 027b70a85h, 02e1b2138h, 04d2c6dfch, 053380d13h
   dd 0650a7354h, 0766a0abbh, 081c2c92eh, 092722c85h 
   dd 0a2bfe8a1h, 0a81a664bh, 0c24b8b70h, 0c76c51a3h
   dd 0d192e819h, 0d6990624h, 0f40e3585h, 0106aa070h 
   dd 019a4c116h, 01e376c08h, 02748774ch, 034b0bcb5h
   dd 0391c0cb3h, 04ed8aa4ah, 05b9cca4fh, 0682e6ff3h 
   dd 0748f82eeh, 078a5636fh, 084c87814h, 08cc70208h
   dd 090befffah, 0a4506cebh, 0bef9a3f7h, 0c67178f2h
   
%endif


