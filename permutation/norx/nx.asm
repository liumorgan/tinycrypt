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
; NORX permutation function in x86 assembly
;
; size: 117 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

   bits 32

   %ifndef BIN
     global _norx_permutex 
     global norx_permutex 
   %endif
   
%define a eax
%define b edx
%define c esi
%define d edi
%define x edi

%define t0 ebp
%define t1 ebx

_norx_permutex:
norx_permutex:
    pushad
    mov    edi, [esp+32+4] ; edi = state
    mov    ecx, [esp+32+8] ; ecx = rounds
e_l1:
    call   load_idx
    dw     0c840H, 0d951H, 0ea62H, 0fb73H
    dw     0fa50H, 0cb61H, 0d872H, 0e943H
load_idx:
    pop    esi  ; pointer to indexes
    push   ecx
    mov    cl, 8
e_l2:
    lodsw
    ; -----------------------------
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
    ; 31, 16, 11, 8
    mov    ecx, 1F100B08h
    mov    t0, [b]
q_l1:
    xor    ebx, ebx
q_l2:
    ; x[a] = PLUS(x[a],x[b]);
    mov    t0, [a]
    and    t0, [b]
    add    t0, t0
    xor    t0, [a]
    xor    t0, [b]
    mov    [a], t0

    ; x[d] = ROTR(XOR(x[d], x[a]), cl);
    ; also x[b] = ROTR(XOR(x[b], x[c]), cl);
    xor    t0, [d]
    ror    t0, cl
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
    ; restore registers
    popad
    ret