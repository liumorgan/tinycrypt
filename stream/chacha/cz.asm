;
;  Copyright © 2015, 2017 Odzhan, Peter Ferrie. All Rights Reserved.
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
; ChaCha20 stream cipher in x86 assembly
;
; size: 210 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

    bits 32
 
%define a eax
%define b edx
%define c esi
%define d edi
%define x edi

%define t0 ebp
 
    %ifndef BIN
      global xchacha20
      global _xchacha20
    %endif
    
    ; ------------------------------------
xchacha20:
_xchacha20:
    pushad
    lea    esi, [esp+32+4]
    lodsd
    xchg   ecx, eax          ; ecx = len
    lodsd
    xchg   edi, eax          ; edi = input or key+nonce
    lodsd
    xchg   esi, eax          ; esi = state
    jecxz  init_key    
    ; perform encryption/decryption
    pushad
    pushad
    mov    ebx, esp          ; ebx = c
cx_l0:
    xor    eax, eax
    jecxz  cc_l2             ; exit if len==0
    call   xchacha_permute
cc_l1:
    mov    dl, [ebx+eax]
    xor    [edi], dl
    inc    edi
    inc    eax
    cmp    al, 64
    loopne cc_l1
    jmp    cx_l0
cc_l2:
    popad
    popad   
    popad
    ret
    ; ----------------------------------
init_key:
    xchg   esi, edi  
    ; copy "expand 32-byte k" into state
    mov    eax, 0x61707865
    stosd
    mov    eax, 0x3320646E
    stosd
    mov    eax, 0x79622D32
    stosd
    mov    eax, 0x6B206574
    stosd
    ; copy 256-bit key
    mov    cl, 8
    rep    movsd
    ; set 32-bit counter to zero
    xchg   ecx, eax
    stosd
    ; store 96-bit nonce and return
    movsd
    movsd
    movsd
    popad
    ret    

    ; esi = state
    ; edi = out
xchacha_permute:
    pushad
    xchg   eax, ecx
    mov    edi, ebx
    
    ; copy state to out
    ; memcpy (out->b, state->b, 64);
    pushad
    mov    cl, 16
    rep    movsd
    popad
    
    push   esi
    mov    cl, 20/2
e_l1:
    ; load indexes
    call   load_idx
    dw     0c840H, 0d951H
    dw     0ea62H, 0fb73H
    dw     0fa50H, 0cb61H
    dw     0d872H, 0e943H
load_idx:
    pop    esi  ; pointer to indexes
    push   ecx
    mov    cl, 8
e_l2:
    lodsw    
    
    pushad
    push   a
    xchg   ah, al
    aam    16

    movzx  ebp, ah
    movzx  c, al

    pop    a
    aam    16

    movzx  b, ah
    movzx  a, al

    lea    a, [x+a*4]
    lea    b, [x+b*4]
    lea    c, [x+c*4]
    lea    d, [x+ebp*4]
    ; load ecx with rotate values
    ; 16, 12, 8, 7
    mov    ecx, 07080C10h
    mov    t0, [b]
q_l1:
    xor    ebx, ebx
q_l2:
    ; x[a] += x[b];
    add    t0, [a]
    mov    [a], t0
    ; x[d] = ROTL32(x[d] ^ x[a], cl);
    ; also x[b] = ROTL32(x[b] ^ x[c], cl);
    xor    t0, [d]
    rol    t0, cl
    mov    [d], t0
    xchg   cl, ch
    xchg   c, a
    xchg   d, b
    dec    ebx
    jp     q_l2
    ; --------------------------------------------
    shr    ecx, 16
    jnz    q_l1

    popad
    loop   e_l2
    
    pop    ecx
    loop   e_l1
    
    pop    esi
    
    ; add state to x
    mov    cl, 16
add_state:
    mov    eax, [esi+ecx*4-4]
    add    [ebx+ecx*4-4], eax
    loop   add_state

    ; update 32-bit counter
    inc    dword[esi+12*4]
    popad
    ret
    