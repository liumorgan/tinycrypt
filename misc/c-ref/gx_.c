
#define GX_SIZE 128

char GX[] = {
  /* 0000 */ "\x60"                 /* pushad                    */
  /* 0001 */ "\xb9\x18\x79\x37\x9e" /* mov ecx, 0x9e377918       */
  /* 0006 */ "\x8b\x74\x24\x24"     /* mov esi, [esp+0x24]       */
  /* 000A */ "\x51"                 /* push ecx                  */
  /* 000B */ "\x31\xc0"             /* xor eax, eax              */
  /* 000D */ "\x8b\x1c\x86"         /* mov ebx, [esi+eax*4]      */
  /* 0010 */ "\xc1\xcb\x08"         /* ror ebx, 0x8              */
  /* 0013 */ "\x8b\x4c\x86\x10"     /* mov ecx, [esi+eax*4+0x10] */
  /* 0017 */ "\xc1\xc1\x09"         /* rol ecx, 0x9              */
  /* 001A */ "\x8b\x54\x86\x20"     /* mov edx, [esi+eax*4+0x20] */
  /* 001E */ "\x89\xcd"             /* mov ebp, ecx              */
  /* 0020 */ "\x8d\x3c\x12"         /* lea edi, [edx+edx]        */
  /* 0023 */ "\x21\xd5"             /* and ebp, edx              */
  /* 0025 */ "\xc1\xe5\x02"         /* shl ebp, 0x2              */
  /* 0028 */ "\x31\xef"             /* xor edi, ebp              */
  /* 002A */ "\x89\xdd"             /* mov ebp, ebx              */
  /* 002C */ "\x31\xfd"             /* xor ebp, edi              */
  /* 002E */ "\x89\x6c\x86\x20"     /* mov [esi+eax*4+0x20], ebp */
  /* 0032 */ "\x89\xdd"             /* mov ebp, ebx              */
  /* 0034 */ "\x89\xcf"             /* mov edi, ecx              */
  /* 0036 */ "\x09\xd5"             /* or ebp, edx               */
  /* 0038 */ "\xd1\xe5"             /* shl ebp, 1                */
  /* 003A */ "\x31\xdf"             /* xor edi, ebx              */
  /* 003C */ "\x31\xef"             /* xor edi, ebp              */
  /* 003E */ "\x89\x7c\x86\x10"     /* mov [esi+eax*4+0x10], edi */
  /* 0042 */ "\x31\xca"             /* xor edx, ecx              */
  /* 0044 */ "\x21\xcb"             /* and ebx, ecx              */
  /* 0046 */ "\xc1\xe3\x03"         /* shl ebx, 0x3              */
  /* 0049 */ "\x31\xda"             /* xor edx, ebx              */
  /* 004B */ "\x89\x14\x86"         /* mov [esi+eax*4], edx      */
  /* 004E */ "\x40"                 /* inc eax                   */
  /* 004F */ "\x3c\x04"             /* cmp al, 0x4               */
  /* 0051 */ "\x75\xba"             /* jnz 0xd                   */
  /* 0053 */ "\x59"                 /* pop ecx                   */
  /* 0054 */ "\x89\xf7"             /* mov edi, esi              */
  /* 0056 */ "\xad"                 /* lodsd                     */
  /* 0057 */ "\x92"                 /* xchg edx, eax             */
  /* 0058 */ "\xad"                 /* lodsd                     */
  /* 0059 */ "\x93"                 /* xchg ebx, eax             */
  /* 005A */ "\xad"                 /* lodsd                     */
  /* 005B */ "\x95"                 /* xchg ebp, eax             */
  /* 005C */ "\xad"                 /* lodsd                     */
  /* 005D */ "\x96"                 /* xchg esi, eax             */
  /* 005E */ "\x88\xc8"             /* mov al, cl                */
  /* 0060 */ "\x24\x03"             /* and al, 0x3               */
  /* 0062 */ "\x75\x06"             /* jnz 0x6a                  */
  /* 0064 */ "\x87\xda"             /* xchg edx, ebx             */
  /* 0066 */ "\x87\xf5"             /* xchg ebp, esi             */
  /* 0068 */ "\x31\xca"             /* xor edx, ecx              */
  /* 006A */ "\x3c\x02"             /* cmp al, 0x2               */
  /* 006C */ "\x75\x04"             /* jnz 0x72                  */
  /* 006E */ "\x87\xea"             /* xchg edx, ebp             */
  /* 0070 */ "\x87\xf3"             /* xchg ebx, esi             */
  /* 0072 */ "\x92"                 /* xchg edx, eax             */
  /* 0073 */ "\xab"                 /* stosd                     */
  /* 0074 */ "\x93"                 /* xchg ebx, eax             */
  /* 0075 */ "\xab"                 /* stosd                     */
  /* 0076 */ "\x95"                 /* xchg ebp, eax             */
  /* 0077 */ "\xab"                 /* stosd                     */
  /* 0078 */ "\x96"                 /* xchg esi, eax             */
  /* 0079 */ "\xab"                 /* stosd                     */
  /* 007A */ "\xfe\xc9"             /* dec cl                    */
  /* 007C */ "\x75\x88"             /* jnz 0x6                   */
  /* 007E */ "\x61"                 /* popad                     */
  /* 007F */ "\xc3"                 /* ret                       */
};