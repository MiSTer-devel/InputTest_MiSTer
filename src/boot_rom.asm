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
	.globl _spinner
	.globl _paddle
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
_paddle	=	0x7200
_spinner	=	0x7300
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
;boot_rom.c:24: void clear_chars()
;	---------------------------------
; Function clear_chars
; ---------------------------------
_clear_chars::
;boot_rom.c:26: for (unsigned int p = 0; p < chram_size; p++)
	ld	bc, #0x0000
00103$:
	ld	hl, #_chram_size
	ld	a, c
	sub	a, (hl)
	ld	a, b
	inc	hl
	sbc	a, (hl)
	ret	NC
;boot_rom.c:28: chram[p] = 0;
	ld	hl, #_chram+0
	add	hl, bc
	ld	(hl), #0x00
;boot_rom.c:26: for (unsigned int p = 0; p < chram_size; p++)
	inc	bc
;boot_rom.c:30: }
	jr	00103$
_chram_cols:
	.db #0x40	; 64
_chram_rows:
	.db #0x20	; 32
;boot_rom.c:32: void write_string(const char *string, char color, unsigned int x, unsigned int y)
;	---------------------------------
; Function write_string
; ---------------------------------
_write_string::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;boot_rom.c:34: unsigned int p = (y * chram_cols) + x;
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
;boot_rom.c:35: unsigned char l = strlen(string);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_strlen
	pop	af
	ld	c, l
;boot_rom.c:36: for (char c = 0; c < l; c++)
	ld	b, #0x00
00103$:
	ld	a, b
	sub	a, c
	jr	NC,00105$
;boot_rom.c:38: chram[p] = string[c];
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
;boot_rom.c:39: colram[p] = color;
	ld	hl, #_colram
	add	hl, de
	ld	a, 6 (ix)
	ld	(hl), a
;boot_rom.c:40: p++;
	inc	de
;boot_rom.c:36: for (char c = 0; c < l; c++)
	inc	b
	jr	00103$
00105$:
;boot_rom.c:42: }
	ld	sp, ix
	pop	ix
	ret
;boot_rom.c:44: void write_char(unsigned char c, char color, unsigned int x, unsigned int y)
;	---------------------------------
; Function write_char
; ---------------------------------
_write_char::
	push	ix
	ld	ix,#0
	add	ix,sp
;boot_rom.c:46: unsigned int p = (y * chram_cols) + x;
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
;boot_rom.c:47: chram[p] = c;
	ld	hl, #_chram+0
	add	hl, bc
	ld	a, 4 (ix)
	ld	(hl), a
;boot_rom.c:48: colram[p] = color;
	ld	hl, #_colram+0
	add	hl, bc
	ld	a, 5 (ix)
	ld	(hl), a
;boot_rom.c:49: }
	pop	ix
	ret
;boot_rom.c:51: void page_border(char color)
;	---------------------------------
; Function page_border
; ---------------------------------
_page_border::
	push	ix
	ld	ix,#0
	add	ix,sp
;boot_rom.c:53: write_char(128, color, 0, 0);
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
;boot_rom.c:54: write_char(130, color, 39, 0);
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
;boot_rom.c:55: write_char(133, color, 0, 29);
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
;boot_rom.c:56: write_char(132, color, 39, 29);
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
;boot_rom.c:57: for (char x = 1; x < 39; x++)
	ld	c, #0x01
00104$:
	ld	a, c
	sub	a, #0x27
	jr	NC,00101$
;boot_rom.c:59: write_char(129, color, x, 0);
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
;boot_rom.c:57: for (char x = 1; x < 39; x++)
	inc	c
	jr	00104$
00101$:
;boot_rom.c:62: for (char y = 1; y < 29; y++)
	ld	c, #0x01
00107$:
	ld	a, c
	sub	a, #0x1d
	jr	NC,00109$
;boot_rom.c:64: write_char(131, color, 0, y);
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
;boot_rom.c:62: for (char y = 1; y < 29; y++)
	inc	c
	jr	00107$
00109$:
;boot_rom.c:67: }
	pop	ix
	ret
;boot_rom.c:69: void page_inputs()
;	---------------------------------
; Function page_inputs
; ---------------------------------
_page_inputs::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-21
	add	hl, sp
	ld	sp, hl
;boot_rom.c:71: clear_chars();
	call	_clear_chars
;boot_rom.c:72: page_border(0b00000111);
	ld	a, #0x07
	push	af
	inc	sp
	call	_page_border
	inc	sp
;boot_rom.c:73: write_string("UDLRABCXYZLRSs", 0xFF, 7, 3);
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
;boot_rom.c:74: write_string("AX", 0xFF, 26, 3);
	ld	hl, #0x0003
	push	hl
	ld	l, #0x1a
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
;boot_rom.c:75: write_string("AY", 0xFF, 31, 3);
	ld	hl, #0x0003
	push	hl
	ld	l, #0x1f
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	ld	hl, #___str_2
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:78: for (unsigned char j = 0; j < 6; j++)
	ld	hl, #0x0000
	add	hl, sp
	ex	de, hl
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-4 (ix), e
	ld	-3 (ix), d
	ld	-12 (ix), e
	ld	-11 (ix), d
	ld	-14 (ix), e
	ld	-13 (ix), d
	ld	-16 (ix), e
	ld	-15 (ix), d
	ld	-1 (ix), #0x00
00103$:
	ld	a, -1 (ix)
	sub	a, #0x06
	jp	NC, 00105$
;boot_rom.c:80: sprintf(label, "JOY%d", j + 1);
	ld	a, -1 (ix)
	ld	-8 (ix), a
	ld	-7 (ix), #0x00
	ld	a, -8 (ix)
	add	a, #0x01
	ld	-10 (ix), a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	-9 (ix), a
	ld	c, e
	ld	b, d
	push	de
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	push	hl
	ld	hl, #___str_3
	push	hl
	push	bc
	call	_sprintf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
;boot_rom.c:81: write_string(label, 0xFF - (j * 2), 2, 4 + j);
	ld	a, -8 (ix)
	add	a, #0x04
	ld	l, a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	h, a
	ld	a, -1 (ix)
	add	a, a
	ld	c, a
	ld	a, #0xff
	sub	a, c
	ld	-2 (ix), a
	ld	c, -6 (ix)
	ld	b, -5 (ix)
	push	de
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	a, -2 (ix)
	push	af
	inc	sp
	push	bc
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
	pop	de
;boot_rom.c:83: sprintf(label, "PAD%d", j + 1);
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	push	de
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	push	hl
	ld	hl, #___str_4
	push	hl
	push	bc
	call	_sprintf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
;boot_rom.c:84: write_string(label, 0xFF - (j * 2), 2, 11 + j);
	ld	a, -8 (ix)
	add	a, #0x0b
	ld	l, a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	h, a
	ld	c, -12 (ix)
	ld	b, -11 (ix)
	push	de
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	a, -2 (ix)
	push	af
	inc	sp
	push	bc
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
	pop	de
;boot_rom.c:86: sprintf(label, "SPN%d", j + 1);
	ld	c, -14 (ix)
	ld	b, -13 (ix)
	push	de
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	push	hl
	ld	hl, #___str_5
	push	hl
	push	bc
	call	_sprintf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
;boot_rom.c:87: write_string(label, 0xFF - (j * 2), 2, 18 + j);
	ld	a, -8 (ix)
	add	a, #0x12
	ld	l, a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	h, a
	ld	c, -16 (ix)
	ld	b, -15 (ix)
	push	de
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	a, -2 (ix)
	push	af
	inc	sp
	push	bc
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
	pop	de
;boot_rom.c:78: for (unsigned char j = 0; j < 6; j++)
	inc	-1 (ix)
	jp	00103$
00105$:
;boot_rom.c:89: }
	ld	sp, ix
	pop	ix
	ret
___str_0:
	.ascii "UDLRABCXYZLRSs"
	.db 0x00
___str_1:
	.ascii "AX"
	.db 0x00
___str_2:
	.ascii "AY"
	.db 0x00
___str_3:
	.ascii "JOY%d"
	.db 0x00
___str_4:
	.ascii "PAD%d"
	.db 0x00
___str_5:
	.ascii "SPN%d"
	.db 0x00
;boot_rom.c:94: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-27
	add	hl, sp
	ld	sp, hl
;boot_rom.c:96: chram_size = chram_cols * chram_rows;
	ld	hl,#_chram_rows + 0
	ld	e, (hl)
	ld	hl,#_chram_cols + 0
	ld	h, (hl)
	ld	l, #0x00
	ld	d, l
	ld	b, #0x08
00212$:
	add	hl, hl
	jr	NC,00213$
	add	hl, de
00213$:
	djnz	00212$
	ld	(_chram_size), hl
;boot_rom.c:98: page_inputs();
	call	_page_inputs
;boot_rom.c:100: while (1)
	ld	c, #0xab
00111$:
;boot_rom.c:102: hsync = input0 & 0x80;
	ld	a,(#_input0 + 0)
	and	a, #0x80
	ld	(#_hsync + 0),a
;boot_rom.c:103: vsync = input0 & 0x40;
	ld	a,(#_input0 + 0)
	and	a, #0x40
	ld	iy, #_vsync
	ld	0 (iy), a
;boot_rom.c:110: if (vsync && !vsync_last)
	ld	a, 0 (iy)
	or	a, a
	jp	Z, 00108$
	ld	a,(#_vsync_last + 0)
	or	a, a
	jp	NZ, 00108$
;boot_rom.c:112: color++;
	inc	c
;boot_rom.c:113: write_string("--- MiSTer Input Tester ---", color, 6, 1);
	push	bc
	ld	hl, #0x0001
	push	hl
	ld	l, #0x06
	push	hl
	ld	a, c
	push	af
	inc	sp
	ld	hl, #___str_6
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
	pop	bc
;boot_rom.c:115: for (char b = 0; b < 2; b++)
	ld	e, #0x00
00119$:
	ld	a, e
	sub	a, #0x02
	jp	NC, 00103$
;boot_rom.c:117: char m = 0b00000001;
	ld	-2 (ix), #0x01
;boot_rom.c:118: for (char i = 0; i < 8; i++)
	ld	-3 (ix), #0x00
00116$:
	ld	a, -3 (ix)
	sub	a, #0x08
	jp	NC, 00120$
;boot_rom.c:120: char x = 7 + i + (b * 8);
	ld	a, -3 (ix)
	add	a, #0x07
	ld	b, a
	ld	a, e
	add	a, a
	add	a, a
	add	a, a
	ld	-7 (ix), a
	ld	a, b
	add	a, -7 (ix)
	ld	-6 (ix), a
;boot_rom.c:121: for (j = 0; j < 6; j++)
	ld	-1 (ix), #0x00
00113$:
;boot_rom.c:123: write_char((joystick[(b * 8) + (j * 32)] & m) ? asc_1 : asc_0, 0xFF, x, 4 + j);
	ld	a, -1 (ix)
	ld	d, #0x00
	add	a, #0x04
	ld	-11 (ix), a
	ld	a, d
	adc	a, #0x00
	ld	-10 (ix), a
	ld	a, -6 (ix)
	ld	-9 (ix), a
	ld	-8 (ix), #0x00
	ld	a, -1 (ix)
	rrca
	rrca
	rrca
	and	a, #0xe0
	add	a, -7 (ix)
	ld	b, a
	rla
	sbc	a, a
	ld	d, a
	ld	a, #<(_joystick)
	add	a, b
	ld	l, a
	ld	a, #>(_joystick)
	adc	a, d
	ld	h, a
	ld	a, (hl)
	and	a, -2 (ix)
	or	a, a
	jr	Z,00129$
	ld	hl,#_asc_1 + 0
	ld	b, (hl)
	jr	00130$
00129$:
	ld	hl,#_asc_0 + 0
	ld	b, (hl)
00130$:
	push	bc
	push	de
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	push	hl
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	push	hl
	ld	a, #0xff
	push	af
	inc	sp
	push	bc
	inc	sp
	call	_write_char
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
	pop	bc
;boot_rom.c:121: for (j = 0; j < 6; j++)
	inc	-1 (ix)
	ld	a, -1 (ix)
	sub	a, #0x06
	jr	C,00113$
;boot_rom.c:125: m <<= 1;
	ld	a, -2 (ix)
	add	a, a
	ld	-2 (ix), a
;boot_rom.c:118: for (char i = 0; i < 8; i++)
	inc	-3 (ix)
	jp	00116$
00120$:
;boot_rom.c:115: for (char b = 0; b < 2; b++)
	inc	e
	jp	00119$
00103$:
;boot_rom.c:129: y = 4;
	ld	-5 (ix), #0x04
	ld	-4 (ix), #0x00
;boot_rom.c:131: char m = 0b00000001;
	ld	b, #0x01
;boot_rom.c:134: for (j = 0; j < 6; j++)
	ld	hl, #0x0006
	add	hl, sp
	ld	-9 (ix), l
	ld	-8 (ix), h
	ld	a, -9 (ix)
	ld	-11 (ix), a
	ld	a, -8 (ix)
	ld	-10 (ix), a
	ld	-1 (ix), #0x00
00121$:
;boot_rom.c:136: signed char jx = analog[(j * 16)];
	ld	de, #_analog+0
	ld	l, -1 (ix)
	ld	h, #0x00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	e, (hl)
;boot_rom.c:137: signed char jy = analog[(j * 16) + 8];
	ld	a, -1 (ix)
	rlca
	rlca
	rlca
	rlca
	and	a, #0xf0
	add	a, #0x08
	ld	l, a
	rla
	sbc	a, a
	ld	h, a
	push	de
	ld	de, #_analog
	add	hl, de
	pop	de
	ld	a, (hl)
;boot_rom.c:139: sprintf(stra, "%4d %4d", jx, jy);
	ld	l, a
	rla
	sbc	a, a
	ld	h, a
	ld	a, e
	rla
	sbc	a, a
	ld	d, a
	push	hl
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	push	hl
	pop	iy
	pop	hl
	push	bc
	push	hl
	push	de
	ld	hl, #___str_7
	push	hl
	push	iy
	call	_sprintf
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
	pop	bc
;boot_rom.c:140: write_string(stra, 0xFF, 24, y + j);
	ld	e, -1 (ix)
	ld	d, #0x00
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	add	hl, de
	ld	e, -11 (ix)
	ld	d, -10 (ix)
	push	bc
	push	hl
	ld	hl, #0x0018
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
;boot_rom.c:143: m <<= 1;
	sla	b
;boot_rom.c:134: for (j = 0; j < 6; j++)
	inc	-1 (ix)
	ld	a, -1 (ix)
	sub	a, #0x06
	jr	C,00121$
;boot_rom.c:148: m = 0b00000001;
	ld	b, #0x01
;boot_rom.c:150: for (j = 0; j < 6; j++)
	ld	hl, #0x0003
	add	hl, sp
	ld	-9 (ix), l
	ld	-8 (ix), h
	ld	a, -9 (ix)
	ld	-11 (ix), a
	ld	a, -8 (ix)
	ld	-10 (ix), a
	ld	-1 (ix), #0x00
00123$:
;boot_rom.c:152: char px = paddle[(j * 8)];
	ld	e, -1 (ix)
	ld	d, #0x00
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a, #<(_paddle)
	add	a, l
	ld	l, a
	ld	a, #>(_paddle)
	adc	a, h
	ld	h, a
	ld	l, (hl)
;boot_rom.c:153: sprintf(strp, "%4d", px);
	ld	h, #0x00
	push	hl
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	push	hl
	pop	iy
	pop	hl
	push	bc
	push	de
	push	hl
	ld	hl, #___str_8
	push	hl
	push	iy
	call	_sprintf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
	pop	bc
;boot_rom.c:154: write_string(strp, 0xFF, 6, y + j);
	ld	hl, #0x000b
	add	hl, de
	ld	e, -11 (ix)
	ld	d, -10 (ix)
	push	bc
	push	hl
	ld	hl, #0x0006
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
;boot_rom.c:155: m <<= 1;
	sla	b
;boot_rom.c:150: for (j = 0; j < 6; j++)
	inc	-1 (ix)
	ld	a, -1 (ix)
	sub	a, #0x06
	jr	C,00123$
;boot_rom.c:160: m = 0b00000001;
	ld	b, #0x01
;boot_rom.c:162: for (j = 0; j < 6; j++)
	ld	hl, #0x0000
	add	hl, sp
	ld	-9 (ix), l
	ld	-8 (ix), h
	ld	a, -9 (ix)
	ld	-11 (ix), a
	ld	a, -8 (ix)
	ld	-10 (ix), a
	ld	-1 (ix), #0x00
00125$:
;boot_rom.c:164: signed char sx = spinner[(j * 16)];
	ld	e, -1 (ix)
	ld	d, #0x00
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a, #<(_spinner)
	add	a, l
	ld	l, a
	ld	a, #>(_spinner)
	adc	a, h
	ld	h, a
	ld	a, (hl)
;boot_rom.c:165: sprintf(strs, "%4d", sx);
	ld	l, a
	rla
	sbc	a, a
	ld	h, a
	push	hl
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	push	hl
	pop	iy
	pop	hl
	push	bc
	push	de
	push	hl
	ld	hl, #___str_8
	push	hl
	push	iy
	call	_sprintf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
	pop	bc
;boot_rom.c:166: write_string(strs, 0xFF, 7, y + j);
	ld	hl, #0x0012
	add	hl, de
	ld	e, -11 (ix)
	ld	d, -10 (ix)
	push	bc
	push	hl
	ld	hl, #0x0007
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
;boot_rom.c:167: m <<= 1;
	sla	b
;boot_rom.c:162: for (j = 0; j < 6; j++)
	inc	-1 (ix)
	ld	a, -1 (ix)
	sub	a, #0x06
	jr	C,00125$
00108$:
;boot_rom.c:171: hsync_last = hsync;
	ld	a,(#_hsync + 0)
	ld	(#_hsync_last + 0),a
;boot_rom.c:172: vsync_last = vsync;
	ld	a,(#_vsync + 0)
	ld	(#_vsync_last + 0),a
;boot_rom.c:174: }
	jp	00111$
___str_6:
	.ascii "--- MiSTer Input Tester ---"
	.db 0x00
___str_7:
	.ascii "%4d %4d"
	.db 0x00
___str_8:
	.ascii "%4d"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
__xinit__asc_0:
	.db #0x30	; 48	'0'
__xinit__asc_1:
	.db #0x31	; 49	'1'
	.area _CABS (ABS)
