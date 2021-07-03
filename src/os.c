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

// Application state
#define STATE_START_INPUTTESTER 0
#define STATE_INPUTTESTER 1

#define STATE_START_INPUTTESTERADV 2
#define STATE_INPUTTESTERADV 3

#define STATE_FADEOUT 8
#define STATE_START_FADEIN 9
#define STATE_FADEIN 10

#define STATE_START_ATTRACT 16
#define STATE_ATTRACT 17

#define STATE_START_GAME 24
#define STATE_GAME 25

char state = STATE_START_INPUTTESTER;
char nextstate = STATE_START_INPUTTESTER;

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
// unsigned char __at(0xC200) joystick_last[12];
// signed char __at(0xC210) ax_last[6];
// signed char __at(0xC220) ay_last[6];
// unsigned char __at(0xC230) px_last[6];
// signed char __at(0xC240) sx_toggle_last[6];
// signed char __at(0xC250) sx_last[6];
// unsigned long __at(0xC260) sx_pos[6];
unsigned char joystick_last[12];
signed char ax_last[6];
signed char ay_last[6];
unsigned char px_last[6];
signed char sx_toggle_last[6];
signed char sx_last[6];
unsigned long sx_pos[6];

unsigned char con_x;	  // Console cursor X position
unsigned char con_y;	  // Console cursor X position
unsigned char con_l = 2;  // Console left edge X
unsigned char con_t = 20; // Console top edge Y
unsigned char con_r = 37; // Console right edge X
unsigned char con_b = 37; // Console bottom edge Y
bool con_cursor;
unsigned char con_cursortimer = 1;
unsigned char con_cursorfreq = 30;
char modeswitchtimer = 0;

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

char color_pad_outline = 0xFE;

#define PAD_COUNT 2
#define BUTTON_COUNT 12

char pad_offset_x[PAD_COUNT] = {6, 6};
char pad_offset_y[PAD_COUNT] = {6, 18};
char button_name[BUTTON_COUNT][6] = {
	"R",
	"L",
	"D",
	"U",
	"A",
	"B",
	"X",
	"Y",
	"L",
	"R",
	"Sel",
	"Start"};
char button_x[BUTTON_COUNT] = {6, 2, 4, 4, 24, 22, 22, 20, 3, 23, 9, 13};
char button_y[BUTTON_COUNT] = {3, 3, 4, 2, 3, 4, 2, 3, 0, 0, 3, 3};

void draw_pad(char xo, char yo)
{
	// Outline
	write_char(134, color_pad_outline, xo, yo + 1);
	for (char x = 1; x < 26; x++)
	{
		write_char(135, color_pad_outline, xo + x, yo + 1);
	}
	write_char(136, color_pad_outline, xo + 26, yo + 1);
	for (char y = 2; y < 5; y++)
	{
		write_char(137, color_pad_outline, xo, yo + y);
		write_char(137, color_pad_outline, xo + 26, yo + y);
	}
	write_char(139, color_pad_outline, xo, yo + 5);
	write_char(138, color_pad_outline, xo + 26, yo + 5);

	write_char(138, color_pad_outline, xo + 8, yo + 5);
	write_char(139, color_pad_outline, xo + 18, yo + 5);
	write_char(134, color_pad_outline, xo + 8, yo + 4);
	write_char(136, color_pad_outline, xo + 18, yo + 4);
	for (char x = 1; x < 8; x++)
	{
		write_char(135, color_pad_outline, xo + x, yo + 5);
	}
	for (char x = 9; x < 18; x++)
	{
		write_char(135, color_pad_outline, xo + x, yo + 4);
	}
	for (char x = 19; x < 26; x++)
	{
		write_char(135, color_pad_outline, xo + x, yo + 5);
	}
	// Shoulders
	write_char(134, color_pad_outline, xo + 1, yo);
	write_char(136, color_pad_outline, xo + 5, yo);
	write_char(134, color_pad_outline, xo + 21, yo);
	write_char(136, color_pad_outline, xo + 25, yo);
}

// Draw static elements for basic input test page
void page_inputtester()
{
	clear_chars(0);
	page_border(0b00000111);

	write_string("- MiSTer Input Tester -", 0b11100011, 8, 1);
	write_string("Hold <Select> for advanced mode", 0b11100011, 4, 29);

	// Draw pad 1
	for (char j = 0; j < PAD_COUNT; j++)
	{
		write_stringf("JOY %d", 0xFF, pad_offset_x[j], pad_offset_y[j] - 1, j + 1);
		draw_pad(pad_offset_x[j], pad_offset_y[j]);
	}
}

// Draw static elements for advanced input test page
void page_inputtester_adv()
{
	clear_chars(0);
	page_border(0b00000111);

	write_string("- MiSTer Input Tester -", 0b11100011, 8, 1);
	write_string("Hold <Select> for basic mode", 0b11100011, 4, 29);

	write_string("RLDUABXYLRsSCZ", 0xFF, 7, 3);
	write_string("AX", 0xFF, 26, 3);
	write_string("AY", 0xFF, 31, 3);

	write_string("POS", 0xFF, 7, 11);
	write_string("SPD  POS", 0xFF, 18, 11);

	char label[5];
	for (unsigned char j = 0; j < 6; j++)
	{
		sprintf(label, "JOY%d", j + 1);
		write_string(label, 0xFF - (j * 2), 2, 4 + j);

		sprintf(label, "PAD%d", j + 1);
		write_string(label, 0xFF - (j * 2), 2, 12 + j);

		sprintf(label, "SPN%d", j + 1);
		write_string(label, 0xFF - (j * 2), 14, 12 + j);
	}
	write_string("CON", 0xFF, 2, 19);
}

void reset_inputstates()
{
	modeswitchtimer = 0;
	for (char i = 0; i < 12; i++)
	{
		joystick_last[i] = 1;
	}
	for (char i = 0; i < 6; i++)
	{
		ax_last[i] = 1;
		ay_last[i] = 1;
		px_last[i] = 1;
		sx_toggle_last[i] = 1;
		sx_last[i] = 1;
		sx_pos[i] = 0;
	}
}

// Initialise basic inputtester state and draw static elements
void start_inputtester()
{
	state = STATE_INPUTTESTER;

	// Draw page
	page_inputtester();

	// Reset last states for inputs
	reset_inputstates();
}

// Initialise advanced inputtester state and draw static elements
void start_inputtester_adv()
{
	state = STATE_INPUTTESTERADV;

	// Draw page
	page_inputtester_adv();

	// Reset console cursor
	con_x = con_l;
	con_y = con_t;

	// Reset last states for inputs
	reset_inputstates();
}

// Initialise fadeout state
void start_fadeout()
{
	state = STATE_FADEOUT;
	fadetimer = fadefreq;
	fade = 0;
}

// Initialise fadein state
void start_fadein()
{
	state = STATE_FADEIN;
	fadetimer = fadefreq;
	fade = 15;
}

// Initialise attract state and draw static elements
void start_attract()
{
	state = STATE_ATTRACT;
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
	state = STATE_GAME;
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

// Track input history of P1 DPAD for secret codes!
void handle_codes()
{
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
	// Check for SNEK code
	if (history[0] == 4 && history[1] == 2 && history[2] == 3 && history[3] == 1)
	{
		nextstate = STATE_START_ATTRACT;
		pushhistory(0);
		start_fadeout();
		return;
	}
}

// Advanced input tester state
void inputtester()
{

	// Handle PS/2 inputs whenever possible to improve latency
	handle_ps2();

	// Handle secret code detection (joypad 1 directions)
	if (hsync && !hsync_last)
	{
		handle_codes();
	}

	// As soon as vsync is detected start drawing screen updates
	if (vsync && !vsync_last)
	{
		// Switch to basic mode if select is held for 1 second
		if (CHECK_BIT(joystick[8], 2))
		{
			modeswitchtimer++;
			if (modeswitchtimer == 60)
			{
				start_inputtester_adv();
				return;
			}
		}

		// Draw control pad buttons
		for (char joy = 0; joy < PAD_COUNT; joy++)
		{
			char index = joy * 32;
			for (char button = 0; button < BUTTON_COUNT; button++)
			{
				char color = (button < 8 ? CHECK_BIT(joystick[index], button) : CHECK_BIT(joystick[index + 8], button - 8)) ? 0xFF : 0b10010010;
				write_string(button_name[button], color, pad_offset_x[joy] + button_x[button], pad_offset_y[joy] + button_y[button]);
			}
		}
	}
}

// Advanced input tester state
void inputtester_adv()
{

	// Handle PS/2 inputs whenever possible to improve latency
	handle_ps2();

	// Handle secret code detection (joypad 1 directions)
	if (hsync && !hsync_last)
	{
		handle_codes();
	}

	// As soon as vsync is detected start drawing screen updates
	if (vsync && !vsync_last)
	{
		// Switch to basic mode if select is held for 1 second
		if (CHECK_BIT(joystick[8], 2))
		{
			modeswitchtimer++;
			if (modeswitchtimer == 60)
			{
				start_inputtester();
				return;
			}
		}

		// Draw joystick inputs (only update each byte if value has changed)
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

			// Draw analog inputs (only update if value has changed)
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

			// Draw paddle inputs (only update if value has changed)
			unsigned char px = paddle[(inputindex * 8)];
			if (px != px_last[inputindex])
			{
				char strp[5];
				sprintf(strp, "%4d", px);
				write_string(strp, 0xFF, 6, 12 + inputindex);
			}
			px_last[inputindex] = px;

			// Draw spinner inputs (only update when update clock changes)
			bool sx_toggle = CHECK_BIT(spinner[(inputindex * 16) + 8], 0);
			signed char sx = spinner[(inputindex * 16)];
			if (sx_toggle != sx_toggle_last[inputindex])
			{
				sx_pos[inputindex] += sx;
				write_stringf("%4d", 0xFF, 22, 12 + inputindex, sx_pos[inputindex] / 16);
			}
			else
			{
				sx = 0;
			}
			if (sx_last[inputindex] != sx)
			{
				write_stringfs("%4d", 0xFF, 17, 12 + inputindex, sx);
			}
			sx_last[inputindex] = sx;
			sx_toggle_last[inputindex] = sx_toggle;
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

		if (CHECK_BIT(joystick[8], 2)) // select to quit
		{
			start_inputtester_adv();
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
		if (CHECK_BIT(joystick[8], 3)) // start
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
		case STATE_START_INPUTTESTER:
			start_inputtester();
			break;
		case STATE_INPUTTESTER:
			inputtester();
			break;

		case STATE_START_INPUTTESTERADV:
			start_inputtester_adv();
			break;
		case STATE_INPUTTESTERADV:
			inputtester_adv();
			break;

		case STATE_FADEOUT:
			fadeout();
			break;
		case STATE_FADEIN:
			fadein();
			break;

		case STATE_START_ATTRACT:
			start_attract();
			break;
		case STATE_ATTRACT:
			attract();
			break;

		case STATE_START_GAME:
			start_gameplay();
			break;
		case STATE_GAME:
			gameplay();
			break;

		default:
			break;
		}
		hsync_last = hsync;
		vsync_last = vsync;
	}
}
