;
;  Copyright © 2017 Odzhan. All Rights Reserved.
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

; -----------------------------------------------
; LightMAC-SPECK64/128
;
; size: 152 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------

    bits 32

    %ifndef BIN
      global lightmac_tagx
      global _lightmac_tagx
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

%define SPECK_RNDS    27
; *****************************************
; Light MAC parameters based on SPECK64-128
;
; N = 64-bits
; K = 128-bits
;
%define COUNTER_LENGTH 4  ; should be <= N/2
%define BLOCK_LENGTH   8  ; equal to N
%define TAG_LENGTH     8  ; >= 64-bits && <= N
%define BC_KEY_LENGTH 16  ; K

%define ENCRYPT speck64_encryptx
%define LIGHTMAC_KEY_LENGTH BC_KEY_LENGTH*2 ; K*2

%define k0 edi
%define k1 ebp
%define k2 ecx
%define k3 esi

%define x0 ebx
%define x1 edx

; esi = input
; ebp = key

speck64_encryptx:
      pushad

      push    esi            ; save M

      lodsd                  ; x0 = x->w[0]
      xchg    eax, x0
      lodsd                  ; x1 = x->w[1]
      xchg    eax, x1

      mov     esi, ebp       ; esi = key
      lodsd
      xchg    eax, k0        ; k0 = key[0]
      lodsd
      xchg    eax, k1        ; k1 = key[1]
      lodsd
      xchg    eax, k2        ; k2 = key[2]
      lodsd
      xchg    eax, k3        ; k3 = key[3]
      xor     eax, eax       ; i = 0
spk_el:
      ; x0 = (ROTR32(x0, 8) + x1) ^ k0;
      ror     x0, 8
      add     x0, x1
      xor     x0, k0
      ; x1 = ROTL32(x1, 3) ^ x0;
      rol     x1, 3
      xor     x1, x0
      ; k1 = (ROTR32(k1, 8) + k0) ^ i;
      ror     k1, 8
      add     k1, k0
      xor     k1, eax
      ; k0 = ROTL32(k0, 3) ^ k1;
      rol     k0, 3
      xor     k0, k1
      xchg    k3, k2
      xchg    k3, k1
      ; i++
      inc     eax
      cmp     al, SPECK_RNDS
      jnz     spk_el

      pop     edi
      xchg    eax, x0        ; x->w[0] = x0
      stosd
      xchg    eax, x1        ; x->w[1] = x1
      stosd
      popad
      ret

; void lightmac_tag(const void *msg, uint32_t msglen,
;     void *tag, void* mkey)
lightmac_tagx:
_lightmac_tagx:
      pushad
      lea     esi, [esp+32+4]; esi = argv
      lodsd
      xchg    eax, ebx       ; ebx = msg
      lodsd
      cdq                    ; ctr = 0, idx = 0,
      xchg    eax, ecx       ; ecx = msglen
      lodsd
      xchg    eax, edi       ; edi = tag
      lodsd
      xchg    eax, ebp       ; ebp = mkey
      pushad                 ; allocate N-bytes for M
      ; zero initialize T
      mov     [edi+0], edx   ; t->w[0] = 0;
      mov     [edi+4], edx   ; t->w[1] = 0;
      ; while we have msg data
lmx_l0:
      mov     esi, esp       ; esi = M
      jecxz   lmx_l2         ; exit loop if msglen == 0
lmx_l1:
      ; add byte to M
      mov     al, [ebx]      ; al = *data++
      inc     ebx
      mov     [esi+edx+COUNTER_LENGTH], al
      inc     edx            ; idx++
      ; M filled?
      cmp     dl, BLOCK_LENGTH - COUNTER_LENGTH
      ; --msglen
      loopne  lmx_l1
      jne     lmx_l2
      ; add S counter in big endian format
      inc     dword[esp+_edx]; ctr++
      mov     eax, [esp+_edx]
      ; reset index
      cdq                    ; idx = 0
      bswap   eax            ; m.ctr = SWAP32(ctr)
      mov     [esi], eax
      ; encrypt M with E using K1
      call    ENCRYPT
      ; update T
      lodsd                  ; t->w[0] ^= m.w[0];
      xor     [edi+0], eax
      lodsd                  ; t->w[1] ^= m.w[1];
      xor     [edi+4], eax
      jmp     lmx_l0         ; keep going
lmx_l2:
      ; add the end bit
      mov     byte[esi+edx+COUNTER_LENGTH], 0x80
      xchg    esi, edi       ; swap T and M
lmx_l3:
      ; update T with any msg data remaining
      mov     al, [edi+edx+COUNTER_LENGTH]
      xor     [esi+edx], al
      dec     edx
      jns     lmx_l3
      ; advance key to K2
      add     ebp, BC_KEY_LENGTH
      ; encrypt T with E using K2
      call    ENCRYPT
      popad                  ; release memory for M
      popad                  ; restore registers
      ret
