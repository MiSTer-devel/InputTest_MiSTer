;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.8.0 #10562 (Linux)
;--------------------------------------------------------
	.module boot_rom
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _page_inputs
	.globl _page_border
	.globl _write_char
	.globl _write_string
	.globl _clear_chars
	.globl _strlen
	.globl _sprintf
	.globl _asc_1
	.globl _asc_0
	.globl _vsync_last
	.globl _vsync
	.globl _hsync_last
	.globl _hsync
	.globl _chram_size
	.globl _colram
	.globl _chram
	.globl _analog
	.globl _joystick
	.globl _input0
	.globl _chram_rows
	.globl _chram_cols
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_input0	=	0x6000
_joystick	=	0x7000
_analog	=	0x7100
_chram	=	0x8000
_colram	=	0x8800
_chram_size::
	.ds 2
_hsync::
	.ds 1
_hsync_last::
	.ds 1
_vsync::
	.ds 1
_vsync_last::
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_asc_0::
	.ds 1
_asc_1::
	.ds 1
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;boot_rom.c:22: void clear_chars()
;	---------------------------------
; Function clear_chars
; ---------------------------------
_clear_chars::
;boot_rom.c:24: for (unsigned int p = 0; p < chram_size; p++)
	ld	bc, #0x0000
00103$:
	ld	hl, #_chram_size
	ld	a, c
	sub	a, (hl)
	ld	a, b
	inc	hl
	sbc	a, (hl)
	ret	NC
;boot_rom.c:26: chram[p] = 0;
	ld	hl, #_chram+0
	add	hl, bc
	ld	(hl), #0x00
;boot_rom.c:24: for (unsigned int p = 0; p < chram_size; p++)
	inc	bc
;boot_rom.c:28: }
	jr	00103$
_chram_cols:
	.db #0x40	; 64
_chram_rows:
	.db #0x20	; 32
;boot_rom.c:30: void write_string(const char *string, char color, unsigned int x, unsigned int y)
;	---------------------------------
; Function write_string
; ---------------------------------
_write_string::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;boot_rom.c:32: unsigned int p = (y * chram_cols) + x;
	ld	hl,#_chram_cols + 0
	ld	c, (hl)
	ld	b, #0x00
	push	bc
	ld	l, 9 (ix)
	ld	h, 10 (ix)
	push	hl
	call	__mulint
	pop	af
	pop	af
	ld	c, l
	ld	b, h
	ld	l, 7 (ix)
	ld	h, 8 (ix)
	add	hl, bc
	ex	de,hl
;boot_rom.c:33: unsigned char l = strlen(string);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_strlen
	pop	af
	ld	c, l
;boot_rom.c:34: for (char c = 0; c < l; c++)
	ld	b, #0x00
00103$:
	ld	a, b
	sub	a, c
	jr	NC,00105$
;boot_rom.c:36: chram[p] = string[c];
	ld	hl, #_chram
	add	hl, de
	ex	(sp), hl
	ld	a, 4 (ix)
	add	a, b
	ld	l, a
	ld	a, 5 (ix)
	adc	a, #0x00
	ld	h, a
	ld	a, (hl)
	pop	hl
	push	hl
	ld	(hl), a
;boot_rom.c:37: colram[p] = color;
	ld	hl, #_colram
	add	hl, de
	ld	a, 6 (ix)
	ld	(hl), a
;boot_rom.c:38: p++;
	inc	de
;boot_rom.c:34: for (char c = 0; c < l; c++)
	inc	b
	jr	00103$
00105$:
;boot_rom.c:40: }
	ld	sp, ix
	pop	ix
	ret
;boot_rom.c:42: void write_char(unsigned char c, char color, unsigned int x, unsigned int y)
;	---------------------------------
; Function write_char
; ---------------------------------
_write_char::
	push	ix
	ld	ix,#0
	add	ix,sp
;boot_rom.c:44: unsigned int p = (y * chram_cols) + x;
	ld	hl,#_chram_cols + 0
	ld	c, (hl)
	ld	b, #0x00
	push	bc
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	call	__mulint
	pop	af
	pop	af
	ld	c, l
	ld	b, h
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	add	hl, bc
	ld	c, l
	ld	b, h
;boot_rom.c:45: chram[p] = c;
	ld	hl, #_chram+0
	add	hl, bc
	ld	a, 4 (ix)
	ld	(hl), a
;boot_rom.c:46: colram[p] = color;
	ld	hl, #_colram+0
	add	hl, bc
	ld	a, 5 (ix)
	ld	(hl), a
;boot_rom.c:47: }
	pop	ix
	ret
;boot_rom.c:49: void page_border(char color)
;	---------------------------------
; Function page_border
; ---------------------------------
_page_border::
	push	ix
	ld	ix,#0
	add	ix,sp
;boot_rom.c:51: write_char(128, color, 0, 0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	ld	d, 4 (ix)
	ld	e,#0x80
	push	de
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;boot_rom.c:52: write_char(130, color, 39, 0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x27
	push	hl
	ld	d, 4 (ix)
	ld	e,#0x82
	push	de
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;boot_rom.c:53: write_char(133, color, 0, 29);
	ld	hl, #0x001d
	push	hl
	ld	l, #0x00
	push	hl
	ld	d, 4 (ix)
	ld	e,#0x85
	push	de
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;boot_rom.c:54: write_char(132, color, 39, 29);
	ld	hl, #0x001d
	push	hl
	ld	l, #0x27
	push	hl
	ld	d, 4 (ix)
	ld	e,#0x84
	push	de
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;boot_rom.c:55: for (char x = 1; x < 39; x++)
	ld	c, #0x01
00104$:
	ld	a, c
	sub	a, #0x27
	jr	NC,00101$
;boot_rom.c:57: write_char(129, color, x, 0);
	ld	e, c
	ld	d, #0x00
	push	bc
	push	de
	ld	hl, #0x0000
	push	hl
	push	de
	ld	d, 4 (ix)
	ld	e,#0x81
	push	de
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
	ld	hl, #0x001d
	push	hl
	push	de
	ld	d, 4 (ix)
	ld	e,#0x81
	push	de
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	bc
;boot_rom.c:55: for (char x = 1; x < 39; x++)
	inc	c
	jr	00104$
00101$:
;boot_rom.c:60: for (char y = 1; y < 29; y++)
	ld	c, #0x01
00107$:
	ld	a, c
	sub	a, #0x1d
	jr	NC,00109$
;boot_rom.c:62: write_char(131, color, 0, y);
	ld	e, c
	ld	d, #0x00
	push	bc
	push	de
	push	de
	ld	hl, #0x0000
	push	hl
	ld	d, 4 (ix)
	ld	e,#0x83
	push	de
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	ld	hl, #0x0027
	push	hl
	ld	d, 4 (ix)
	ld	e,#0x83
	push	de
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	bc
;boot_rom.c:60: for (char y = 1; y < 29; y++)
	inc	c
	jr	00107$
00109$:
;boot_rom.c:65: }
	pop	ix
	ret
;boot_rom.c:67: void page_inputs()
;	---------------------------------
; Function page_inputs
; ---------------------------------
_page_inputs::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;boot_rom.c:69: clear_chars();
	call	_clear_chars
;boot_rom.c:70: page_border(0b00000111);
	ld	a, #0x07
	push	af
	inc	sp
	call	_page_border
	inc	sp
;boot_rom.c:71: write_string("UDLRABCXYZLRSs", 0xFF, 7, 3);
	ld	hl, #0x0003
	push	hl
	ld	l, #0x07
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	ld	hl, #___str_0
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:72: write_string("AX  AY", 0xFF, 25, 3);
	ld	hl, #0x0003
	push	hl
	ld	l, #0x19
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	ld	hl, #___str_1
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:75: for (unsigned char j = 0; j < 6; j++)
	ld	hl, #0x0000
	add	hl, sp
	ld	-3 (ix), l
	ld	-2 (ix), h
	ld	a, -3 (ix)
	ld	-5 (ix), a
	ld	a, -2 (ix)
	ld	-4 (ix), a
	ld	-1 (ix), #0x00
00103$:
	ld	a, -1 (ix)
	sub	a, #0x06
	jr	NC,00105$
;boot_rom.c:77: sprintf(label, "JOY%d", j + 1);
	ld	c, -1 (ix)
	ld	b, #0x00
	ld	e, c
	ld	d, b
	inc	de
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	push	bc
	push	de
	ld	de, #___str_2
	push	de
	push	hl
	call	_sprintf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	bc
;boot_rom.c:78: write_string(label, 0xFF - (j*2), 2, 4 + j);
	inc	bc
	inc	bc
	inc	bc
	inc	bc
	ld	a, -1 (ix)
	add	a, a
	ld	e, a
	ld	a, #0xff
	sub	a, e
	ld	h, a
	ld	e, -5 (ix)
	ld	d, -4 (ix)
	push	bc
	ld	bc, #0x0002
	push	bc
	push	hl
	inc	sp
	push	de
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:75: for (unsigned char j = 0; j < 6; j++)
	inc	-1 (ix)
	jr	00103$
00105$:
;boot_rom.c:80: }
	ld	sp, ix
	pop	ix
	ret
___str_0:
	.ascii "UDLRABCXYZLRSs"
	.db 0x00
___str_1:
	.ascii "AX  AY"
	.db 0x00
___str_2:
	.ascii "JOY%d"
	.db 0x00
;boot_rom.c:85: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-20
	add	hl, sp
	ld	sp, hl
;boot_rom.c:87: chram_size = chram_cols * chram_rows;
	ld	hl,#_chram_rows + 0
	ld	e, (hl)
	ld	hl,#_chram_cols + 0
	ld	h, (hl)
	ld	l, #0x00
	ld	d, l
	ld	b, #0x08
00191$:
	add	hl, hl
	jr	NC,00192$
	add	hl, de
00192$:
	djnz	00191$
	ld	(_chram_size), hl
;boot_rom.c:89: page_inputs();
	call	_page_inputs
;boot_rom.c:91: while (1)
	ld	-5 (ix), #0xab
00109$:
;boot_rom.c:93: hsync = input0 & 0x80;
	ld	a,(#_input0 + 0)
	and	a, #0x80
	ld	(#_hsync + 0),a
;boot_rom.c:94: vsync = input0 & 0x40;
	ld	a,(#_input0 + 0)
	and	a, #0x40
	ld	iy, #_vsync
	ld	0 (iy), a
;boot_rom.c:99: if (vsync && !vsync_last)
	ld	a, 0 (iy)
	or	a, a
	jp	Z, 00106$
	ld	a,(#_vsync_last + 0)
	or	a, a
	jp	NZ, 00106$
;boot_rom.c:101: color++;
	inc	-5 (ix)
;boot_rom.c:102: write_string("--- MiSTer Input Tester ---", color, 6, 1);
	ld	hl, #0x0001
	push	hl
	ld	l, #0x06
	push	hl
	ld	a, -5 (ix)
	push	af
	inc	sp
	ld	hl, #___str_3
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:104: for (char b = 0; b < 2; b++)
	ld	c, #0x00
00118$:
	ld	a, c
	sub	a, #0x02
	jp	NC, 00103$
;boot_rom.c:106: char m = 0b00000001;
	ld	b, #0x01
;boot_rom.c:107: for (char i = 0; i < 8; i++)
	ld	e, #0x00
00115$:
;boot_rom.c:109: char x = 7 + i + (b * 8);
	ld	a,e
	cp	a,#0x08
	jp	NC,00119$
	add	a, #0x07
	ld	d, a
	ld	a, c
	add	a, a
	add	a, a
	add	a, a
	ld	-6 (ix), a
	ld	a, d
	add	a, -6 (ix)
	ld	-1 (ix), a
;boot_rom.c:110: for (char j = 0; j < 6; j++)
	ld	-4 (ix), #0x00
00112$:
	ld	a, -4 (ix)
	sub	a, #0x06
	jr	NC,00101$
;boot_rom.c:112: write_char((joystick[(b * 8) + (j * 32)] & m) ? asc_1 : asc_0, 0xFF, x, 4 + j);
	ld	a, -4 (ix)
	ld	l, #0x00
	add	a, #0x04
	ld	-12 (ix), a
	ld	a, l
	adc	a, #0x00
	ld	-11 (ix), a
	ld	a, -1 (ix)
	ld	-14 (ix), a
	ld	-13 (ix), #0x00
	ld	a, -4 (ix)
	rrca
	rrca
	rrca
	and	a, #0xe0
	add	a, -6 (ix)
	ld	d, a
	rla
	sbc	a, a
	ld	h, a
	ld	a, #<(_joystick)
	add	a, d
	ld	l, a
	ld	a, #>(_joystick)
	adc	a, h
	ld	h, a
	ld	a, (hl)
	and	a,b
	jr	Z,00125$
	ld	hl,#_asc_1 + 0
	ld	d, (hl)
	jr	00126$
00125$:
	ld	hl,#_asc_0 + 0
	ld	d, (hl)
00126$:
	push	bc
	push	de
	ld	l, -12 (ix)
	ld	h, -11 (ix)
	push	hl
	ld	l, -14 (ix)
	ld	h, -13 (ix)
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	push	de
	inc	sp
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
	pop	bc
;boot_rom.c:110: for (char j = 0; j < 6; j++)
	inc	-4 (ix)
	jr	00112$
00101$:
;boot_rom.c:114: m <<= 1;
	sla	b
;boot_rom.c:107: for (char i = 0; i < 8; i++)
	inc	e
	jp	00115$
00119$:
;boot_rom.c:104: for (char b = 0; b < 2; b++)
	inc	c
	jp	00118$
00103$:
;boot_rom.c:120: char m = 0b00000001;
	ld	-14 (ix), #0x01
;boot_rom.c:122: for (char j = 0; j < 6; j++)
	ld	hl, #0x0000
	add	hl, sp
	ld	-12 (ix), l
	ld	-11 (ix), h
	ld	a, -12 (ix)
	ld	-8 (ix), a
	ld	a, -11 (ix)
	ld	-7 (ix), a
	ld	a, -12 (ix)
	ld	-10 (ix), a
	ld	a, -11 (ix)
	ld	-9 (ix), a
	ld	a, -12 (ix)
	ld	-16 (ix), a
	ld	a, -11 (ix)
	ld	-15 (ix), a
	ld	-2 (ix), #0x00
00121$:
	ld	a, -2 (ix)
	sub	a, #0x06
	jp	NC, 00106$
;boot_rom.c:124: signed char jx = analog[(j * 16)];
	ld	l, -2 (ix)
	ld	h, #0x00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, #_analog
	add	hl, de
	ld	c, (hl)
;boot_rom.c:125: signed char jy = analog[(j * 16) + 8];
	ld	a, -2 (ix)
	rlca
	rlca
	rlca
	rlca
	and	a, #0xf0
	add	a, #0x08
	ld	e, a
	rla
	sbc	a, a
	ld	d, a
	ld	hl, #_analog
	add	hl, de
	ld	a, (hl)
	ld	-3 (ix), a
;boot_rom.c:126: sprintf(str, "%d", jx);
	ld	a, c
	rla
	sbc	a, a
	ld	b, a
	ld	e, -12 (ix)
	ld	d, -11 (ix)
	push	bc
	ld	hl, #___str_4
	push	hl
	push	de
	call	_sprintf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;boot_rom.c:127: write_string(str, 0xFF, 25, y + j);
	ld	c, -2 (ix)
	ld	b, #0x00
	inc	bc
	inc	bc
	inc	bc
	inc	bc
	ld	e, -8 (ix)
	ld	d, -7 (ix)
	push	bc
	push	bc
	ld	hl, #0x0019
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	push	de
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
	pop	bc
;boot_rom.c:128: sprintf(str, "%d", jy);
	ld	a, -3 (ix)
	ld	e, a
	rla
	sbc	a, a
	ld	d, a
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	push	bc
	push	de
	ld	de, #___str_4
	push	de
	push	hl
	call	_sprintf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	bc
;boot_rom.c:129: write_string(str, 0xFF, 29, y + j);
	ld	e, -16 (ix)
	ld	d, -15 (ix)
	push	bc
	ld	hl, #0x001d
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	push	de
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:130: m <<= 1;
	ld	a, -14 (ix)
	add	a, a
	ld	-14 (ix), a
;boot_rom.c:122: for (char j = 0; j < 6; j++)
	inc	-2 (ix)
	jp	00121$
00106$:
;boot_rom.c:133: hsync_last = hsync;
	ld	a,(#_hsync + 0)
	ld	(#_hsync_last + 0),a
;boot_rom.c:134: vsync_last = vsync;
	ld	a,(#_vsync + 0)
	ld	(#_vsync_last + 0),a
;boot_rom.c:136: }
	jp	00109$
___str_3:
	.ascii "--- MiSTer Input Tester ---"
	.db 0x00
___str_4:
	.ascii "%d"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
__xinit__asc_0:
	.db #0x30	; 48	'0'
__xinit__asc_1:
	.db #0x31	; 49	'1'
	.area _CABS (ABS)
