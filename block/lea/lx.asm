;
;  Copyright © 2017 Odzhan, Peter Ferrie. All Rights Reserved.
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
; LEA-128 Block Cipher in x86 assembly (Encryption only)
;
; size: 161 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

    bits 32
    
    %ifndef BIN
      global lea128_encryptx
      global _lea128_encryptx
    %endif
    
struc pushad_t
  _edi resd 1
  _esi resd 1
  _ebp resd 1
  _esp resd 1
  _ebx resd 1
  _edx resd 1
  _ecx resd 1
  _eax resd 1
  .size:
endstruc
    
%define k0 ebx
%define k1 edx
%define k2 edi
%define k3 ebp
     
%define p0 [esi+4*0]     
%define p1 [esi+4*1]     
%define p2 [esi+4*2]     
%define p3 [esi+4*3]
     
%define t ecx
%define x eax
%define y ecx
     
%define LEA128_RNDS 24
     
lea128_encryptx:
_lea128_encryptx:
    pushad   
    ; initialize 4 constants
    mov    edi, 0xc3efe9db   ; td[0]
    mov    esi, 0x88c4d604   ; td[1]
    mov    ebp, 0xe789f229   ; td[2]
    pushad
    mov    dword[esp+_esp], 0xc6f98763   ; td[3] 
    mov    esi, [esp+64+4]   ; esi = key
    ; load key
    lodsd
    xchg   eax, k0
    lodsd
    xchg   eax, k1
    lodsd
    xchg   eax, k2
    lodsd
    xchg   eax, k3
    mov    esi, [esp+64+8]   ; esi = block
    xor    eax, eax          ; i = 0    
lea_l0:
    push   eax
    and    al, 3
    mov    t, [esp+eax*4+4]  ; t = td[i % 4]
    rol    t, 4
    mov    [esp+eax*4+4], t  ; td[i & 3] = ROTL32(t, 4);
    ror    t, 4
    
    ; **************************************
    ; create subkey
    ; **************************************
    ; k0 = ROTL32(k0 + t, 1);
    add    k0, t             
    rol    k0, 1
    
    ; k1 = ROTL32(k1 + ROTL32(t, 1),  3);
    rol    t, 1              
    add    k1, t
    rol    k1, 3
    
    ; k2 = ROTL32(k2 + ROTL32(t, 2),  6);
    rol    t, 1              
    add    k2, t
    rol    k2, 6
    
    ; k3 = ROTL32(k3 + ROTL32(t, 3), 11);
    rol    t, 1              
    add    k3, t
    rol    k3, 11
    
    ; **************************************
    ; encrypt block
    ; **************************************
    ; p3 = ROTR32((p2 ^ k3) + (p3 ^ k1), 3);
    mov    x, p2             
    mov    y, p3
    xor    x, k3
    xor    y, k1
    add    x, y
    ror    x, 3
    mov    p3, x
    
    ; p2 = ROTR32((p1 ^ k2) + (p2 ^ k1), 5);
    mov    x, p1             
    mov    y, p2
    xor    x, k2
    xor    y, k1
    add    x, y
    ror    x, 5
    mov    p2, x
    
    ; p1 = ROTL32((p0 ^ k0) + (p1 ^ k1), 9);
    mov    x, p0             
    mov    y, p1
    xor    x, k0
    xor    y, k1
    add    x, y
    rol    x, 9
    mov    p1, x
    
    ; rotate block 32-bits
    mov    t, p3
    xchg   t, p2             ; XCHG(p0, p1); 
    xchg   t, p1             ; XCHG(p1, p2);
    xchg   t, p0             ; XCHG(p2, p3);
    mov    p3, t
    
    pop    eax
    inc    eax               ; i++
    cmp    al, LEA128_RNDS
    jnz    lea_l0
    
    popad
    popad
    ret    
    
    