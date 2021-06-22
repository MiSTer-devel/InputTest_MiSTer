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
;boot_rom.c:69: clear_chars();
	call	_clear_chars
;boot_rom.c:70: page_border(0b00000111);
	ld	a, #0x07
	push	af
	inc	sp
	call	_page_border
	inc	sp
;boot_rom.c:71: write_string("UDLR", 0xFF, 9, 3);
	ld	hl, #0x0003
	push	hl
	ld	l, #0x09
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
;boot_rom.c:72: write_string("JOY 1)", 0xF0, 2, 4);
	ld	hl, #0x0004
	push	hl
	ld	l, #0x02
	push	hl
	ld	a, #0xf0
	push	af
	inc	sp
	ld	hl, #___str_1
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:73: write_string("JOY 2)", 0xE0, 2, 5);
	ld	hl, #0x0005
	push	hl
	ld	l, #0x02
	push	hl
	ld	a, #0xe0
	push	af
	inc	sp
	ld	hl, #___str_2
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:74: write_string("JOY 3)", 0xD0, 2, 6);
	ld	hl, #0x0006
	push	hl
	ld	l, #0x02
	push	hl
	ld	a, #0xd0
	push	af
	inc	sp
	ld	hl, #___str_3
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:75: }
	ret
___str_0:
	.ascii "UDLR"
	.db 0x00
___str_1:
	.ascii "JOY 1)"
	.db 0x00
___str_2:
	.ascii "JOY 2)"
	.db 0x00
___str_3:
	.ascii "JOY 3)"
	.db 0x00
;boot_rom.c:80: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-24
	add	hl, sp
	ld	sp, hl
;boot_rom.c:82: chram_size = chram_cols * chram_rows;
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
;boot_rom.c:84: page_inputs();
	call	_page_inputs
;boot_rom.c:86: while (1)
	ld	-15 (ix), #0xab
00109$:
;boot_rom.c:88: hsync = input0 & 0x80;
	ld	a,(#_input0 + 0)
	and	a, #0x80
	ld	(#_hsync + 0),a
;boot_rom.c:89: vsync = input0 & 0x40;
	ld	a,(#_input0 + 0)
	and	a, #0x40
	ld	iy, #_vsync
	ld	0 (iy), a
;boot_rom.c:94: if (vsync && !vsync_last)
	ld	a, 0 (iy)
	or	a, a
	jp	Z, 00106$
	ld	a,(#_vsync_last + 0)
	or	a, a
	jp	NZ, 00106$
;boot_rom.c:96: color++;
	inc	-15 (ix)
;boot_rom.c:97: write_string("--- MiSTer Input Tester ---", color, 6, 1);
	ld	hl, #0x0001
	push	hl
	ld	l, #0x06
	push	hl
	ld	a, -15 (ix)
	push	af
	inc	sp
	ld	hl, #___str_4
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:98: int y = 4;
	ld	bc, #0x0004
;boot_rom.c:99: for (char b = 0; b < 2; b++)
	ld	e, #0x00
00118$:
	ld	a, e
	sub	a, #0x02
	jp	NC, 00103$
;boot_rom.c:101: char m = 0b00000001;
	ld	-5 (ix), #0x01
;boot_rom.c:102: for (char i = 0; i < 8; i++)
	ld	-6 (ix), #0x00
00115$:
	ld	a, -6 (ix)
	sub	a, #0x08
	jp	NC, 00119$
;boot_rom.c:104: char x = 9 + i + (b * 10);
	ld	a, -6 (ix)
	add	a, #0x09
	ld	-8 (ix), a
	ld	d, e
	push	de
	ld	a, d
	ld	e, a
	add	a, a
	add	a, a
	add	a, e
	add	a, a
	pop	de
	add	a, -8 (ix)
	ld	-7 (ix), a
;boot_rom.c:105: for (char j = 0; j < 3; j++)
	ld	a, d
	add	a, a
	add	a, a
	add	a, a
	ld	-8 (ix), a
	ld	-2 (ix), #0x00
00112$:
	ld	a, -2 (ix)
	sub	a, #0x03
	jr	NC,00101$
;boot_rom.c:107: write_char((joystick[(b * 8) + (j * 32)] & m) ? asc_1 : asc_0, 0xFF, x, 4 + j);
	ld	a, -2 (ix)
	ld	l, #0x00
	add	a, #0x04
	ld	-14 (ix), a
	ld	a, l
	adc	a, #0x00
	ld	-13 (ix), a
	ld	a, -7 (ix)
	ld	-10 (ix), a
	ld	-9 (ix), #0x00
	ld	a, -2 (ix)
	rrca
	rrca
	rrca
	and	a, #0xe0
	add	a, -8 (ix)
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
	and	a, -5 (ix)
	or	a, a
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
	ld	l, -14 (ix)
	ld	h, -13 (ix)
	push	hl
	ld	l, -10 (ix)
	ld	h, -9 (ix)
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
;boot_rom.c:105: for (char j = 0; j < 3; j++)
	inc	-2 (ix)
	jr	00112$
00101$:
;boot_rom.c:109: m <<= 1;
	ld	a, -5 (ix)
	add	a, a
	ld	-5 (ix), a
;boot_rom.c:102: for (char i = 0; i < 8; i++)
	inc	-6 (ix)
	jp	00115$
00119$:
;boot_rom.c:99: for (char b = 0; b < 2; b++)
	inc	e
	jp	00118$
00103$:
;boot_rom.c:113: y += 6;
	ld	hl, #0x0006
	add	hl, bc
	ld	-4 (ix), l
	ld	-3 (ix), h
;boot_rom.c:115: char m = 0b00000001;
	ld	-10 (ix), #0x01
;boot_rom.c:117: for (char j = 0; j < 8; j++)
	ld	hl, #0x0000
	add	hl, sp
	ld	-14 (ix), l
	ld	-13 (ix), h
	ld	a, -14 (ix)
	ld	-12 (ix), a
	ld	a, -13 (ix)
	ld	-11 (ix), a
	ld	-1 (ix), #0x00
00121$:
	ld	a, -1 (ix)
	sub	a, #0x08
	jr	NC,00106$
;boot_rom.c:119: signed char jx = analog[(j * 16)];
	ld	l, -1 (ix)
	ld	h, #0x00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, #_analog
	add	hl, de
	ld	c, (hl)
;boot_rom.c:120: signed char jy = analog[(j * 16) + 8];
	ld	a, -1 (ix)
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
;boot_rom.c:121: sprintf(str, "%d,%d", jx, jy);
	ld	e, a
	rla
	sbc	a, a
	ld	d, a
	ld	a, c
	rla
	sbc	a, a
	ld	b, a
	ld	l, -14 (ix)
	ld	h, -13 (ix)
	push	de
	push	bc
	ld	bc, #___str_5
	push	bc
	push	hl
	call	_sprintf
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
;boot_rom.c:122: write_string(str, 0xFF, 5, y);
	ld	c, -12 (ix)
	ld	b, -11 (ix)
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	hl, #0x0005
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	push	bc
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:123: m <<= 1;
	ld	a, -10 (ix)
	add	a, a
	ld	-10 (ix), a
;boot_rom.c:117: for (char j = 0; j < 8; j++)
	inc	-1 (ix)
	jr	00121$
00106$:
;boot_rom.c:126: hsync_last = hsync;
	ld	a,(#_hsync + 0)
	ld	(#_hsync_last + 0),a
;boot_rom.c:127: vsync_last = vsync;
	ld	a,(#_vsync + 0)
	ld	(#_vsync_last + 0),a
;boot_rom.c:129: }
	jp	00109$
___str_4:
	.ascii "--- MiSTer Input Tester ---"
	.db 0x00
___str_5:
	.ascii "%d,%d"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
__xinit__asc_0:
	.db #0x30	; 48	'0'
__xinit__asc_1:
	.db #0x31	; 49	'1'
	.area _CABS (ABS)
