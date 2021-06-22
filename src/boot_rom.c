#include <stdio.h>
#include <stdbool.h>
#include <string.h>

// Memory maps
unsigned char __at(0x6000) input0;
unsigned char __at(0x7000) joystick[24];
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
	write_string("UDLR", 0xFF, 9, 3);
	write_string("JOY 1)", 0xF0, 2, 4);
	write_string("JOY 2)", 0xE0, 2, 5);
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

		if (vsync && !vsync_last)
		{
			color++;
			write_string("--- MiSTer Input Tester ---", color, 6, 1);

			for (char b = 0; b < 2; b++)
			{
				char m = 0b00000001;
				for (char i = 0; i < 8; i++)
				{
					char x = 9 + i + (b * 10);
					for (char j = 0; j < 3; j++)
					{
						write_char((joystick[b + (j * 32)] & m) ? asc_1 : asc_0, 0xFF, x, 4 + j);
					}
					m <<= 1;
				}
			}
		}
		hsync_last = hsync;
		vsync_last = vsync;
	}
}