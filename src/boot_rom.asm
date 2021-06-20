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
	.globl _cur_y
	.globl _cur_x
	.globl _y
	.globl _color
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
_input0	=	0x4000
_input1	=	0x4001
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
_color::
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_y::
	.ds 1
_cur_x::
	.ds 2
_cur_y::
	.ds 2
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
;boot_rom.c:26: int putchar(int c) {
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-11
	add	hl, sp
	ld	sp, hl
;boot_rom.c:28: unsigned int *dptr = (unsigned int*)(VGA_WIDTH*(8*cur_y) + 8*cur_x);
	ld	hl, (_cur_y)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	bc, (_VGA_WIDTH)
	push	hl
	push	bc
	call	__mulint
	pop	af
	pop	af
	ld	c, l
	ld	b, h
	ld	hl, (_cur_x)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	inc	sp
	inc	sp
	push	hl
;boot_rom.c:31: if(c < 32) {
	ld	a, 4 (ix)
	sub	a, #0x20
	ld	a, 5 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC,00108$
;boot_rom.c:32: if(c == '\r') { cur_x=0; }
	ld	a, 4 (ix)
	sub	a, #0x0d
	or	a, 5 (ix)
	jr	NZ,00102$
	ld	hl, #0x0000
	ld	(_cur_x), hl
00102$:
;boot_rom.c:33: if(c == '\n') {
	ld	a, 4 (ix)
	sub	a, #0x0a
	or	a, 5 (ix)
	jp	NZ,00122$
;boot_rom.c:34: cur_y++;
	ld	iy, #_cur_y
	inc	0 (iy)
	jr	NZ,00192$
	inc	1 (iy)
00192$:
;boot_rom.c:35: cur_x=0;
	ld	hl, #0x0000
	ld	(_cur_x), hl
;boot_rom.c:36: if(cur_y >= 12) { cur_y = 0; }
	ld	a, 0 (iy)
	sub	a, #0x0c
	ld	a, 1 (iy)
	sbc	a, #0x00
	jp	C,00122$
	ld	l, #0x00
	ld	(_cur_y), hl
;boot_rom.c:38: return;
	jp	00122$
00108$:
;boot_rom.c:41: if(c < 0) return;
	bit	7, 5 (ix)
	jp	NZ,00122$
;boot_rom.c:43: p = font+8*(unsigned char)(c-32);
	ld	bc, #_font+0
	ld	a, 4 (ix)
	add	a, #0xe0
	ld	l, a
	ld	h, #0x00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	ld	-9 (ix), l
	ld	-8 (ix), h
;boot_rom.c:44: for(i=0;i<8;i++) {
	ld	bc, #0x0000
00120$:
;boot_rom.c:45: unsigned char l = *p++;
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	a, (hl)
	ld	-3 (ix), a
	ld	a, -9 (ix)
	add	a, #0x02
	ld	-9 (ix), a
	jr	NC,00193$
	inc	-8 (ix)
00193$:
;boot_rom.c:46: for(j=0;j<8;j++) {
	ld	-2 (ix), #0x08
	ld	-1 (ix), #0x00
	pop	de
	push	de
00119$:
;boot_rom.c:47: *dptr++ = (l & 0x80) ? color : 0x00;
	ld	-5 (ix), e
	ld	-4 (ix), d
	inc	de
	inc	de
	bit	7, -3 (ix)
	jr	Z,00124$
	ld	a,(#_color + 0)
	ld	-7 (ix), a
	ld	-6 (ix), #0x00
	jr	00125$
00124$:
	ld	-7 (ix), #0x00
	ld	-6 (ix), #0x00
00125$:
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	ld	a, -7 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -6 (ix)
	ld	(hl), a
;boot_rom.c:48: l <<= 1;
	ld	a, -3 (ix)
	add	a, a
	ld	-3 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	dec	hl
	ld	-2 (ix), l
	ld	-1 (ix), h
;boot_rom.c:46: for(j=0;j<8;j++) {
	ld	a, h
	or	a, l
	jr	NZ,00119$
;boot_rom.c:50: dptr += (VGA_WIDTH-8);
	ld	hl, (_VGA_WIDTH)
	ld	a, l
	add	a, #0xf8
	ld	l, a
	ld	a, h
	adc	a, #0xff
	ld	h, a
	add	hl, hl
	add	hl, de
	inc	sp
	inc	sp
	push	hl
;boot_rom.c:44: for(i=0;i<8;i++) {
	inc	bc
	ld	a, c
	sub	a, #0x08
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jp	C, 00120$
;boot_rom.c:53: cur_x++;
	ld	iy, #_cur_x
	inc	0 (iy)
	jr	NZ,00195$
	inc	1 (iy)
00195$:
;boot_rom.c:54: if(cur_x >= 20) {
	ld	a, 0 (iy)
	sub	a, #0x14
	ld	a, 1 (iy)
	sbc	a, #0x00
	jr	C,00116$
;boot_rom.c:55: cur_x = 0;
	ld	hl, #0x0000
	ld	(_cur_x), hl
;boot_rom.c:56: cur_y++;
	ld	iy, #_cur_y
	inc	0 (iy)
	jr	NZ,00196$
	inc	1 (iy)
00196$:
;boot_rom.c:58: if(cur_y >= 12)
	ld	a, 0 (iy)
	sub	a, #0x0c
	ld	a, 1 (iy)
	sbc	a, #0x00
	jr	C,00116$
;boot_rom.c:59: cur_y = 0;
	ld	l, #0x00
	ld	(_cur_y), hl
00116$:
;boot_rom.c:61: return;
00122$:
;boot_rom.c:62: }
	ld	sp, ix
	pop	ix
	ret
_VGA_WIDTH:
	.dw #0x0140
_VGA_HEIGHT:
	.dw #0x00c8
;boot_rom.c:65: void put_pixel(unsigned int x, unsigned int y, unsigned char color) {
;	---------------------------------
; Function put_pixel
; ---------------------------------
_put_pixel::
;boot_rom.c:66: *((unsigned int*)(VGA_WIDTH*y+x)) = color;
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
;boot_rom.c:67: }
	ret
;boot_rom.c:69: void cls(unsigned char color) {
;	---------------------------------
; Function cls
; ---------------------------------
_cls::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;boot_rom.c:73: for(i=0;i<VGA_HEIGHT;i++) {
	ld	bc, #0x0000
00107$:
	ld	hl, (_VGA_HEIGHT)
	ld	a, c
	sub	a, l
	ld	a, b
	sbc	a, h
	jr	NC,00102$
;boot_rom.c:74: for(unsigned int x=0;x<VGA_HEIGHT;x++) {
	ld	a, 4 (ix)
	ld	-1 (ix), a
	ld	de, #0x0000
00104$:
	ld	hl, (_VGA_HEIGHT)
	ld	a, e
	sub	a, l
	ld	a, d
	sbc	a, h
	jr	NC,00115$
;boot_rom.c:76: put_pixel(x,i, color);
	push	bc
	push	de
	ld	a, -1 (ix)
	push	af
	inc	sp
	push	bc
	push	de
	call	_put_pixel
	pop	af
	pop	af
	inc	sp
	pop	de
	pop	bc
;boot_rom.c:77: color++;
	inc	-1 (ix)
;boot_rom.c:74: for(unsigned int x=0;x<VGA_HEIGHT;x++) {
	inc	de
	jr	00104$
00115$:
	ld	a, -1 (ix)
	ld	4 (ix), a
;boot_rom.c:73: for(i=0;i<VGA_HEIGHT;i++) {
	inc	bc
	jr	00107$
00102$:
;boot_rom.c:81: cur_x = 0;
	ld	hl, #0x0000
	ld	(_cur_x), hl
;boot_rom.c:82: cur_y = 0;
	ld	l, #0x00
	ld	(_cur_y), hl
;boot_rom.c:83: }
	inc	sp
	pop	ix
	ret
;boot_rom.c:86: void draw_line(unsigned int x, unsigned int y, 
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
;boot_rom.c:90: int dx1 = (x<x2)?1:-1;
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
	ld	-12 (ix), c
	ld	-11 (ix), b
;boot_rom.c:91: int dy1 = (y<y2)?1:-1;
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
	ld	-10 (ix), c
	ld	-9 (ix), b
;boot_rom.c:94: longest = abs(x2 - x);
	ld	a, 8 (ix)
	sub	a, 4 (ix)
	ld	c, a
	ld	a, 9 (ix)
	sbc	a, 5 (ix)
	ld	b, a
	push	bc
	call	_abs
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
;boot_rom.c:95: shortest = abs(y2 - y);
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
	ld	-4 (ix), l
	ld	-3 (ix), h
;boot_rom.c:96: if(longest<shortest) {
	ld	a, -2 (ix)
	sub	a, -4 (ix)
	ld	a, -1 (ix)
	sbc	a, -3 (ix)
	jr	NC,00102$
;boot_rom.c:97: longest = abs(y2 - y);
	push	de
	call	_abs
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
;boot_rom.c:98: shortest = abs(x2 - x);
	push	bc
	call	_abs
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
;boot_rom.c:99: dx2 = 0;            
	ld	bc, #0x0000
;boot_rom.c:100: dy2 = dy1;
	ld	a, -10 (ix)
	ld	-8 (ix), a
	ld	a, -9 (ix)
	ld	-7 (ix), a
	jr	00103$
00102$:
;boot_rom.c:102: dx2 = dx1;
	ld	c, -12 (ix)
	ld	b, -11 (ix)
;boot_rom.c:103: dy2 = 0;
	ld	-8 (ix), #0x00
	ld	-7 (ix), #0x00
00103$:
;boot_rom.c:106: numerator = longest/2;
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	srl	d
	rr	e
;boot_rom.c:107: for(i=0;i<=longest;i++) {
	ld	a, -2 (ix)
	sub	a, -4 (ix)
	ld	-14 (ix), a
	ld	a, -1 (ix)
	sbc	a, -3 (ix)
	ld	-13 (ix), a
	ld	-6 (ix), #0x00
	ld	-5 (ix), #0x00
00108$:
;boot_rom.c:108: put_pixel(x,y,color) ;
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
;boot_rom.c:110: numerator += shortest ;
	ld	a, -4 (ix)
	add	a, e
	ld	-16 (ix), a
	ld	a, -3 (ix)
	adc	a, d
	ld	-15 (ix), a
;boot_rom.c:109: if(numerator >= longest-shortest) {
	ld	a, e
	sub	a, -14 (ix)
	ld	a, d
	sbc	a, -13 (ix)
	jr	C,00105$
;boot_rom.c:110: numerator += shortest ;
;boot_rom.c:111: numerator -= longest ;
	ld	a, -16 (ix)
	ld	d, -15 (ix)
	sub	a, -2 (ix)
	ld	e, a
	ld	a, d
	sbc	a, -1 (ix)
	ld	d, a
;boot_rom.c:112: x += dx1;
	ld	a, -12 (ix)
	ld	-18 (ix), a
	ld	a, -11 (ix)
	ld	-17 (ix), a
	ld	a, 4 (ix)
	add	a, -18 (ix)
	ld	4 (ix), a
	ld	a, 5 (ix)
	adc	a, -17 (ix)
	ld	5 (ix), a
;boot_rom.c:113: y += dy1;
	ld	a, -10 (ix)
	ld	-18 (ix), a
	ld	a, -9 (ix)
	ld	-17 (ix), a
	ld	a, 6 (ix)
	add	a, -18 (ix)
	ld	6 (ix), a
	ld	a, 7 (ix)
	adc	a, -17 (ix)
	ld	7 (ix), a
	jr	00109$
00105$:
;boot_rom.c:115: numerator += shortest ;
	ld	e, -16 (ix)
	ld	d, -15 (ix)
;boot_rom.c:116: x += dx2;
	inc	sp
	inc	sp
	push	bc
	ld	a, 4 (ix)
	add	a, -18 (ix)
	ld	4 (ix), a
	ld	a, 5 (ix)
	adc	a, -17 (ix)
	ld	5 (ix), a
;boot_rom.c:117: y += dy2;
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
00109$:
;boot_rom.c:107: for(i=0;i<=longest;i++) {
	inc	-6 (ix)
	jr	NZ,00142$
	inc	-5 (ix)
00142$:
	ld	a, -2 (ix)
	sub	a, -6 (ix)
	ld	a, -1 (ix)
	sbc	a, -5 (ix)
	jp	NC, 00108$
;boot_rom.c:120: }
	ld	sp, ix
	pop	ix
	ret
;boot_rom.c:123: void main() {
;	---------------------------------
; Function main
; ---------------------------------
_main::
;boot_rom.c:124: while(1) {
00108$:
;boot_rom.c:127: input0_cache = input0;
	ld	a,(#_input0 + 0)
	ld	iy, #_input0_cache
	ld	0 (iy), a
;boot_rom.c:128: hsync = input0_cache & 0x80;
	ld	c, 0 (iy)
	ld	a, c
	and	a, #0x80
	ld	(#_hsync + 0),a
;boot_rom.c:129: vsync = input0_cache & 0x40;
	ld	a, c
	and	a, #0x40
	ld	(#_vsync + 0),a
;boot_rom.c:131: if(hsync && !hsync_last){
	ld	a,(#_hsync + 0)
	or	a, a
	jr	Z,00102$
	ld	a,(#_hsync_last + 0)
	or	a, a
	jr	NZ,00102$
;boot_rom.c:132: y++;
	ld	hl, #_y+0
	inc	(hl)
00102$:
;boot_rom.c:134: if(vsync && !vsync_last){
	ld	a,(#_vsync + 0)
	or	a, a
	jr	Z,00105$
	ld	a,(#_vsync_last + 0)
	or	a, a
	jr	NZ,00105$
;boot_rom.c:135: y=0;
	ld	hl,#_y + 0
	ld	(hl), #0x00
;boot_rom.c:138: input1_cache = input1;
	ld	a,(#_input1 + 0)
	ld	(#_input1_cache + 0),a
00105$:
;boot_rom.c:141: hsync_last = hsync;
	ld	a,(#_hsync + 0)
	ld	(#_hsync_last + 0),a
;boot_rom.c:142: vsync_last = vsync;
	ld	a,(#_vsync + 0)
	ld	(#_vsync_last + 0),a
;boot_rom.c:144: }
	jr	00108$
	.area _CODE
	.area _INITIALIZER
__xinit__y:
	.db #0x00	; 0
__xinit__cur_x:
	.dw #0x0000
__xinit__cur_y:
	.dw #0x0000
	.area _CABS (ABS)
