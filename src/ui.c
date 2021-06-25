#pragma once
#include "sys.c"

void clear_chars(char c)
{
	for (unsigned int p = 0; p < chram_size; p++)
	{
		chram[p] = c;
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

void box(unsigned int tx, unsigned int ty, unsigned int bx, unsigned int by, char c, char color)
{
	for (unsigned int x = tx; x <= bx; x++)
	{
		write_char(c, color, x, ty);
		write_char(c, color, x, by);
	}
	for (unsigned int y = ty + 1; y < by; y++)
	{
		write_char(c, color, tx, y);
		write_char(c, color, bx, y);
	}
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
