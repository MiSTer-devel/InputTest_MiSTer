/*============================================================================
	Input Test - Custom system functions

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
#include "sys.c"

// Application states
#define STATE_START_INPUTTESTER 1
#define STATE_INPUTTESTER 2

#define STATE_START_INPUTTESTERADVANCED 3
#define STATE_INPUTTESTERADVANCED 4

#define STATE_START_INPUTTESTERANALOG 5
#define STATE_INPUTTESTERANALOG 6

#define STATE_START_BTNTEST 7
#define STATE_BTNTEST 8

#define STATE_START_MENU 9
#define STATE_MENU 10

#define STATE_FADEOUT 20
#define STATE_START_FADEIN 21
#define STATE_FADEIN 22

#define STATE_START_ATTRACT 30
#define STATE_ATTRACT 31

#define STATE_START_GAME_SNEK 40
#define STATE_GAME_SNEK 41

#define GET_TIMER ((unsigned short)timer[8] << 8) | (unsigned char)timer[0]

// DPAD tracker
bool input_left = 0;
bool input_left_last = 0;
bool input_right = 0;
bool input_right_last = 0;
bool input_up = 0;
bool input_up_last = 0;
bool input_down = 0;
bool input_down_last = 0;
bool input_start;
bool input_start_last = 0;
bool input_select;
bool input_select_last = 0;
bool input_a;
bool input_a_last = 0;
bool input_b;
bool input_b_last = 0;

// Track joypad 1 directions and start for menu control
void basic_input()
{
	input_up_last = input_up;
	input_down_last = input_down;
	input_left_last = input_left;
	input_right_last = input_right;
	input_start_last = input_start;
	input_select_last = input_select;
	input_a_last = input_a;
	input_b_last = input_b;
	input_up = CHECK_BIT(joystick[0], 3);
	input_down = CHECK_BIT(joystick[0], 2);
	input_left = CHECK_BIT(joystick[0], 1);
	input_right = CHECK_BIT(joystick[0], 0);
	input_start = CHECK_BIT(joystick[8], 3);
	input_select = CHECK_BIT(joystick[8], 2);
	input_a = CHECK_BIT(joystick[0], 4);
	input_b = CHECK_BIT(joystick[0], 5);
}

