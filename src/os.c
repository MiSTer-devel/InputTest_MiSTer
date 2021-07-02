/*============================================================================
	MiSTer test harness OS - Main application

	Author: Jim Gregory - https://github.com/JimmyStones/
	Version: 0.1
	Date: 2021-06-29

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

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include "sys.c"
#include "ui.c"
#include "ps2.c"

bool hsync;
bool hsync_last;
bool vsync;
bool vsync_last;

// Draw static elements for input test page
void page_inputs()
{
	clear_chars(0);
	page_border(0b00000111);

	write_string("- MiSTer Input Tester -", 0b11100011, 8, 1);
	write_string("RLDUABXYLRsSCZ", 0xFF, 7, 3);
	write_string("AX", 0xFF, 26, 3);
	write_string("AY", 0xFF, 31, 3);

	char label[5];
	for (unsigned char j = 0; j < 6; j++)
	{
		sprintf(label, "JOY%d", j + 1);
		write_string(label, 0xFF - (j * 2), 2, 4 + j);

		sprintf(label, "PAD%d", j + 1);
		write_string(label, 0xFF - (j * 2), 2, 11 + j);

		sprintf(label, "SPN%d", j + 1);
		write_string(label, 0xFF - (j * 2), 14, 11 + j);
	}

	// write_string("EXT PRS SHF SCN ASC CHR", 0xFF, 6, 18);
	write_string("CON", 0xFF, 2, 18);
}

// Application state
char state = 0;
char nextstate = 0;
// state = 0 - inputtester
// state = 1 - fadeout
// state = 2 - fadein
// state = 3 - startfadein
// state = 4 - startgame
// state = 5 - gameplaying
// state = 7 - startattract
// state = 8 - attract

// SNEK variables
unsigned char movefreqinit = 14;
unsigned char movefreqdecfreq = 200;
unsigned char movefreqdectimer = 0;
unsigned char movefreq = 0;
unsigned char movetimer = 0;
signed int x = 20;
signed int y = 15;
signed char xd = 0;
signed char yd = 1;
signed char nxd = 0;
signed char nyd = 1;
unsigned int length = 0;
unsigned char playerchar = 83;

// Fade in/out variables
unsigned char fade = 0;
unsigned char fadetimer = 0;
unsigned char fadefreq = 4;

// Attract mode variables
unsigned char attractstate = 0;

// Input tester variables
unsigned char inputindex = 0;
unsigned char __at(0xC200) joystick_last[12];
signed char __at(0xC210) ax_last[6];
signed char __at(0xC220) ay_last[6];
unsigned char __at(0xC230) px_last[6];
signed char __at(0xC240) sx_last[6];

unsigned char con_x;	  // Console cursor X position
unsigned char con_y;	  // Console cursor X position
unsigned char con_l = 2;  // Console left edge X
unsigned char con_t = 20; // Console top edge Y
unsigned char con_r = 37; // Console right edge X
unsigned char con_b = 37; // Console bottom edge Y
bool con_cursor;
unsigned char con_cursortimer = 1;
unsigned char con_cursorfreq = 30;

// DPAD tracker
bool bdown_left = 0;
bool bdown_left_last = 0;
bool bdown_right = 0;
bool bdown_right_last = 0;
bool bdown_up = 0;
bool bdown_up_last = 0;
bool bdown_down = 0;
bool bdown_down_last = 0;
char history[4];

// Initialise inputtester state and draw static elements
void start_inputtester()
{
	page_inputs();
	state = 1;
	con_x = con_l;
	con_y = con_t;
	for (char i = 0; i < 12; i++)
	{
		joystick_last[i] = 1;
	}
	for (char i = 0; i < 6; i++)
	{
		ax_last[i] = 1;
		ay_last[i] = 1;
		px_last[i] = 1;
		sx_last[i] = 1;
	}
}

// Initialise fadeout state
void start_fadeout()
{
	state = 2;
	fadetimer = fadefreq;
	fade = 0;
}

// Initialise fadein state
void start_fadein()
{
	state = 3;
	fadetimer = fadefreq;
	fade = 15;
}

// Initialise attract state and draw static elements
void start_attract()
{
	state = 7;
	attractstate = 0;
	clear_chars(0);
	page_border(0b00000111);
	write_string("SNEK", 0b00000111, 18, 0);
	movefreq = 5;
	movetimer = 1;
}

// Initialise attract state and draw static elements
void start_gameplay()
{
	state = 5;
	length = 0;
	x = 20;
	y = 15;
	xd = 0;
	yd = 1;
	nxd = 0;
	nyd = 1;
	clear_chars(0);
	page_border(0b00000111);
	write_string("SNEK", 0b00000111, 18, 0);
	write_char(playerchar, 0xFF, x, y);

	movefreq = movefreqinit;
	movefreqdectimer = movefreqdecfreq;
	movetimer = movefreq;
}

// Fade out state
void fadeout()
{
	if (vsync && !vsync_last)
	{
		fadetimer--;
		if (fadetimer == 0)
		{
			box(fade, fade, 39 - fade, 29 - fade, 127, 0b0000111);
			fadetimer = fadefreq;
			fade++;
			if (fade == 16)
			{
				start_fadein();
			}
		}
	}
}

// Fade in state
void fadein()
{
	if (vsync && !vsync_last)
	{
		fadetimer--;
		if (fadetimer == 0)
		{
			box(fade, fade, 39 - fade, 29 - fade, 0, 0b0000000);
			fadetimer = fadefreq;
			fade--;
			if (fade == 0)
			{
				state = nextstate;
			}
		}
	}
}

// Rotate DPAD direction history and push new entry
void pushhistory(char new)
{
	for (char h = 1; h < 4; h++)
	{
		history[h - 1] = history[h];
	}
	history[3] = new;
}


// Input tester state
void inputtester()
{

	// Handle PS/2 inputs whenever possible to improve latency
	handle_ps2();

	if (hsync && !hsync_last)
	{
		// Track input history of P1 DPAD for secret codes!
		bdown_up_last = bdown_up;
		bdown_down_last = bdown_down;
		bdown_left_last = bdown_left;
		bdown_right_last = bdown_right;
		bdown_up = CHECK_BIT(joystick[0], 3);
		bdown_down = CHECK_BIT(joystick[0], 2);
		bdown_left = CHECK_BIT(joystick[0], 1);
		bdown_right = CHECK_BIT(joystick[0], 0);
		if (!bdown_up && bdown_up_last)
		{
			pushhistory(1);
		}
		if (!bdown_down && bdown_down_last)
		{
			pushhistory(2);
		}
		if (!bdown_left && bdown_left_last)
		{
			pushhistory(3);
		}
		if (!bdown_right && bdown_right_last)
		{
			pushhistory(4);
		}
	}

	if (vsync && !vsync_last)
	{

		// Rotate index of inputs to show this loop
		inputindex++;
		if (inputindex == 6)
		{
			inputindex = 0;
		}

		// Check for SNEK code
		if (history[0] == 4 && history[1] == 2 && history[2] == 3 && history[3] == 1)
		{
			nextstate = 6;
			pushhistory(0);
			start_fadeout();
			return;
		}

		// Draw joystick inputs
		for (char inputindex = 0; inputindex < 6; inputindex++)
		{
			char m = 0b00000001;
			char x = 6;
			char y = 4 + inputindex;
			char inputoffset = (inputindex * 32);
			char lastoffset = (inputindex * 2);
			for (char b = 0; b < 2; b++)
			{
				char index = (b * 8) + inputoffset;
				char lastindex = b + lastoffset;
				char joy = joystick[index];
				if (joy != joystick_last[lastindex])
				{
					m = 0b00000001;
					for (char i = 0; i < 8; i++)
					{
						x++;
						write_char((joy & m) ? asc_1 : asc_0, 0xFF, x, y);
						m <<= 1;
					}
				}
				else
				{
					x += 8;
				}
				joystick_last[lastindex] = joy;
			}

			// Draw analog inputs
			signed char ax = analog[(inputindex * 16)];
			signed char ay = analog[(inputindex * 16) + 8];
			if (ax != ax_last[inputindex] || ay != ay_last[inputindex])
			{
				char stra[10];
				sprintf(stra, "%4d %4d", ax, ay);
				write_string(stra, 0xFF, 24, 4 + inputindex);
			}
			ax_last[inputindex] = ax;
			ay_last[inputindex] = ay;

			// Draw paddle inputs
			unsigned char px = paddle[(inputindex * 8)];
			if (px != px_last[inputindex])
			{
				char strp[5];
				sprintf(strp, "%4d", px);
				write_string(strp, 0xFF, 6, 11 + inputindex);
			}
			px_last[inputindex] = px;

			// Draw spinner inputs
			signed char sx = spinner[(inputindex * 16)];
			if (sx != sx_last[inputindex])
			{
				char strs[5];
				sprintf(strs, "%4d", sx);
				write_string(strs, 0xFF, 17, 11 + inputindex);
			}
			sx_last[inputindex] = sx;
		}

		// Keyboard test console
		if (kbd_buffer_len > 0)
		{
			// Clear existing cursor if visible
			if (con_cursor)
			{
				write_char(' ', 0xFF, con_x, con_y);
			}
			// Write characters in buffer
			for (char k = 0; k < kbd_buffer_len; k++)
			{
				if (kbd_buffer[k] == '\n')
				{
					// New line
					con_x = con_l;
					con_y++;
					if (con_y > con_b)
					{
						// Wrap to top
						con_y = con_t;
					}
				}
				else if (kbd_buffer[k] == '\b')
				{
					// Backspace - only if not at beginning of line
					if (con_x > con_l)
					{
						con_x--;
						// Clear existing character
						write_char(' ', 0xFF, con_x, con_y);
					}
				}
				else
				{
					// Write character
					write_char(kbd_buffer[k], 0xFF, con_x, con_y);
					// Move cursor right
					con_x++;
					if (con_x > con_r)
					{
						// New line
						con_x = con_l;
						con_y++;
						if (con_y > con_b)
						{
							// Wrap to top
							con_y = con_t;
						}
					}
				}
			}
			// Clear buffer and enable cursor
			kbd_buffer_len = 0;
			con_cursor = 0;
			con_cursortimer = 1;
		}

		// Cursor blink timer
		con_cursortimer--;
		if (con_cursortimer <= 0)
		{
			con_cursor = !con_cursor;
			con_cursortimer = con_cursorfreq;
			write_char(con_cursor ? '|' : ' ', 0xFF, con_x, con_y);
		}

	}
}

// SNEK - gameplay state
void gameplay()
{

	if (hsync && !hsync_last)
	{
		if (yd != 1 && joystick[0] & 0b00001000) // up
		{
			nyd = -1;
			nxd = 0;
		}
		if (yd != -1 && joystick[0] & 0b00000100) // down
		{
			nyd = 1;
			nxd = 0;
		}
		if (xd != 1 && joystick[0] & 0b00000010) // left
		{
			nxd = -1;
			nyd = 0;
		}
		if (xd != -1 && joystick[0] & 0b00000001) //right
		{
			nxd = 1;
			nyd = 0;
		}

		if (joystick[0] & 0b00010000)
		{
			start_inputtester();
			return;
		}
	}

	if (vsync && !vsync_last)
	{
		movetimer--;
		if (movetimer == 0)
		{
			write_char(127, 0x66, x, y);
			xd = nxd;
			yd = nyd;
			x += xd;
			y += yd;
			unsigned int p = (y * chram_cols) + x;
			if (chram[p] > 0)
			{
				nextstate = 4;
				start_fadeout();
				return;
			}
			length++;
			write_char(playerchar, 0xFF, x, y);
			movetimer = movefreq;
			char score[5];
			sprintf(score, "%4d", length);
			write_string(score, 0xFF, 35, 0);
		}

		movefreqdectimer--;
		if (movefreqdectimer == 0)
		{
			movefreqdectimer = movefreqdecfreq;
			if (movefreq > 3)
			{
				movefreq--;
			}
			char str_movefreq[3];
			sprintf(str_movefreq, "%4d", movefreq);
			write_string(str_movefreq, 0xFF, 35, 29);
		}
	}
}

// SNEK - attract state
void attract()
{

	if (hsync && !hsync_last)
	{
		if (joystick[1] & 0b00100000) // start
		{
			start_gameplay();
		}
	}

	if (vsync && !vsync_last)
	{
		movetimer--;
		if (movetimer == 0)
		{
			attractstate = !attractstate;
			write_string("PRESS START", attractstate == 0 ? 0x00 : 0xFF, 16, 15);
			movetimer = movefreq;
		}
	}
}

// Main entry and state machine
void main()
{
	chram_size = chram_cols * chram_rows;
	while (1)
	{
		hsync = input0 & 0x80;
		vsync = input0 & 0x40;
		switch (state)
		{
		case 0:
			start_inputtester();
			break;
		case 1:
			inputtester();
			break;
		case 2:
			fadeout();
			break;
		case 3:
			fadein();
			break;
		case 4:
			start_gameplay();
			break;
		case 5:
			gameplay();
			break;
		case 6:
			start_attract();
			break;
		case 7:
			attract();
			break;
		default:
			break;
		}
		hsync_last = hsync;
		vsync_last = vsync;
	}
}
