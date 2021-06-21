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
	.globl _draw_line
	.globl _cls
	.globl _put_pixel
	.globl _abs
	.globl _puts
	.globl _color
	.globl _cur_y
	.globl _cur_x
	.globl _y
	.globl _input1_cache
	.globl _input0_cache
	.globl _vsync_last
	.globl _vsync
	.globl _hsync_last
	.globl _hsync
	.globl _input1
	.globl _input0
	.globl _VGA_HEIGHT
	.globl _VGA_WIDTH
	.globl _putchar
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_input0	=	0x6000
_input1	=	0x6001
_hsync::
	.ds 1
_hsync_last::
	.ds 1
_vsync::
	.ds 1
_vsync_last::
	.ds 1
_input0_cache::
	.ds 1
_input1_cache::
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_y::
	.ds 1
_cur_x::
	.ds 1
_cur_y::
	.ds 1
_color::
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
;boot_rom.c:25: int putchar(int c) {
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-7
	add	hl, sp
	ld	sp, hl
;boot_rom.c:27: unsigned char *dptr = (unsigned char*)(160*(8*cur_y) + 8*cur_x);
	ld	hl,#_cur_y + 0
	ld	c, (hl)
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, #_cur_x
	ld	l, 0 (iy)
	ld	h, #0x00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	-5 (ix), l
	ld	-4 (ix), h
;boot_rom.c:30: if(c < 32) {
	ld	a, 4 (ix)
	sub	a, #0x20
	ld	a, 5 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC,00108$
;boot_rom.c:31: if(c == '\r') 
	ld	a, 4 (ix)
	sub	a, #0x0d
	or	a, 5 (ix)
	jr	NZ,00102$
;boot_rom.c:32: cur_x=0;
	ld	0 (iy), #0x00
00102$:
;boot_rom.c:34: if(c == '\n') {
	ld	a, 4 (ix)
	sub	a, #0x0a
	or	a, 5 (ix)
	jp	NZ,00122$
;boot_rom.c:35: cur_y++;
	ld	iy, #_cur_y
	inc	0 (iy)
;boot_rom.c:36: cur_x=0;
	ld	iy, #_cur_x
	ld	0 (iy), #0x00
;boot_rom.c:38: if(cur_y >= 12)
	ld	iy, #_cur_y
	ld	a, 0 (iy)
	sub	a, #0x0c
	jp	C,00122$
;boot_rom.c:39: cur_y = 0;
	ld	0 (iy), #0x00
;boot_rom.c:41: return;
	jp	00122$
00108$:
;boot_rom.c:44: if(c < 0) return;
	bit	7, 5 (ix)
	jp	NZ,00122$
;boot_rom.c:46: p = font+8*(unsigned char)(c-32);
	ld	bc, #_font+0
	ld	a, 4 (ix)
	add	a, #0xe0
	ld	l, a
	ld	h, #0x00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	ld	c, l
	ld	b, h
;boot_rom.c:47: for(i=0;i<8;i++) {
	ld	-2 (ix), #0x00
00120$:
;boot_rom.c:48: unsigned char l = *p++;
	ld	a, (bc)
	ld	-1 (ix), a
	inc	bc
;boot_rom.c:49: for(j=0;j<8;j++) {
	ld	-3 (ix), #0x08
	ld	e, -5 (ix)
	ld	d, -4 (ix)
00119$:
;boot_rom.c:50: *dptr++ = (l & 0x80)?color:0x00;
	inc	sp
	inc	sp
	push	de
	inc	de
	bit	7, -1 (ix)
	jr	Z,00124$
	ld	iy, #_color
	ld	l, 0 (iy)
	jr	00125$
00124$:
	ld	hl, #0x0000
00125$:
	ld	a, l
	pop	hl
	push	hl
	ld	(hl), a
;boot_rom.c:51: l <<= 1;
	ld	a, -1 (ix)
	add	a, a
	ld	-1 (ix), a
	dec	-3 (ix)
	ld	a, -3 (ix)
;boot_rom.c:49: for(j=0;j<8;j++) {
	or	a, a
	jr	NZ,00119$
;boot_rom.c:53: dptr += (160-8);
	ld	hl, #0x0098
	add	hl, de
	ld	-5 (ix), l
	ld	-4 (ix), h
;boot_rom.c:47: for(i=0;i<8;i++) {
	inc	-2 (ix)
	ld	a, -2 (ix)
	sub	a, #0x08
	jr	C,00120$
;boot_rom.c:56: cur_x++;
	ld	iy, #_cur_x
	inc	0 (iy)
;boot_rom.c:57: if(cur_x >= 20) {
	ld	a, 0 (iy)
	sub	a, #0x14
	jr	C,00122$
;boot_rom.c:58: cur_x = 0;
	ld	0 (iy), #0x00
;boot_rom.c:59: cur_y++;
	ld	iy, #_cur_y
	inc	0 (iy)
;boot_rom.c:61: if(cur_y >= 12)
	ld	a, 0 (iy)
	sub	a, #0x0c
	jr	C,00122$
;boot_rom.c:62: cur_y = 0;
	ld	0 (iy), #0x00
00122$:
;boot_rom.c:64: }
	ld	sp, ix
	pop	ix
	ret
_VGA_WIDTH:
	.dw #0x00a0
_VGA_HEIGHT:
	.dw #0x0064
;boot_rom.c:67: void put_pixel(unsigned int x, unsigned int y, unsigned char color) {
;	---------------------------------
; Function put_pixel
; ---------------------------------
_put_pixel::
;boot_rom.c:68: *((unsigned int*)(VGA_WIDTH*y+x)) = color;
	ld	hl, (_VGA_WIDTH)
	ld	iy, #4
	add	iy, sp
	ld	c, 0 (iy)
	ld	b, 1 (iy)
	push	bc
	push	hl
	call	__mulint
	pop	af
	pop	af
	ld	c, l
	ld	b, h
	ld	a, c
	ld	hl, #2
	add	hl, sp
	add	a, (hl)
	ld	c, a
	ld	a, b
	inc	hl
	adc	a, (hl)
	ld	l, c
	ld	h, a
	ld	iy, #6
	add	iy, sp
	ld	c, 0 (iy)
	ld	b, #0x00
	ld	(hl), c
	inc	hl
	ld	(hl), b
;boot_rom.c:69: }
	ret
;boot_rom.c:71: void cls(unsigned char color) {
;	---------------------------------
; Function cls
; ---------------------------------
_cls::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;boot_rom.c:73: unsigned int *p = (unsigned int*)0;
	ld	de, #0x0000
;boot_rom.c:74: for(i=0;i<VGA_HEIGHT;i++) {
	ld	-1 (ix), #0x00
00103$:
	ld	bc, (_VGA_HEIGHT)
	ld	l, -1 (ix)
	ld	h, #0x00
	cp	a, a
	sbc	hl, bc
	jr	NC,00105$
;boot_rom.c:75: memset(p, color, VGA_WIDTH);
	ld	c, e
	ld	b, d
	ld	l, 4 (ix)
	ld	h, #0x00
	ld	iy, (_VGA_WIDTH)
	push	de
	push	iy
	push	hl
	push	bc
	call	_memset
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
;boot_rom.c:76: p += VGA_WIDTH;
	ld	hl, (_VGA_WIDTH)
	add	hl, hl
	add	hl, de
	ex	de, hl
;boot_rom.c:74: for(i=0;i<VGA_HEIGHT;i++) {
	inc	-1 (ix)
	jr	00103$
00105$:
;boot_rom.c:78: }
	inc	sp
	pop	ix
	ret
;boot_rom.c:81: void draw_line(unsigned int x, unsigned int y, 
;	---------------------------------
; Function draw_line
; ---------------------------------
_draw_line::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-18
	add	hl, sp
	ld	sp, hl
;boot_rom.c:85: int dx1 = (x<x2)?1:-1;
	ld	a, 4 (ix)
	sub	a, 8 (ix)
	ld	a, 5 (ix)
	sbc	a, 9 (ix)
	jr	NC,00112$
	ld	bc, #0x0001
	jr	00113$
00112$:
	ld	bc, #0xffff
00113$:
	ld	-6 (ix), c
	ld	-5 (ix), b
;boot_rom.c:86: int dy1 = (y<y2)?1:-1;
	ld	a, 6 (ix)
	sub	a, 10 (ix)
	ld	a, 7 (ix)
	sbc	a, 11 (ix)
	jr	NC,00114$
	ld	bc, #0x0001
	jr	00115$
00114$:
	ld	bc, #0xffff
00115$:
	ld	-8 (ix), c
	ld	-7 (ix), b
;boot_rom.c:89: longest = abs(x2 - x);
	ld	a, 8 (ix)
	sub	a, 4 (ix)
	ld	c, a
	ld	a, 9 (ix)
	sbc	a, 5 (ix)
	ld	b, a
	push	bc
	call	_abs
	pop	af
	ld	-10 (ix), l
	ld	-9 (ix), h
;boot_rom.c:90: shortest = abs(y2 - y);
	ld	a, 10 (ix)
	sub	a, 6 (ix)
	ld	e, a
	ld	a, 11 (ix)
	sbc	a, 7 (ix)
	ld	d, a
	push	de
	push	de
	call	_abs
	pop	af
	pop	de
	ld	-2 (ix), l
	ld	-1 (ix), h
;boot_rom.c:91: if(longest<shortest) {
	ld	a, -10 (ix)
	sub	a, -2 (ix)
	ld	a, -9 (ix)
	sbc	a, -1 (ix)
	jr	NC,00102$
;boot_rom.c:92: longest = abs(y2 - y);
	push	de
	call	_abs
	pop	af
	ld	-10 (ix), l
	ld	-9 (ix), h
;boot_rom.c:93: shortest = abs(x2 - x);
	push	bc
	call	_abs
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
;boot_rom.c:94: dx2 = 0;            
	ld	bc, #0x0000
;boot_rom.c:95: dy2 = dy1;
	ld	a, -8 (ix)
	ld	-12 (ix), a
	ld	a, -7 (ix)
	ld	-11 (ix), a
	jr	00103$
00102$:
;boot_rom.c:97: dx2 = dx1;
	ld	c, -6 (ix)
	ld	b, -5 (ix)
;boot_rom.c:98: dy2 = 0;
	ld	-12 (ix), #0x00
	ld	-11 (ix), #0x00
00103$:
;boot_rom.c:101: numerator = longest/2;
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	srl	d
	rr	e
;boot_rom.c:102: for(i=0;i<=longest;i++) {
	ld	a, -10 (ix)
	sub	a, -2 (ix)
	ld	-14 (ix), a
	ld	a, -9 (ix)
	sbc	a, -1 (ix)
	ld	-13 (ix), a
	ld	-4 (ix), #0x00
	ld	-3 (ix), #0x00
00108$:
;boot_rom.c:103: put_pixel(x,y,color) ;
	push	bc
	push	de
	ld	a, 12 (ix)
	push	af
	inc	sp
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_put_pixel
	pop	af
	pop	af
	inc	sp
	pop	de
	pop	bc
;boot_rom.c:105: numerator += shortest ;
	ld	a, -2 (ix)
	add	a, e
	ld	-16 (ix), a
	ld	a, -1 (ix)
	adc	a, d
	ld	-15 (ix), a
;boot_rom.c:104: if(numerator >= longest-shortest) {
	ld	a, e
	sub	a, -14 (ix)
	ld	a, d
	sbc	a, -13 (ix)
	jr	C,00105$
;boot_rom.c:105: numerator += shortest ;
;boot_rom.c:106: numerator -= longest ;
	ld	a, -16 (ix)
	ld	d, -15 (ix)
	sub	a, -10 (ix)
	ld	e, a
	ld	a, d
	sbc	a, -9 (ix)
	ld	d, a
;boot_rom.c:107: x += dx1;
	ld	a, -6 (ix)
	ld	-18 (ix), a
	ld	a, -5 (ix)
	ld	-17 (ix), a
	ld	a, 4 (ix)
	add	a, -18 (ix)
	ld	4 (ix), a
	ld	a, 5 (ix)
	adc	a, -17 (ix)
	ld	5 (ix), a
;boot_rom.c:108: y += dy1;
	ld	a, -8 (ix)
	ld	-18 (ix), a
	ld	a, -7 (ix)
	ld	-17 (ix), a
	ld	a, 6 (ix)
	add	a, -18 (ix)
	ld	6 (ix), a
	ld	a, 7 (ix)
	adc	a, -17 (ix)
	ld	7 (ix), a
	jr	00109$
00105$:
;boot_rom.c:110: numerator += shortest ;
	ld	e, -16 (ix)
	ld	d, -15 (ix)
;boot_rom.c:111: x += dx2;
	inc	sp
	inc	sp
	push	bc
	ld	a, 4 (ix)
	add	a, -18 (ix)
	ld	4 (ix), a
	ld	a, 5 (ix)
	adc	a, -17 (ix)
	ld	5 (ix), a
;boot_rom.c:112: y += dy2;
	ld	a, -12 (ix)
	ld	-18 (ix), a
	ld	a, -11 (ix)
	ld	-17 (ix), a
	ld	a, 6 (ix)
	add	a, -18 (ix)
	ld	6 (ix), a
	ld	a, 7 (ix)
	adc	a, -17 (ix)
	ld	7 (ix), a
00109$:
;boot_rom.c:102: for(i=0;i<=longest;i++) {
	inc	-4 (ix)
	jr	NZ,00142$
	inc	-3 (ix)
00142$:
	ld	a, -10 (ix)
	sub	a, -4 (ix)
	ld	a, -9 (ix)
	sbc	a, -3 (ix)
	jp	NC, 00108$
;boot_rom.c:115: }
	ld	sp, ix
	pop	ix
	ret
;boot_rom.c:119: void main() {
;	---------------------------------
; Function main
; ---------------------------------
_main::
;boot_rom.c:120: while(1) {
00108$:
;boot_rom.c:123: input0_cache = input0;
	ld	a,(#_input0 + 0)
	ld	iy, #_input0_cache
	ld	0 (iy), a
;boot_rom.c:124: hsync = input0_cache & 0x80;
	ld	c, 0 (iy)
	ld	a, c
	and	a, #0x80
	ld	(#_hsync + 0),a
;boot_rom.c:125: vsync = input0_cache & 0x40;
	ld	a, c
	and	a, #0x40
	ld	(#_vsync + 0),a
;boot_rom.c:127: if(hsync && !hsync_last){
	ld	a,(#_hsync + 0)
	or	a, a
	jr	Z,00102$
	ld	a,(#_hsync_last + 0)
	or	a, a
	jr	NZ,00102$
;boot_rom.c:128: y++;
	ld	hl, #_y+0
	inc	(hl)
00102$:
;boot_rom.c:130: if(vsync && !vsync_last){
	ld	a,(#_vsync + 0)
	or	a, a
	jr	Z,00105$
	ld	a,(#_vsync_last + 0)
	or	a, a
	jr	NZ,00105$
;boot_rom.c:131: y=0;
	ld	hl,#_y + 0
	ld	(hl), #0x00
;boot_rom.c:133: cur_x = 0;
	ld	hl,#_cur_x + 0
	ld	(hl), #0x00
;boot_rom.c:134: cur_y = 0;
	ld	hl,#_cur_y + 0
	ld	(hl), #0x00
;boot_rom.c:135: color++;
	ld	iy, #_color
	inc	0 (iy)
;boot_rom.c:136: cls(~color);
	ld	a, 0 (iy)
	cpl
	ld	b, a
	push	bc
	inc	sp
	call	_cls
	inc	sp
;boot_rom.c:137: puts(" << Z80 SoC >>\n");
	ld	hl, #___str_0
	push	hl
	call	_puts
	pop	af
;boot_rom.c:140: input1_cache = input1;
	ld	a,(#_input1 + 0)
	ld	(#_input1_cache + 0),a
00105$:
;boot_rom.c:143: hsync_last = hsync;
	ld	a,(#_hsync + 0)
	ld	(#_hsync_last + 0),a
;boot_rom.c:144: vsync_last = vsync;
	ld	a,(#_vsync + 0)
	ld	(#_vsync_last + 0),a
;boot_rom.c:146: }
	jr	00108$
___str_0:
	.ascii " << Z80 SoC >>"
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
__xinit__y:
	.db #0x00	; 0
__xinit__cur_x:
	.db #0x00	; 0
__xinit__cur_y:
	.db #0x00	; 0
__xinit__color:
	.db #0x66	; 102	'f'
	.area _CABS (ABS)
