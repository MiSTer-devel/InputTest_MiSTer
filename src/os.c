#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include "sys.c"
#include "ui.c"
#include "ps2.c"

unsigned char hsync;
unsigned char hsync_last;
unsigned char vsync;
unsigned char vsync_last;

void page_inputs()
{
	clear_chars(0);
	page_border(0b00000111);
	write_string("RLDUABCXYZLRsS", 0xFF, 7, 3);
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

char color = 0xAB;

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

char movefreqinit = 14;

char movefreqdecfreq = 200;
char movefreqdectimer = 0;

char movefreq = 0;
char movetimer = 0;

signed int x = 20;
signed int y = 15;

signed char xd = 0;
signed char yd = 1;

signed char nxd = 0;
signed char nyd = 1;
unsigned int length = 0;

char playerchar = 83;
char fade = 0;
char fadetimer = 0;
char fadefreq = 4;

void start_inputtester()
{
	page_inputs();
	state = 1;
}

void start_fadeout()
{
	state = 2;
	fadetimer = fadefreq;
	fade = 0;
}

void start_fadein()
{
	state = 3;
	fadetimer = fadefreq;
	fade = 15;
}

char attractstate = 0;

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

char bdown_left = 0;
char bdown_left_last = 0;
char bdown_right = 0;
char bdown_right_last = 0;
char bdown_up = 0;
char bdown_up_last = 0;
char bdown_down = 0;
char bdown_down_last = 0;

char history[4];

void pushhistory(char new)
{
	for (char h = 1; h < 4; h++)
	{
		history[h - 1] = history[h];
	}
	history[3] = new;
}

char lastbufferlen = 0;
char inputindex = 0;
char fps;
char con_x;		 // Console cursor X position
char con_y;		 // Console cursor X position
char con_l = 2;	 // Console left edge X
char con_t = 21; // Console top edge Y
char con_r = 37; // Console right edge X
char con_b = 37; // Console bottom edge Y

void inputtester()
{
	hsync = input0 & 0x80;
	vsync = input0 & 0x40;

	handle_ps2();

	if (hsync && !hsync_last)
	{

		bdown_up_last = bdown_up;
		bdown_down_last = bdown_down;
		bdown_left_last = bdown_left;
		bdown_right_last = bdown_right;

		bdown_up = joystick[0] & 0b00001000;
		bdown_down = joystick[0] & 0b00000100;
		bdown_left = joystick[0] & 0b00000010;
		bdown_right = joystick[0] & 0b00000001;

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
		inputindex++;
		if (inputindex == 6)
		{
			inputindex = 0;
		}
		color++;
		fps++;
		write_string("- MiSTer Input Tester -", color, 8, 1);
		write_stringf("%d", 0xbb, 0, 1, fps);

		// char hstr[10];
		// sprintf(hstr, "%d %d %d %d", history[0], history[1], history[2], history[3]);
		if (history[0] == 4 && history[1] == 2 && history[2] == 3 && history[3] == 1)
		{
			nextstate = 6;
			pushhistory(0);
			start_fadeout();
			return;
		}
		// write_string(hstr, 0xFF, 6, 2);

		char x = 7;
		char y = 4 + inputindex;
		char inputoffset = (inputindex * 32);
		for (char b = 0; b < 2; b++)
		{
			char m = 0b00000001;
			for (char i = 0; i < 8; i++)
			{
				//(b * 8);
				x++;
				//				for (inputindex = 0; inputindex < 6; inputindex++)
				//				{
				write_char((joystick[(b * 8) + inputoffset] & m) ? asc_1 : asc_0, 0xFF, x, y);
				//				}
				m <<= 1;
			}
		}

		y = 4;
		// ANALOG
		char m = 0b00000001;
		char stra[10];
		//		for (inputindex = 0; inputindex < 6; inputindex++)
		//		{
		signed char jx = analog[(inputindex * 16)];
		signed char jy = analog[(inputindex * 16) + 8];

		sprintf(stra, "%4d %4d", jx, jy);
		write_string(stra, 0xFF, 24, y + inputindex);
		m <<= 1;
		//		}

		// PADDLE
		y = 11;
		m = 0b00000001;
		char strp[3];
		//		for (inputindex = 0; inputindex < 6; inputindex++)
		//		{
		char px = paddle[(inputindex * 8)];
		sprintf(strp, "%4d", px);
		write_string(strp, 0xFF, 6, y + inputindex);
		m <<= 1;
		//		}

		// SPINNER
		y = 11;
		m = 0b00000001;
		//		for (j = 0; j < 6; j++)
		//		{
		signed char sx = spinner[(inputindex * 16)];
		write_stringf("%4d", 0xFF, 17, y + inputindex, sx);
		m <<= 1;
		//		}

		// KEYBOARD
		// write_stringf("%3d", 0xFF, 6, 19, kbd_extend);
		// write_stringf("%3d", 0xFF, 10, 19, kbd_pressed);
		// write_stringf("%3d", 0xFF, 14, 19, kbd_shift);
		// write_stringf("%3d", 0xFF, 18, 19, kbd_lastscan);
		// write_stringf("%3d", 0xFF, 22, 19, kbd_lastascii);
		// write_char(kbd_lastascii, 0xFF, 26, 19);

		if (kbd_buffer_len > 0)
		{
			for (char k = 0; k < kbd_buffer_len; k++)
			{
				write_char(kbd_buffer[k], 0xFF, con_x, con_y);
				con_x++;
				if (con_x > con_r)
				{
					con_x = con_l;
					con_y++;
					if (con_y > con_b)
					{
						con_y = con_t;
					}
				}
			}
			kbd_buffer_len = 0;
		}

		// MOUSE
		// write_stringf("%3d", 0xFF, 6, 23, mse_a1);
		// write_stringf("%3d", 0xFF, 10, 23, mse_a2);
		// write_stringf("%3d", 0xFF, 14, 23, mse_a3);

		// write_bits(ps2_mouse, 8, 0, 3, 0xFF, 6, 25);
		// write_bits(ps2_mouse, 8, 3, 3, 0xFF, 6, 27);
	}

	hsync_last = hsync;
	vsync_last = vsync;
}

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

void main()
{
	chram_size = chram_cols * chram_rows;
	con_x = con_l;
	con_y = con_t;

	while (1)
	{
		hsync = input0 & 0x80;
		vsync = input0 & 0x40;

		if (state == 0)
		{
			start_inputtester();
		}
		if (state == 1)
		{
			inputtester();
		}
		if (state == 2)
		{
			fadeout();
		}
		if (state == 3)
		{
			fadein();
		}
		if (state == 4)
		{
			start_gameplay();
		}
		if (state == 5)
		{
			gameplay();
		}
		if (state == 6)
		{
			start_attract();
		}
		if (state == 7)
		{
			attract();
		}

		hsync_last = hsync;
		vsync_last = vsync;
	}
}