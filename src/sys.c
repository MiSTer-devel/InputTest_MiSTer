/*============================================================================
	MiSTer test harness OS - System interface functions

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

#pragma once

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

// Memory maps
unsigned char __at(0x6000) input0;
unsigned char __at(0x7000) joystick[24];
unsigned char __at(0x7100) analog[12];
unsigned char __at(0x7200) paddle[6];
unsigned char __at(0x7300) spinner[12];
unsigned char __at(0x7400) ps2_key[2];
unsigned char __at(0x7500) ps2_mouse[6];
unsigned char __at(0x8000) chram[2048];
unsigned char __at(0x8800) colram[2048];

// Character map
const unsigned char chram_cols = 64;
const unsigned char chram_rows = 32;
unsigned int chram_size;

// Macros
#define CHECK_BIT(var, pos) ((var) & (1 << (pos)))