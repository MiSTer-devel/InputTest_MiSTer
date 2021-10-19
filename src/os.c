/*============================================================================
	MiSTer test harness OS - Main application

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

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#include "sys.c"
#include "sys_custom.c"
#include "ps2.c"
#include "ui.c"
#include "ui_custom.c"
#include "menu.c"
#include "inputtester.c"
#include "snek.c"
#include "fader.c"

// Main entry and state machine
void main()
{
	chram_size = chram_cols * chram_rows;
	while (1)
	{
		hsync = input0 & 0x80;
		vsync = input0 & 0x40;
		hblank = input0 & 0x20;
		vblank = input0 & 0x10;
		switch (state)
		{
		case STATE_START_INPUTTESTER:
			start_inputtester_digital();
			break;
		case STATE_INPUTTESTER:
			inputtester_digital();
			break;

		case STATE_START_INPUTTESTERADVANCED:
			start_inputtester_advanced();
			break;
		case STATE_INPUTTESTERADVANCED:
			inputtester_advanced();
			break;

		case STATE_START_INPUTTESTERANALOG:
			start_inputtester_analog();
			break;
		case STATE_INPUTTESTERANALOG:
			inputtester_analog();
			break;

		case STATE_START_BTNTEST:
			start_btntest();
			break;
		case STATE_BTNTEST:
			btntest();
			break;

		case STATE_START_MENU:
			start_menu();
			break;
		case STATE_MENU:
			menu();
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
			snek_attract();
			break;

		case STATE_START_GAME_SNEK:
			start_gameplay();
			break;
		case STATE_GAME_SNEK:
			snek_gameplay();
			break;

		default:
			// Start default state
			//start_inputtester_digital();
			start_inputtester_advanced();
			//start_inputtester_analog();
			//start_btntest();
			break;
		}
		hsync_last = hsync;
		vsync_last = vsync;
		hblank_last = hblank;
		vblank_last = vblank;
	}
}
