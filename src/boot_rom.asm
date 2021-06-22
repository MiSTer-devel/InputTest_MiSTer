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
	.globl _asc_1
	.globl _asc_0
	.globl _vsync_last
	.globl _vsync
	.globl _hsync_last
	.globl _hsync
	.globl _chram_size
	.globl _colram
	.globl _chram
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
;boot_rom.c:21: void clear_chars()
;	---------------------------------
; Function clear_chars
; ---------------------------------
_clear_chars::
;boot_rom.c:23: for (unsigned int p = 0; p < chram_size; p++)
	ld	bc, #0x0000
00103$:
	ld	hl, #_chram_size
	ld	a, c
	sub	a, (hl)
	ld	a, b
	inc	hl
	sbc	a, (hl)
	ret	NC
;boot_rom.c:25: chram[p] = 0;
	ld	hl, #_chram+0
	add	hl, bc
	ld	(hl), #0x00
;boot_rom.c:23: for (unsigned int p = 0; p < chram_size; p++)
	inc	bc
;boot_rom.c:27: }
	jr	00103$
_chram_cols:
	.db #0x40	; 64
_chram_rows:
	.db #0x20	; 32
;boot_rom.c:29: void write_string(const char *string, char color, unsigned int x, unsigned int y)
;	---------------------------------
; Function write_string
; ---------------------------------
_write_string::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;boot_rom.c:31: unsigned int p = (y * chram_cols) + x;
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
;boot_rom.c:32: unsigned char l = strlen(string);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_strlen
	pop	af
	ld	c, l
;boot_rom.c:33: for (char c = 0; c < l; c++)
	ld	b, #0x00
00103$:
	ld	a, b
	sub	a, c
	jr	NC,00105$
;boot_rom.c:35: chram[p] = string[c];
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
;boot_rom.c:36: colram[p] = color;
	ld	hl, #_colram
	add	hl, de
	ld	a, 6 (ix)
	ld	(hl), a
;boot_rom.c:37: p++;
	inc	de
;boot_rom.c:33: for (char c = 0; c < l; c++)
	inc	b
	jr	00103$
00105$:
;boot_rom.c:39: }
	ld	sp, ix
	pop	ix
	ret
;boot_rom.c:41: void write_char(unsigned char c, char color, unsigned int x, unsigned int y)
;	---------------------------------
; Function write_char
; ---------------------------------
_write_char::
	push	ix
	ld	ix,#0
	add	ix,sp
;boot_rom.c:43: unsigned int p = (y * chram_cols) + x;
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
;boot_rom.c:44: chram[p] = c;
	ld	hl, #_chram+0
	add	hl, bc
	ld	a, 4 (ix)
	ld	(hl), a
;boot_rom.c:45: colram[p] = color;
	ld	hl, #_colram+0
	add	hl, bc
	ld	a, 5 (ix)
	ld	(hl), a
;boot_rom.c:46: }
	pop	ix
	ret
;boot_rom.c:48: void page_border(char color)
;	---------------------------------
; Function page_border
; ---------------------------------
_page_border::
	push	ix
	ld	ix,#0
	add	ix,sp
;boot_rom.c:50: write_char(128, color, 0, 0);
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
;boot_rom.c:51: write_char(130, color, 39, 0);
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
;boot_rom.c:52: write_char(133, color, 0, 29);
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
;boot_rom.c:53: write_char(132, color, 39, 29);
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
;boot_rom.c:54: for (char x = 1; x < 39; x++)
	ld	c, #0x01
00104$:
	ld	a, c
	sub	a, #0x27
	jr	NC,00101$
;boot_rom.c:56: write_char(129, color, x, 0);
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
;boot_rom.c:54: for (char x = 1; x < 39; x++)
	inc	c
	jr	00104$
00101$:
;boot_rom.c:59: for (char y = 1; y < 29; y++)
	ld	c, #0x01
00107$:
	ld	a, c
	sub	a, #0x1d
	jr	NC,00109$
;boot_rom.c:61: write_char(131, color, 0, y);
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
;boot_rom.c:59: for (char y = 1; y < 29; y++)
	inc	c
	jr	00107$
00109$:
;boot_rom.c:64: }
	pop	ix
	ret
;boot_rom.c:66: void page_inputs()
;	---------------------------------
; Function page_inputs
; ---------------------------------
_page_inputs::
;boot_rom.c:68: clear_chars();
	call	_clear_chars
;boot_rom.c:69: page_border(0b00000111);
	ld	a, #0x07
	push	af
	inc	sp
	call	_page_border
	inc	sp
;boot_rom.c:70: write_string("UDLR", 0xFF, 9, 3);
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
;boot_rom.c:71: write_string("JOY 1)", 0xF0, 2, 4);
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
;boot_rom.c:72: write_string("JOY 2)", 0xE0, 2, 5);
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
;boot_rom.c:73: }
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
;boot_rom.c:78: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:80: chram_size = chram_cols * chram_rows;
	ld	hl,#_chram_rows + 0
	ld	e, (hl)
	ld	hl,#_chram_cols + 0
	ld	h, (hl)
	ld	l, #0x00
	ld	d, l
	ld	b, #0x08
00176$:
	add	hl, hl
	jr	NC,00177$
	add	hl, de
00177$:
	djnz	00176$
	ld	(_chram_size), hl
;boot_rom.c:82: page_inputs();
	call	_page_inputs
;boot_rom.c:84: while (1)
	ld	b, #0xab
00108$:
;boot_rom.c:86: hsync = input0 & 0x80;
	ld	a,(#_input0 + 0)
	and	a, #0x80
	ld	(#_hsync + 0),a
;boot_rom.c:87: vsync = input0 & 0x40;
	ld	a,(#_input0 + 0)
	and	a, #0x40
	ld	iy, #_vsync
	ld	0 (iy), a
;boot_rom.c:92: if (vsync && !vsync_last)
	ld	a, 0 (iy)
	or	a, a
	jp	Z, 00105$
	ld	a,(#_vsync_last + 0)
	or	a, a
	jp	NZ, 00105$
;boot_rom.c:94: color++;
	inc	b
;boot_rom.c:95: write_string("--- MiSTer Input Tester ---", color, 6, 1);
	push	bc
	ld	hl, #0x0001
	push	hl
	ld	l, #0x06
	push	hl
	push	bc
	inc	sp
	ld	hl, #___str_3
	push	hl
	call	_write_string
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
	pop	bc
;boot_rom.c:97: for (char b = 0; b < 2; b++)
	ld	c, #0x00
00117$:
	ld	a, c
	sub	a, #0x02
	jp	NC, 00105$
;boot_rom.c:99: char m = 0b00000001;
	ld	e, #0x01
;boot_rom.c:100: for (char i = 0; i < 8; i++)
	ld	-2 (ix), #0x00
00114$:
	ld	a, -2 (ix)
	sub	a, #0x08
	jp	NC, 00118$
;boot_rom.c:102: char x = 9 + i + (b * 10);
	ld	a, -2 (ix)
	add	a, #0x09
	ld	d, a
	ld	a, c
	push	de
	ld	e, a
	add	a, a
	add	a, a
	add	a, e
	add	a, a
	pop	de
	add	a, d
	ld	-3 (ix), a
;boot_rom.c:103: for (char j = 0; j < 3; j++)
	ld	-1 (ix), #0x00
00111$:
	ld	a, -1 (ix)
	sub	a, #0x03
	jr	NC,00101$
;boot_rom.c:105: write_char((joystick[b + (j * 32)] & m) ? asc_1 : asc_0, 0xFF, x, 4 + j);
	ld	a, -1 (ix)
	ld	l, #0x00
	add	a, #0x04
	ld	-7 (ix), a
	ld	a, l
	adc	a, #0x00
	ld	-6 (ix), a
	ld	a, -3 (ix)
	ld	-5 (ix), a
	ld	-4 (ix), #0x00
	ld	a, -1 (ix)
	rrca
	rrca
	rrca
	and	a, #0xe0
	ld	d, c
	add	a, d
	ld	l, a
	rla
	sbc	a, a
	ld	d, a
	ld	a, #<(_joystick)
	add	a, l
	ld	l, a
	ld	a, #>(_joystick)
	adc	a, d
	ld	h, a
	ld	a, (hl)
	and	a,e
	jr	Z,00121$
	ld	hl,#_asc_1 + 0
	ld	d, (hl)
	jr	00122$
00121$:
	ld	hl,#_asc_0 + 0
	ld	d, (hl)
00122$:
	push	bc
	push	de
	ld	l, -7 (ix)
	ld	h, -6 (ix)
	push	hl
	ld	l, -5 (ix)
	ld	h, -4 (ix)
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
;boot_rom.c:103: for (char j = 0; j < 3; j++)
	inc	-1 (ix)
	jr	00111$
00101$:
;boot_rom.c:107: m <<= 1;
	sla	e
;boot_rom.c:100: for (char i = 0; i < 8; i++)
	inc	-2 (ix)
	jp	00114$
00118$:
;boot_rom.c:97: for (char b = 0; b < 2; b++)
	inc	c
	jp	00117$
00105$:
;boot_rom.c:111: hsync_last = hsync;
	ld	a,(#_hsync + 0)
	ld	(#_hsync_last + 0),a
;boot_rom.c:112: vsync_last = vsync;
	ld	a,(#_vsync + 0)
	ld	(#_vsync_last + 0),a
;boot_rom.c:114: }
	jp	00108$
___str_3:
	.ascii "--- MiSTer Input Tester ---"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
__xinit__asc_0:
	.db #0x30	; 48	'0'
__xinit__asc_1:
	.db #0x31	; 49	'1'
	.area _CABS (ABS)
