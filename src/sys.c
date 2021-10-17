/*============================================================================
	Aznable OS - System interface functions

	Author: Jim Gregory - https://github.com/JimmyStones/
	Version: 1.0
	Date: 2021-07-12

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

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

// Memory mapped IO
// - Inputs
unsigned char __at(0x6000) input0;
unsigned char __at(0x7000) joystick[24];
unsigned char __at(0x7100) analog_l[12];
unsigned char __at(0x7200) analog_r[12];
unsigned char __at(0x7300) paddle[6];
unsigned char __at(0x7400) spinner[12];
unsigned char __at(0x7500) ps2_key[2];
unsigned char __at(0x7600) ps2_mouse[6];
unsigned char __at(0x7700) timestamp[5];
unsigned char __at(0x7800) timer[2];
// - Graphics RAM
unsigned char __at(0x8000) chram[2048];
unsigned char __at(0x8800) fgcolram[2048];
unsigned char __at(0x9000) bgcolram[2048];

// Character map
const unsigned char chram_cols = 64;
const unsigned char chram_rows = 32;
unsigned int chram_size;

// Hardware inputs
bool hsync;
bool hsync_last;
bool vsync;
bool vsync_last;
bool hblank;
bool hblank_last;
bool vblank;
bool vblank_last;

// Macros
#define CHECK_BIT(var, pos) ((var) & (1 << (pos)))
#define SET_BIT(var,pos) ((var) |= (1 << (pos)))
#define CLEAR_BIT(var,pos) ((var) &= ~(1 << (pos)))
#define VBLANK_RISING (vblank && !vblank_last)
#define VSYNC_RISING (vsync && !vsync_last)
#define HBLANK_RISING (hblank && !hblank_last)
#define HSYNC_RISING (hsync && !hsync_last)

// Application state
char state = 0;
char nextstate = 0;
