#include <stdio.h>
#include <stdbool.h>
#include <string.h>

// Memory maps
unsigned char __at(0x6000) input0;
unsigned char __at(0x7000) joystick[24];
unsigned char __at(0x7100) analog[12];
unsigned char __at(0x7200) paddle[6];
unsigned char __at(0x7300) spinner[12];
unsigned char __at(0x8000) chram[2048];
unsigned char __at(0x8800) colram[2048];

// Character map
const unsigned char chram_cols = 64;
const unsigned char chram_rows = 32;
unsigned int chram_size;

unsigned char hsync;
unsigned char hsync_last;
unsigned char vsync;
unsigned char vsync_last;

void clear_chars()
{
	for (unsigned int p = 0; p < chram_size; p++)
	{
		chram[p] = 0;
	}
}

void write_string(const char *string, char color, unsigned int x, unsigned int y)
{
	unsigned int p = (y * chram_cols) + x;
	unsigned char l = strlen(string);
	for (char c = 0; c < l; c++)
	{
		chram[p] = string[c];
		colram[p] = color;
		p++;
	}
}

void write_char(unsigned char c, char color, unsigned int x, unsigned int y)
{
	unsigned int p = (y * chram_cols) + x;
	chram[p] = c;
	colram[p] = color;
}

void page_border(char color)
{
	write_char(128, color, 0, 0);
	write_char(130, color, 39, 0);
	write_char(133, color, 0, 29);
	write_char(132, color, 39, 29);
	for (char x = 1; x < 39; x++)
	{
		write_char(129, color, x, 0);
		write_char(129, color, x, 29);
	}
	for (char y = 1; y < 29; y++)
	{
		write_char(131, color, 0, y);
		write_char(131, color, 39, y);
	}
}

void page_inputs()
{
	clear_chars();
	page_border(0b00000111);
	write_string("UDLRABCXYZLRSs", 0xFF, 7, 3);
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
		write_string(label, 0xFF - (j * 2), 2, 18 + j);
	}
}

char asc_0 = 48;
char asc_1 = 49;

void main()
{
	chram_size = chram_cols * chram_rows;
	char color = 0xAB;
	page_inputs();

	while (1)
	{
		hsync = input0 & 0x80;
		vsync = input0 & 0x40;

		// if(hsync && !hsync_last){
		// }

		char j = 0;

		if (vsync && !vsync_last)
		{
			color++;
			write_string("--- MiSTer Input Tester ---", color, 6, 1);
			int y = 4;
			for (char b = 0; b < 2; b++)
			{
				char m = 0b00000001;
				for (char i = 0; i < 8; i++)
				{
					char x = 7 + i + (b * 8);
					for (j = 0; j < 6; j++)
					{
						write_char((joystick[(b * 8) + (j * 32)] & m) ? asc_1 : asc_0, 0xFF, x, 4 + j);
					}
					m <<= 1;
				}
			}

			y = 4;
			// ANALOG
			char m = 0b00000001;
			char stra[10];
			// char stra2[5];
			for (j = 0; j < 6; j++)
			{
				signed char jx = analog[(j * 16)];
				signed char jy = analog[(j * 16) + 8];

				sprintf(stra, "%4d %4d", jx, jy);
				write_string(stra, 0xFF, 24, y + j);
				// sprintf(stra2, "%-4d", jy);
				// write_string(stra2, 0xFF, 29, y + j);
				m <<= 1;
			}

			// PADDLE
			y = 11;
			m = 0b00000001;
			char strp[3];
			for (j = 0; j < 6; j++)
			{
				char px = paddle[(j * 8)];
				sprintf(strp, "%4d", px);
				write_string(strp, 0xFF, 6, y + j);
				m <<= 1;
			}

			// SPINNER
			y = 18;
			m = 0b00000001;
			char strs[3];
			for (j = 0; j < 6; j++)
			{
				signed char sx = spinner[(j * 16)];
				sprintf(strs, "%4d", sx);
				write_string(strs, 0xFF, 7, y + j);
				m <<= 1;
			}
		}

		hsync_last = hsync;
		vsync_last = vsync;
	}
}