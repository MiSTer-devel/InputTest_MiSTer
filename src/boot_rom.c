
#include <stdio.h>
#include <string.h>
#include <stdlib.h>   // for abs()

extern unsigned char font[];

const unsigned int VGA_WIDTH = 160;
const unsigned int VGA_HEIGHT = 100;

unsigned char __at (0x6000) input0;
unsigned char __at (0x6001) input1;

unsigned char y = 0;
unsigned char hsync;
unsigned char hsync_last;
unsigned char vsync;
unsigned char vsync_last;
unsigned char input0_cache;
unsigned char input1_cache;

unsigned char color;
unsigned char cur_x=0, cur_y=0;

int putchar(int c) {
  unsigned char *p;
  unsigned char *dptr = (unsigned char*)(160*(8*cur_y) + 8*cur_x);
  char i, j;

  if(c < 32) {
    if(c == '\r') 
      cur_x=0;

    if(c == '\n') {
      cur_y++;
      cur_x=0;

      if(cur_y >= 12)
	cur_y = 0;
    }
    return;
  }

  if(c < 0) return;

  p = font+8*(unsigned char)(c-32);
  for(i=0;i<8;i++) {
    unsigned char l = *p++;
    for(j=0;j<8;j++) {
      *dptr++ = (l & 0x80)?color:0x00;
      l <<= 1;
    }
    dptr += (160-8);
  }

  cur_x++;
  if(cur_x >= 20) {
    cur_x = 0;
    cur_y++;

    if(cur_y >= 12)
      cur_y = 0;
  }
}

// draw a pixel
void put_pixel(unsigned int x, unsigned int y, unsigned char color) {
  *((unsigned int*)(VGA_WIDTH*y+x)) = color;
}

void cls(unsigned char color) {
  unsigned char i;
  unsigned int *p = (unsigned int*)0;
  for(i=0;i<VGA_HEIGHT;i++) {
    memset(p, color, VGA_WIDTH);
    p += VGA_WIDTH;
  }
}

// bresenham algorithm to draw a line
void draw_line(unsigned int x, unsigned int y, 
	       unsigned int x2, unsigned int y2, 
	       unsigned char color) {
  unsigned int longest, shortest, numerator, i;
  int dx1 = (x<x2)?1:-1;
  int dy1 = (y<y2)?1:-1;
  int dx2, dy2;
  
  longest = abs(x2 - x);
  shortest = abs(y2 - y);
  if(longest<shortest) {
    longest = abs(y2 - y);
    shortest = abs(x2 - x);
    dx2 = 0;            
    dy2 = dy1;
  } else {
    dx2 = dx1;
    dy2 = 0;
  }

  numerator = longest/2;
  for(i=0;i<=longest;i++) {
    put_pixel(x,y,color) ;
    if(numerator >= longest-shortest) {
      numerator += shortest ;
      numerator -= longest ;
      x += dx1;
      y += dy1;
    } else {
      numerator += shortest ;
      x += dx2;
      y += dy2;
    }
  }
}

char color = 0x66;

void main() {
	while(1) {

	// get inputs
		input0_cache = input0;
		hsync = input0_cache & 0x80;
		vsync = input0_cache & 0x40;

		if(hsync && !hsync_last){
			y++;
		}
		if(vsync && !vsync_last){
			y=0;

			cur_x = 0;
			cur_y = 0;
			color++;
			cls(~color);
    	puts(" << Z80 SoC >>\n");

			// process inputs
			input1_cache = input1;

		}
		hsync_last = hsync;
		vsync_last = vsync;
	}
}
