/*============================================================================
	Input Test - Input test state handlers

	Author: Jim Gregory - https://github.com/JimmyStones/
	Version: 1.0
	Date: 2021-07-13

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
#include "fader.c"
#include "menu.c"

// Input tester variables
unsigned char joystick_last[12];
signed char ax_l_last[6];
signed char ay_l_last[6];
signed char ax_r_last[6];
signed char ay_r_last[6];
unsigned char px_last[6];
signed char sx_toggle_last[6];
signed char sx_last[6];
unsigned long sx_pos[6];

// Console constants
#define con_cursorfreq 30
// Console variables
unsigned char con_x;      // Console cursor X position
unsigned char con_y;      // Console cursor X position
unsigned char con_l = 2;  // Console left edge X
unsigned char con_t = 22; // Console top edge Y
unsigned char con_r = 37; // Console right edge X
unsigned char con_b = 36; // Console bottom edge Y
bool con_cursor;
unsigned char con_cursortimer = 1;

// Mode switcher variables
char modeswitchtimer_select = 0;
char modeswitchtimer_start = 0;

#define HISTORY_LENGTH 7
char history[HISTORY_LENGTH];

#define PAD_COUNT 2
#define BUTTON_COUNT 12

char pad_offset_x[PAD_COUNT] = {7, 7};
char pad_offset_y[PAD_COUNT] = {5, 16};
char button_symbol[BUTTON_COUNT][6] = {
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
char button_name[BUTTON_COUNT][12] = {
    "DPAD Right",
    "DPAD Left",
    "DPAD Down",
    "DPAD Up",
    "A",
    "B",
    "X",
    "Y",
    "L",
    "R",
    "Select",
    "Start"};
char button_x[BUTTON_COUNT] = {6, 2, 4, 4, 24, 22, 22, 20, 3, 23, 9, 13};
char button_y[BUTTON_COUNT] = {5, 5, 6, 4, 5, 6, 4, 5, 1, 1, 5, 5};
#define color_button_active 0xFF
#define color_button_inactive 0b11100100

char analog_offset_x[PAD_COUNT] = {1, 20};
char analog_offset_y[PAD_COUNT] = {5, 5};
signed char analog_x[PAD_COUNT];
signed char analog_y[PAD_COUNT];
#define analog_size 18
#define analog_ratio 15 // 256 / 17;

#define timestamp_clock_index 32
#define timestamp_index_1 8
#define timestamp_index_2 16
#define timestamp_index_3 24
bool last_timestamp_clock = 0;
// Button test constants
#define btntest_mode_select 0
#define btntest_mode_ready 1
#define btntest_mode_test 2
#define btntest_mode_results 3
#define btntest_timer_start 60    // vblanks to wait before first prompt
#define btntest_timer_interval 90 // vblanks to wait between prompts
#define btntest_timer_visible 30  // vblanks to wait between prompts
#define btntest_counter_max 5     // Number of button presses required
#define btntest_max 255
#define btntest_highlight_start 2
#define btntest_highlight_end 35

// Analog tester variables
char analog_pad = 0;

// Button test variables
char btntest_mode = 0;
char btntest_buttonbank = 0;
char btntest_buttonindex = 0;
char btntest_buttonlast = 1;
char btntest_timer = 0;
char btntest_counter = 0;
unsigned short btntest_presses[btntest_max];
unsigned short btntest_prompts[btntest_counter_max];
char btntest_pos = 0;
char btntest_buttondownlast = 0;
bool btntest_results_refresh = 0;
char btntest_results_offset = 0;
char btntest_highlight = 0;
char btntest_aftertimer = 0;

// Draw static elements for digital input test page
void page_inputtester_digital()
{
    page_frame(true, false);
    // Draw pads
    for (char j = 0; j < PAD_COUNT; j++)
    {
        write_stringf("JOY %d", 0xFF, pad_offset_x[j] - 5, pad_offset_y[j] + 5, j + 1);
        draw_pad(pad_offset_x[j], pad_offset_y[j]);
    }
}

// Draw static elements for analog input test page
void page_inputtester_analog()
{
    page_frame(true, false);
    // Draw analog grids
    char j = 0;
    write_string("ANALOG LEFT", 0xFF, analog_offset_x[j], analog_offset_y[j] - 1);
    draw_analog(analog_offset_x[j], analog_offset_y[j], analog_size, analog_size);
    write_string("X:", 0xFF, analog_offset_x[j] + 1, analog_offset_y[j] + analog_size + 1);
    write_string("Y:", 0xFF, analog_offset_x[j] + 10, analog_offset_y[j] + analog_size + 1);

    write_stringf("PAD %d", 0xFF, 18, analog_offset_y[j] - 1, analog_pad + 1);

    j = 1;
    write_string("ANALOG RIGHT", 0xFF, analog_offset_x[j] + analog_size - 11, analog_offset_y[j] - 1);
    draw_analog(analog_offset_x[j], analog_offset_y[j], analog_size, analog_size);
    write_string("X:", 0xFF, analog_offset_x[j] + 1, analog_offset_y[j] + analog_size + 1);
    write_string("Y:", 0xFF, analog_offset_x[j] + 10, analog_offset_y[j] + analog_size + 1);

    write_string("Cycle selected pad with A / B", 0x3F, 5, analog_offset_y[j] + analog_size + 2);
}

// Draw static elements for advanced input test page
void page_inputtester_advanced()
{
    page_frame(true, false);

    write_string("RLDUABXYLRsS", 0xFF, 7, 5);
    write_string("ALX", 0xFF, 21, 5);
    write_string("ALY", 0xFF, 25, 5);
    write_string("ARX", 0xFF, 30, 5);
    write_string("ARY", 0xFF, 34, 5);

    write_string("POS", 0xFF, 7, 13);
    write_string("SPD  POS", 0xFF, 18, 13);

    char label[5];
    for (unsigned char j = 0; j < 6; j++)
    {
        sprintf(label, "JOY%d", j + 1);
        write_string(label, 0xFF - (j * 2), 2, 6 + j);

        sprintf(label, "PAD%d", j + 1);
        write_string(label, 0xFF - (j * 2), 2, 14 + j);

        sprintf(label, "SPN%d", j + 1);
        write_string(label, 0xFF - (j * 2), 14, 14 + j);
    }
    write_string("CON", 0xFF, 2, 21);
}

// Draw static elements for button test page
void page_btntest(bool showMenuButton, bool showContinueButton)
{
    page_frame(showMenuButton, showContinueButton);
    write_string("BUTTON TEST", 0xAA, 15, 4);
}

void reset_inputstates()
{
    modeswitchtimer_select = 0;
    modeswitchtimer_start = 0;
    for (char i = 0; i < 12; i++)
    {
        joystick_last[i] = 1;
    }
    for (char i = 0; i < 6; i++)
    {
        ax_l_last[i] = 1;
        ay_l_last[i] = -1;
        ax_r_last[i] = 1;
        ay_r_last[i] = -1;
        px_last[i] = 1;
        sx_toggle_last[i] = 1;
        sx_last[i] = 1;
        sx_pos[i] = 0;
    }
}

// Initialise digital inputtester state and draw static elements
void start_inputtester_digital()
{
    state = STATE_INPUTTESTER;

    // Draw page
    page_inputtester_digital();

    // Reset last states for inputs
    reset_inputstates();
}

// Initialise analog inputtester state and draw static elements
void start_inputtester_analog()
{
    state = STATE_INPUTTESTERANALOG;

    // Draw page
    page_inputtester_analog();

    // Reset last states for inputs
    reset_inputstates();
}

// Initialise advanced inputtester state and draw static elements
void start_inputtester_advanced()
{
    state = STATE_INPUTTESTERADVANCED;

    // Draw page
    page_inputtester_advanced();

    // Reset console cursor
    con_x = con_l;
    con_y = con_t;

    // Reset last states for inputs
    reset_inputstates();
}

// Initialise button test state and draw static elements
void start_btntest()
{
    state = STATE_BTNTEST;
    btntest_mode = btntest_mode_select;
    btntest_buttonbank = 0;
    btntest_buttonindex = 0;
    btntest_buttonlast = 1;
    btntest_timer = 0;
    btntest_counter = 0;
    btntest_pos = 0;

    // Draw page
    page_btntest(true, false);
    write_string("Press the button you want to test", 0xFF, 3, 14);
    write_string("Remember to enable fast USB polling!", 0xEE, 2, 25);
}

// Rotate DPAD direction history and push new entry
void pushhistory(char new)
{
    for (char h = 1; h < HISTORY_LENGTH; h++)
    {
        history[h - 1] = history[h];
    }
    history[HISTORY_LENGTH - 1] = new;
}

// Track input history of P1 DPAD for secret codes!
void handle_codes()
{
    if (!input_up && input_up_last)
    {
        pushhistory(1);
    }
    if (!input_down && input_down_last)
    {
        pushhistory(2);
    }
    if (!input_left && input_left_last)
    {
        pushhistory(3);
    }
    if (!input_right && input_right_last)
    {
        pushhistory(4);
    }
    if (!input_a && input_a_last)
    {
        pushhistory(5);
    }
    // Check for SNEK code
    if (history[0] == 1 && history[1] == 1 && history[2] == 2 && history[3] == 2 && history[4] == 3 && history[5] == 4 && history[6] == 5)
    {
        nextstate = STATE_START_ATTRACT;
        pushhistory(0);
        start_fadeout();
        return;
    }
}

// Menu opening handler
bool modeswitcher()
{
    // Open menu if select is held
    if (input_select)
    {
        modeswitchtimer_select++;
        if (modeswitchtimer_select == menu_openholdtime)
        {
            modeswitchtimer_select = 0;
            start_menu();
            return 1;
        }
    }
    else
    {
        modeswitchtimer_select = 0;
    }
    return 0;
}

// Digital input tester state
void inputtester_digital()
{

    // Handle PS/2 inputs whenever possible to improve latency
    handle_ps2();

    // Handle secret code detection (joypad 1 directions)
    if (HBLANK_RISING)
    {
        basic_input();
        handle_codes();
    }

    // As soon as vsync is detected start drawing screen updates
    if (VBLANK_RISING)
    {
        // Handle test mode switch
        if (modeswitcher())
        {
            return;
        }

        // Draw control pad buttons
        for (char joy = 0; joy < PAD_COUNT; joy++)
        {
            char index = joy * 32;
            for (char button = 0; button < BUTTON_COUNT; button++)
            {
                char color = (button < 8 ? CHECK_BIT(joystick[index], button) : CHECK_BIT(joystick[index + 8], button - 8)) ? color_button_active : color_button_inactive;
                write_string(button_symbol[button], color, pad_offset_x[joy] + button_x[button], pad_offset_y[joy] + button_y[button]);
            }
        }
    }
}

// Analog input tester state
void inputtester_analog()
{

    // Handle PS/2 inputs whenever possible to improve latency
    handle_ps2();

    if (HBLANK_RISING)
    {
        basic_input();
        handle_codes();
        
        // Pad selection
        if (!input_a && input_a_last)
        {
            if (analog_pad == 5)
            {
                analog_pad = 0;
            }
            else
            {
                analog_pad += 1;
            }
            page_inputtester_analog();
        }
        if (!input_b && input_b_last)
        {
            if (analog_pad == 0)
            {
                analog_pad = 5;
            }
            else
            {
                analog_pad -= 1;
            }
            page_inputtester_analog();
        }
    }

    // As soon as vsync is detected start drawing screen updates
    if (VBLANK_RISING)
    {
        // Handle test mode switch
        if (modeswitcher())
        {
            return;
        }

        // Draw analog left point
        char side = 0;
        char mx = analog_offset_x[side] + (analog_size / 2);
        char my = analog_offset_y[side] + (analog_size / 2);

        // Reset previous color
        set_fgcolour(color_analog_grid, analog_x[side] + mx, analog_y[side] + my);

        signed char ax = analog_l[(analog_pad * 16)];
        signed char ay = analog_l[(analog_pad * 16) + 8];

        analog_x[side] = ax / analog_ratio;
        analog_y[side] = ay / analog_ratio;

        // Set new color
        set_fgcolour(0xFF, analog_x[side] + mx, analog_y[side] + my);

        write_stringfs("%4d", 0xFF, analog_offset_x[side] + 3, analog_offset_y[side] + analog_size + 1, ax);
        write_stringfs("%4d", 0xFF, analog_offset_x[side] + 12, analog_offset_y[side] + analog_size + 1, ay);

        // Draw analog right point
        side = 1;
        mx = analog_offset_x[side] + (analog_size / 2);
        my = analog_offset_y[side] + (analog_size / 2);

        // Reset previous color
        set_fgcolour(color_analog_grid, analog_x[side] + mx, analog_y[side] + my);

        ax = analog_r[(analog_pad * 16)];
        ay = analog_r[(analog_pad * 16) + 8];

        analog_x[side] = ax / analog_ratio;
        analog_y[side] = ay / analog_ratio;

        // Set new color
        set_fgcolour(0xFF, analog_x[side] + mx, analog_y[side] + my);

        write_stringfs("%4d", 0xFF, analog_offset_x[side] + 3, analog_offset_y[side] + analog_size + 1, ax);
        write_stringfs("%4d", 0xFF, analog_offset_x[side] + 12, analog_offset_y[side] + analog_size + 1, ay);
    }
}

// Advanced input tester state
void inputtester_advanced()
{

    // Handle PS/2 inputs whenever possible to improve latency
    handle_ps2();

    // Handle secret code detection (joypad 1 directions)
    if (HBLANK_RISING)
    {
        basic_input();
        handle_codes();
    }

    // As soon as vsync is detected start drawing screen updates
    if (VBLANK_RISING)
    {
        // Handle test mode switch
        if (modeswitcher())
        {
            return;
        }

        // Draw joystick inputs (only update each byte if value has changed)
        for (char inputindex = 0; inputindex < 6; inputindex++)
        {
            char m = 0b00000001;
            char x = 6;
            char y = 6 + inputindex;
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
                    char bytes = (b == 0 ? 8 : 4);
                    for (char i = 0; i < bytes; i++)
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

            char stra[10];
            // Draw analog left inputs (only update if value has changed)
            signed char ax_l = analog_l[(inputindex * 16)];
            signed char ay_l = analog_l[(inputindex * 16) + 8];
            if (ax_l != ax_l_last[inputindex] || ay_l != ay_l_last[inputindex])
            {
                sprintf(stra, "%4d%4d", ax_l, ay_l);
                write_string(stra, 0xFF, 20, 6 + inputindex);
            }
            ax_l_last[inputindex] = ax_l;
            ay_l_last[inputindex] = ay_l;

            // Draw analog right inputs (only update if value has changed)
            signed char ax_r = analog_r[(inputindex * 16)];
            signed char ay_r = analog_r[(inputindex * 16) + 8];
            if (ax_r != ax_r_last[inputindex] || ay_r != ay_r_last[inputindex])
            {
                sprintf(stra, "%4d%4d", ax_r, ay_r);
                write_string(stra, 0xFF, 29, 6 + inputindex);
            }
            ax_r_last[inputindex] = ax_r;
            ay_r_last[inputindex] = ay_r;

            // Draw paddle inputs (only update if value has changed)
            unsigned char px = paddle[(inputindex * 8)];
            if (px != px_last[inputindex])
            {
                char strp[5];
                sprintf(strp, "%4d", px);
                write_string(strp, 0xFF, 6, 14 + inputindex);
            }
            px_last[inputindex] = px;

            // Draw spinner inputs (only update when update clock changes)
            bool sx_toggle = CHECK_BIT(spinner[(inputindex * 16) + 8], 0);
            signed char sx = spinner[(inputindex * 16)];
            if (sx_toggle != sx_toggle_last[inputindex])
            {
                sx_pos[inputindex] += sx;
                write_stringf("%4d", 0xFF, 22, 14 + inputindex, sx_pos[inputindex]);
            }
            else
            {
                if (sx == 1 || sx == -1)
                {
                    sx = 0;
                }
            }
            if (sx_last[inputindex] != sx)
            {
                write_stringfs("%4d", 0xFF, 17, 14 + inputindex, sx);
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

void btntest_starttest()
{
    btntest_mode = btntest_mode_test;
    page_btntest(false, false); // reset screen

    // Prepare variables
    btntest_timer = btntest_timer_start;

    // Reset hardware timer
    timer[0] = 0;

    write_string("Press here", 0xDD, 14, 14);
    write_char(19, 0xDD, 19, 15);
    write_string("---\x3\x3\x3\x2\x2\x2\x1\x1\x1\xA6\xA6\xA6\x7f\x7f\x7f\xA6\xA6\xA6\x1\x1\x1\x2\x2\x2\x3\x3\x3---", 0xDD, 3, 16);
}

// Button test - button select state
void btntest_select()
{
    if (HBLANK_RISING)
    {

        // If any of 1st 8 buttons is pressed
        if (joystick[0] != 0)
        {
            // Find which button
            for (char b = 0; b < 8; b++)
            {
                if (CHECK_BIT(joystick[0], b))
                {
                    btntest_buttonindex = b;
                    break;
                }
            }
            btntest_mode = btntest_mode_ready;
            page_btntest(false, false); // reset screen
            write_string("Hit the button at each prompt", 0b11111000, 5, 14);
            write_string("Selected button is: ", 0xFF, 6, 16);
            char i = btntest_buttonindex;
            write_string(button_name[i], 0b00000111, 26, 16);
            write_string("Press again to start test", 0b00111000, 7, 18);
            btntest_timer = 10;
            return;
        }
    }
    if (VBLANK_RISING)
    {
        // Check inputs for select hold to enter menu
        basic_input();
        modeswitcher();
    }
}

// Button test - ready state
void btntest_ready()
{
    if (HBLANK_RISING)
    {
        char button = CHECK_BIT(joystick[0], btntest_buttonindex);
        if (btntest_timer > 0)
        {
            if (joystick[0] == 0)
            {
                btntest_timer--;
            }
        }
        else
        {
            // Check for selected button to be pressed again
            if (!button && btntest_buttonlast)
            {
                btntest_starttest();
            }
        }
        btntest_buttonlast = button;
    }
}

// Button test - begin test state
void btntest_test()
{

    // Track button presses
    bool down = CHECK_BIT(joystick[0], btntest_buttonindex);
    if (down && !btntest_buttondownlast)
    {
        btntest_presses[btntest_pos] = GET_TIMER;
        btntest_pos++;
    }
    btntest_buttondownlast = down;

    if (VBLANK_RISING)
    {
        // Count down to next prompt on vblanks
        btntest_timer--;

        set_bgcolour(0x0, btntest_highlight, 16);
        if (btntest_timer == 30)
        {
            btntest_highlight = btntest_highlight_start;
        }
        if (btntest_highlight > 0)
        {
            if ((btntest_timer % 2) == 0)
            {
                btntest_highlight++;
                if (btntest_highlight > btntest_highlight_end)
                {
                    btntest_highlight = 0;
                }
            }
        }
        if (btntest_highlight > 0)
        {
            set_bgcolour(0xFF, btntest_highlight, 16);
        }

        if (btntest_aftertimer > 0)
        {
            btntest_aftertimer--;
            if (btntest_aftertimer == 0)
            {
                // End test here
                if (btntest_counter == btntest_counter_max)
                {
                    btntest_mode = btntest_mode_results;
                    btntest_results_refresh = true;
                    page_btntest(true, true); // reset screen
                    return;
                }
            }
        }

        if (btntest_timer == 0)
        {
            // Capture timer
            btntest_prompts[btntest_counter] = GET_TIMER;

            // Display test counter
            write_stringf("%2d", 0xFF, 18, 6, btntest_counter + 1);

            btntest_timer = btntest_timer_interval;
            btntest_aftertimer = 33;
            btntest_counter++;
        }
    }
}

unsigned short abs(signed short value)
{
    if (value < 0)
    {
        value = value * -1;
    }
    return value;
}
// Button test - results view
void btntest_results()
{

    if (btntest_results_refresh)
    {
        write_string("Prompts", 0xFF, 2, 6);
        //        write_string("-------", 0xFF, 2, 7);
        write_string("Presses", 0xFF, 11, 6);
        //        write_string("-------", 0xFF, 11, 7);

        char y = 7;
        char press = 0;
        char prompt = 0;
        char done = false;

        unsigned short prompt_last = 0;
        unsigned short press_last = 0;

        while (!done)
        {

            unsigned short prompt_time = prompt < btntest_counter_max ? btntest_prompts[prompt] : 65535;
            unsigned short press_time = press < btntest_pos ? btntest_presses[press] : 65535;

            if (prompt_time < press_time)
            {
                write_stringf_ushort("%6dms", 0xFF, 2, y, btntest_prompts[prompt]);
                y++;
                prompt++;
                prompt_last = prompt_time;
            }
            else if (press_time < prompt_time)
            {
                write_stringf_ushort("%6dms", 0xFF, 11, y, btntest_presses[press]);

                // Is this early or late or just nowhere near?!
                unsigned short prompt_next = prompt + 1 <= btntest_counter_max ? btntest_prompts[prompt] : 65535;

                unsigned short diff_last = abs(press_time - prompt_last);
                unsigned short diff_next = abs(prompt_next - press_time);

                if (diff_next < 500)
                {
                    write_stringf_short("%3dms before", 0b11111000, 20, y, diff_next);
                }
                else if (diff_last <= 500)
                {
                    write_stringf_short("%3dms after", 0b00111111, 20, y, diff_last);
                }
                else
                {
                    write_stringf_short("????", 0b00000111, 20, y, diff_next);
                }
                y++;
                press++;
            }
            else
            {
                done = true;
            }
        }

        btntest_results_refresh = 0;
    }

    if (VBLANK_RISING)
    {

        // Check inputs for select hold to enter menu
        basic_input();
        modeswitcher();

        if (input_start && !input_start_last)
        {
            start_btntest();
        }
    }
}

// Button test - mode handler
void btntest()
{

    switch (btntest_mode)
    {
    case btntest_mode_select:
        btntest_select();
        break;
    case btntest_mode_ready:
        btntest_ready();
        break;
    case btntest_mode_test:
        btntest_test();
        break;
    case btntest_mode_results:
        btntest_results();
        break;
    }
}
