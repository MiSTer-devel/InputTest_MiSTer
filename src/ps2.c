/*============================================================================
	Aznable OS - PS/2 interface functions

	Author: Jim Gregory - https://github.com/JimmyStones/
	Version: 1.1
	Date: 2021-10-20

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 3 of the License, or (at your option)
	any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program. If not, see <http://www.gnu.org/licenses/>.
===========================================================================*/

#pragma once
#include "sys.c"

// COMMAND KEYS
const char KEY_TAB = 0x0d;
const char KEY_CAPSLOCK = 0x58;
const char KEY_ENTER = 0x5a;
const char KEY_BACKSPACE = 0x66;
const char KEY_ESC = 0x76;
const char KEY_LEFTSHIFT = 0x12;
const char KEY_RIGHTSHIFT = 0x59;
const char KEY_ALT = 0x11;	// EXT 0 = LEFT, EXT 1 = RIGHT
const char KEY_CTRL = 0x63; // EXT 0 = LEFT, EXT 1 = RIGHT

// USEFUL KEYS
const char KEY_1 = 0x16;
const char KEY_SPACE = 0x29;

// UNMAPPED COMMAND KEYS
// 	0x7c, //55  KEY_KPASTERISK
// 	0x05, //59  KEY_F1
// 	0x06, //60  KEY_F2
// 	0x04, //61  KEY_F3
// 	0x0c, //62  KEY_F4
// 	0x03, //63  KEY_F5
// 	0x0b, //64  KEY_F6
// 	0x83, //65  KEY_F7
// 	0x0a, //66  KEY_F8
// 	0x01, //67  KEY_F9
// 	0x09, //68  KEY_F10
// 	0x6c, //71  KEY_KP7
// 	0x75, //72  KEY_KP8
// 	0x7d, //73  KEY_KP9
// 	0x7b, //74  KEY_KPMINUS
// 	0x6b, //75  KEY_KP4
// 	0x73, //76  KEY_KP5
// 	0x74, //77  KEY_KP6
// 	0x79, //78  KEY_KPPLUS
// 	0x69, //79  KEY_KP1
// 	0x72, //80  KEY_KP2
// 	0x7a, //81  KEY_KP3
// 	0x70, //82  KEY_KP0
// 	0x71, //83  KEY_KPDOT
// 	0x61, //86  KEY_102ND
// 	0x78, //87  KEY_F11
// 	0x07, //88  KEY_F12

// EXTENSION KEYS
const char KEY_UP = 0x75;
const char KEY_LEFT = 0x6b;
const char KEY_RIGHT = 0x74;
const char KEY_DOWN = 0x72;

// UNMAPPED EXTENSION KEYS
// 	EXT | 0x5a, //96  KEY_KPENTER
// 	EXT | 0x4a, //98  KEY_KPSLASH
// 	EXT | 0x6c, //102 KEY_HOME
// 	EXT | 0x7d, //104 KEY_PAGEUP
// 	EXT | 0x69, //107 KEY_END
// 	EXT | 0x7a, //109 KEY_PAGEDOWN
// 	EXT | 0x70, //110 KEY_INSERT
// 	EXT | 0x71, //111 KEY_DELETE

char kbd_UK[256] =
	{
		0, 0,		// 0x00
		0, 0,		// 0x01
		0, 0,		// 0x02
		0, 0,		// 0x03
		0, 0,		// 0x04
		0, 0,		// 0x05
		0, 0,		// 0x06
		0, 0,		// 0x07
		0, 0,		// 0x08
		0, 0,		// 0x09
		0, 0,		// 0x0a
		0, 0,		// 0x0b
		0, 0,		// 0x0c
		0, 0,		// 0x0d
		'¬', '`',	// 0x0e
		0, 0,		// 0x0f
		0, 0,		// 0x10
		0, 0,		// 0x11
		0, 0,		// 0x12
		0, 0,		// 0x13
		0, 0,		// 0x14
		'Q', 'q',	// 0x15
		'!', '1',	// 0x16
		0, 0,		// 0x17
		0, 0,		// 0x18
		0, 0,		// 0x19
		'Z', 'z',	// 0x1a
		'S', 's',	// 0x1b
		'A', 'a',	// 0x1c
		'W', 'w',	// 0x1d
		'"', '2',	// 0x1e
		0, 0,		// 0x1f
		0, 0,		// 0x20
		'C', 'c',	// 0x21
		'X', 'x',	// 0x22
		'D', 'd',	// 0x23
		'E', 'e',	// 0x24
		'$', '4',	// 0x25
		'£', '3',	// 0x26
		0, 0,		// 0x27
		0, 0,		// 0x28
		' ', ' ',	// 0x29
		'V', 'v',	// 0x2a
		'F', 'f',	// 0x2b
		'T', 't',	// 0x2c
		'R', 'r',	// 0x2d
		'%', '5',	// 0x2e
		0, 0,		// 0x2f
		0, 0,		// 0x30
		'N', 'n',	// 0x31
		'B', 'b',	// 0x32
		'H', 'h',	// 0x33
		'G', 'g',	// 0x34
		'Y', 'y',	// 0x35
		'^', '6',	// 0x36
		0, 0,		// 0x37
		0, 0,		// 0x38
		0, 0,		// 0x39
		'M', 'm',	// 0x3a
		'J', 'j',	// 0x3b
		'U', 'u',	// 0x3c
		'&', '7',	// 0x3d
		'*', '8',	// 0x3e
		0, 0,		// 0x3f
		0, 0,		// 0x40
		'<', ',',	// 0x41
		'K', 'k',	// 0x42
		'I', 'i',	// 0x43
		'O', 'o',	// 0x44
		')', '0',	// 0x45
		'(', '9',	// 0x46
		0, 0,		// 0x47
		0, 0,		// 0x48
		'>', '.',	// 0x49
		'?', '/',	// 0x4a
		'L', 'l',	// 0x4b
		':', ';',	// 0x4c
		'P', 'p',	// 0x4d
		'_', '-',	// 0x4e
		0, 0,		// 0x4f
		0, 0,		// 0x50
		0, 0,		// 0x51
		'@', '\'',	// 0x52
		0, 0,		// 0x53
		'{', '[',	// 0x54
		'+', '=',	// 0x55
		0, 0,		// 0x56
		0, 0,		// 0x57
		'+', '=',	// 0x58
		0, 0,		// 0x59 (RSHIFT)
		'\n', '\n', // 0x5a (ENTER)
		'}', ']',	// 0x5b
		0, 0,		// 0x5c
		'|', '\\',	// 0x5d
		0, 0,		// 0x5e
		0, 0,		// 0x5f
		0, 0,		// 0x60
		0, 0,		// 0x61
		0, 0,		// 0x62
		0, 0,		// 0x63
		0, 0,		// 0x64
		0, 0,		// 0x65
		'\b', '\b', // 0x66
		0, 0};

char kbd_in[2];
char kbd_lastclock = 0;
char kbd_shift_left = 0;
char kbd_shift_right = 0;
char kbd_scan = 0;
char kbd_pressed;
char kbd_extend;
char kbd_ascii = 0;
char kbd_clock_index = 1;

char mse_lastclock = 0;
bool mse_changed = 1;
signed char mse_x;
signed char mse_y;
signed char mse_w;
char mse_button1;
char mse_button2;
char mse_clock_index = 3;

char kbd_buffer[128];
char kbd_buffer_len = 0;
bool kbd_down[256];

void get_ascii()
{
	char p = (kbd_scan * 2);
	if (!(kbd_shift_left || kbd_shift_right))
	{
		p++;
	}
	kbd_ascii = kbd_UK[p];
	if (kbd_ascii > 0)
	{
		kbd_buffer[kbd_buffer_len] = kbd_ascii;
		kbd_buffer_len++;
	}
}

void handle_ps2()
{
	bool kbd_clock = CHECK_BIT(ps2_key[kbd_clock_index], 2);
	if (kbd_clock != kbd_lastclock)
	{
		for (char k = 0; k < 2; k++)
		{
			kbd_in[k] = ps2_key[k];
		}
		kbd_extend = CHECK_BIT(kbd_in[1], 0) > 0;
		kbd_pressed = CHECK_BIT(kbd_in[1], 1) > 0;
		kbd_scan = kbd_in[0];
		kbd_ascii = 0;
		if (kbd_pressed)
		{
			kbd_down[kbd_scan] = 1;
			if (kbd_scan == KEY_LEFTSHIFT)
			{
				kbd_shift_left = 1;
			}
			else if (kbd_scan == KEY_RIGHTSHIFT)
			{
				kbd_shift_right = 1;
			}
			else
			{
				get_ascii();
			}
		}
		else
		{
			kbd_down[kbd_scan] = 0;
			if (kbd_scan == KEY_LEFTSHIFT)
			{
				kbd_shift_left = 0;
			}
			else if (kbd_scan == KEY_RIGHTSHIFT)
			{
				kbd_shift_right = 0;
			}
			else
			{
				get_ascii();
			}
		}
	}
	kbd_lastclock = kbd_clock;

	bool mse_clock = CHECK_BIT(ps2_mouse[mse_clock_index], 0);
	if (mse_clock != mse_lastclock)
	{
		mse_changed = 1;
		mse_button1 = ps2_mouse[0];
		mse_button2 = ps2_mouse[5];
		mse_x = ps2_mouse[1];
		mse_y = ps2_mouse[2];
		mse_w = ps2_mouse[4];
	}
	mse_lastclock = mse_clock;
}
