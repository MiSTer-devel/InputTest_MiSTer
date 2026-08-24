;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module os
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _app_main
	.globl _app_credits
	.globl _fadein
	.globl _fadeout
	.globl _snek_attract
	.globl _snek_gameplay
	.globl _start_snek_gameplay
	.globl _start_snek_attract
	.globl _app_zorblaxx
	.globl _menu
	.globl _start_menu
	.globl _gunsight
	.globl _btntest
	.globl _inputtester_advanced
	.globl _inputtester_analog
	.globl _inputtester_digital
	.globl _start_gunsight
	.globl _start_btntest
	.globl _start_inputtester_advanced
	.globl _start_inputtester_analog
	.globl _start_inputtester_digital
	.globl _loader
	.globl _musicram
	.globl _sndram
	.globl _tilemapram
	.globl _tilemapctl
	.globl _spritecollisionram
	.globl _spriteram
	.globl _bgcolram
	.globl _fgcolram
	.globl _chram
	.globl _system_menu
	.globl _system_pause
	.globl _starfield3
	.globl _starfield2
	.globl _starfield1
	.globl _analog_r2
	.globl _analog_l2
	.globl _timer
	.globl _timestamp
	.globl _ps2_mouse
	.globl _ps2_key
	.globl _spinner
	.globl _paddle
	.globl _analog_r
	.globl _analog_l
	.globl _joystick
	.globl _video_ctl
	.globl _input0
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_input0	=	0x8000
_video_ctl	=	0x8001
_joystick	=	0x8100
_analog_l	=	0x8200
_analog_r	=	0x8300
_paddle	=	0x8400
_spinner	=	0x8500
_ps2_key	=	0x8600
_ps2_mouse	=	0x8700
_timestamp	=	0x8800
_timer	=	0x8900
_analog_l2	=	0x9000
_analog_r2	=	0x9100
_starfield1	=	0x8a00
_starfield2	=	0x8a10
_starfield3	=	0x8a20
_system_pause	=	0x8a30
_system_menu	=	0x8a31
_chram	=	0x9800
_fgcolram	=	0xa000
_bgcolram	=	0xa800
_spriteram	=	0xb000
_spritecollisionram	=	0xb400
_tilemapctl	=	0x8c00
_tilemapram	=	0x8c10
_sndram	=	0x8b00
_musicram	=	0x8b10
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
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
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:33: void app_main()
;	---------------------------------
; Function app_main
; ---------------------------------
_app_main::
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:35: chram_size = chram_cols * chram_rows;
	ld	a, (_chram_rows+0)
	ld	e, a
	ld	a, (_chram_cols+0)
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	ld	l, #0x00
	ld	d, l
	ld	b, #0x08
00233$:
	add	hl, hl
	jr	NC, 00234$
	add	hl, de
00234$:
	djnz	00233$
	ld	(_chram_size), hl
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:36: while (1)
00124$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:38: hsync = input0 & 0x80;
	ld	a, (_input0+0)
	rlca
	and	a, #0x01
	ld	c, a
	xor	a, a
	cp	a, c
	rla
	ld	(_hsync+0), a
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:39: vsync = input0 & 0x40;
	ld	a, (_input0+0)
	rlca
	rlca
	and	a, #0x01
	ld	c, a
	xor	a, a
	cp	a, c
	rla
	ld	(_vsync+0), a
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:40: hblank = CHECK_BIT(input0, INPUT_HBLANK);
	ld	a, (_input0+0)
	rlca
	rlca
	rlca
	and	a, #0x01
	ld	c, a
	xor	a, a
	cp	a, c
	rla
	ld	(_hblank+0), a
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:41: vblank = CHECK_BIT(input0, INPUT_VBLANK);
	ld	a, (_input0+0)
	rrca
	rrca
	rrca
	rrca
	and	a, #0x01
	ld	c, a
	xor	a, a
	cp	a, c
	rla
	ld	(_vblank+0), a
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:42: switch (state)
	ld	a, (_state+0)
	dec	a
	jp	Z,00101$
	ld	a, (_state+0)
	sub	a, #0x02
	jp	Z,00102$
	ld	a, (_state+0)
	sub	a, #0x03
	jp	Z,00103$
	ld	a, (_state+0)
	sub	a, #0x04
	jp	Z,00104$
	ld	a, (_state+0)
	sub	a, #0x05
	jp	Z,00105$
	ld	a, (_state+0)
	sub	a, #0x06
	jp	Z,00106$
	ld	a, (_state+0)
	sub	a, #0x07
	jr	Z, 00107$
	ld	a, (_state+0)
	sub	a, #0x08
	jr	Z, 00108$
	ld	a, (_state+0)
	sub	a, #0x09
	jr	Z, 00109$
	ld	a, (_state+0)
	sub	a, #0x0a
	jr	Z, 00110$
	ld	a, (_state+0)
	sub	a, #0x0b
	jr	Z, 00111$
	ld	a, (_state+0)
	sub	a, #0x0c
	jr	Z, 00112$
	ld	a, (_state+0)
	sub	a, #0x14
	jr	Z, 00113$
	ld	a, (_state+0)
	sub	a, #0x16
	jr	Z, 00114$
	ld	a, (_state+0)
	sub	a, #0x1e
	jr	Z, 00115$
	ld	a, (_state+0)
	sub	a, #0x1f
	jr	Z, 00116$
	ld	a, (_state+0)
	sub	a, #0x28
	jr	Z, 00118$
	ld	a, (_state+0)
	sub	a, #0x29
	jr	Z, 00119$
	ld	a, (_state+0)
	sub	a, #0x2a
	jr	Z, 00117$
	ld	a, (_state+0)
	sub	a, #0x2b
	jr	Z, 00120$
	jr	00121$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:44: case STATE_START_INPUTTESTER:
00101$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:45: start_inputtester_digital();
	call	_start_inputtester_digital
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:46: break;
	jp	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:47: case STATE_INPUTTESTER:
00102$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:48: inputtester_digital();
	call	_inputtester_digital
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:49: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:51: case STATE_START_INPUTTESTERADVANCED:
00103$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:52: start_inputtester_advanced();
	call	_start_inputtester_advanced
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:53: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:54: case STATE_INPUTTESTERADVANCED:
00104$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:55: inputtester_advanced();
	call	_inputtester_advanced
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:56: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:58: case STATE_START_INPUTTESTERANALOG:
00105$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:59: start_inputtester_analog();
	call	_start_inputtester_analog
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:60: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:61: case STATE_INPUTTESTERANALOG:
00106$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:62: inputtester_analog();
	call	_inputtester_analog
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:63: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:65: case STATE_START_BTNTEST:
00107$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:66: start_btntest();
	call	_start_btntest
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:67: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:68: case STATE_BTNTEST:
00108$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:69: btntest();
	call	_btntest
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:70: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:72: case STATE_START_GUNSIGHT:
00109$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:73: start_gunsight();
	call	_start_gunsight
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:74: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:75: case STATE_GUNSIGHT:
00110$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:76: gunsight();
	call	_gunsight
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:77: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:79: case STATE_START_MENU:
00111$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:80: start_menu();
	call	_start_menu
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:81: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:82: case STATE_MENU:
00112$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:83: menu();
	call	_menu
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:84: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:86: case STATE_FADEOUT:
00113$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:87: fadeout();
	call	_fadeout
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:88: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:89: case STATE_FADEIN:
00114$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:90: fadein();
	call	_fadein
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:91: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:93: case STATE_START_ATTRACT:
00115$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:94: state = 0;
	ld	hl, #_state
	ld	(hl), #0x00
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:95: loader("SNEK.AZN");
	ld	hl, #___str_0
	call	_loader
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:96: start_snek_attract();
	call	_start_snek_attract
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:97: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:98: case STATE_ATTRACT:
00116$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:99: snek_attract();
	call	_snek_attract
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:100: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:101: case STATE_START_CREDITS:
00117$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:102: app_credits();
	call	_app_credits
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:103: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:105: case STATE_START_GAME_SNEK:
00118$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:106: start_snek_gameplay();
	call	_start_snek_gameplay
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:107: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:108: case STATE_GAME_SNEK:
00119$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:109: snek_gameplay();
	call	_snek_gameplay
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:110: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:111: case STATE_START_ZORBLAXX:
00120$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:112: state = 0;
	ld	hl, #_state
	ld	(hl), #0x00
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:113: loader("ZORBLAXX.AZN");
	ld	hl, #___str_1
	call	_loader
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:114: app_zorblaxx();
	call	_app_zorblaxx
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:115: break;
	jr	00122$
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:117: default:
00121$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:122: loader("INPUTTESTER.AZN");
	ld	hl, #___str_2
	call	_loader
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:123: start_inputtester_digital();
	call	_start_inputtester_digital
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:128: }
00122$:
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:130: hsync_last = hsync;
	ld	a, (_hsync+0)
	ld	(_hsync_last+0), a
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:131: vsync_last = vsync;
	ld	a, (_vsync+0)
	ld	(_vsync_last+0), a
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:132: hblank_last = hblank;
	ld	a, (_hblank+0)
	ld	(_hblank_last+0), a
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:133: vblank_last = vblank;
	ld	a, (_vblank+0)
	ld	(_vblank_last+0), a
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:135: }
	jp	00124$
___str_0:
	.ascii "SNEK.AZN"
	.db 0x00
___str_1:
	.ascii "ZORBLAXX.AZN"
	.db 0x00
___str_2:
	.ascii "INPUTTESTER.AZN"
	.db 0x00
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:138: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:140: app_main();
;C:\Users\Robot\Documents\GitHub\InputTest_MiSTer\src\inputtest\os.c:141: }
	jp	_app_main
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
