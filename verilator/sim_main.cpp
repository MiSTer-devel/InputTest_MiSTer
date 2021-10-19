#include <verilated.h>
#include "Vemu.h"

#include "imgui.h"
#ifndef _MSC_VER
#include <stdio.h>
#include <SDL.h>
#include <SDL_opengl.h>
#else
#define WIN32
#include <dinput.h>
#endif
#include <chrono>

#include "sim_console.h"
#include "sim_bus.h"
#include "sim_video.h"
#include "sim_input.h"
#include "sim_clock.h"

#include "../imgui/imgui_memory_editor.h"
#include "../imgui/ImGuiFileDialog.h"

// Debug GUI 
// ---------
const char* windowTitle = "Verilator Sim: InputTest";
bool showDebugWindow = true;
const char* debugWindowTitle = "Virtual Dev Board v1.0";
DebugConsole console;
MemoryEditor mem_edit_1;
MemoryEditor mem_edit_2;
MemoryEditor mem_edit_3;
// HPS emulator
// ------------
SimBus bus(console);

// Input handling
// --------------
SimInput input(12);
const int input_right = 0;
const int input_left = 1;
const int input_down = 2;
const int input_up = 3;
const int input_a = 4;
const int input_b = 5;
const int input_x = 6;
const int input_y = 7;
const int input_l = 8;
const int input_r = 9;
const int input_select = 10;
const int input_start = 11;

// Video
// -----
#define VGA_WIDTH 320
#define VGA_HEIGHT 240
#define VGA_ROTATE 0  // 90 degrees anti-clockwise
SimVideo video(VGA_WIDTH, VGA_HEIGHT, VGA_ROTATE);

// Simulation control
// ------------------
int initialReset = 48;
bool run_enable = 1;
int batchSize = 150000;
bool single_step = 0;
bool multi_step = 0;
int multi_step_amount = 1024;

// Verilog module
// --------------
Vemu* top = NULL;

vluint64_t main_time = 0;		// Current simulation time.
vluint32_t timestamp = 0;	    // Simulated Unix timestamp.
vluint16_t timestamp_ticksperms = 24000; // Number of simulation ticks per simulated millisecond
vluint16_t timestamp_ticks = 0; // Ticks left until next ms
unsigned short timestamp_updatefreq = 5000; // Only update sim every 5 seconds 
unsigned short timestamp_update = 0;	    // Ms to next update.
bool timestamp_clock = 1;		// Timestamp update clock

double sc_time_stamp() {	    // Called by $time in Verilog.
	return main_time;
}

SimClock clk_sys(1);




long GetTime() {
	return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
}

void resetSim() {
	main_time = 0;
	timestamp = GetTime();
	top->reset = 1;
	clk_sys.Reset();
}

int verilate() {

	if (!Verilated::gotFinish()) {

		// Assert reset during startup
		if (main_time < initialReset) { top->reset = 1; }
		// Deassert reset after startup
		if (main_time == initialReset) { top->reset = 0; }

		// Clock dividers
		clk_sys.Tick();

		// Increment timestamp
		timestamp_ticks ++;
		if (timestamp_ticks >= timestamp_ticksperms) {
			timestamp_ticks -= timestamp_ticksperms;
			timestamp++;

			top->timestamp = timestamp;
			timestamp_clock = !timestamp_clock;

			if (timestamp_clock) {
				timestamp_update--;
				if (timestamp_update <= 0) {
					top->timestamp |= ((uint64_t)1) << 32;
					timestamp_update = timestamp_updatefreq;
				}
			}
		}

		// Set system clock in core
		top->clk_sys = clk_sys.clk;

		// Simulate both edges of system clock
		if (clk_sys.clk != clk_sys.old) {
			if (clk_sys.clk) {
				input.BeforeEval();
				bus.BeforeEval();
			}
			top->eval();
			if (clk_sys.clk) { bus.AfterEval(); }
		}

		// Output pixels on rising edge of pixel clock
		if (clk_sys.IsRising() && top->emu__DOT__ce_pix) {
			uint32_t colour = 0xFF000000 | top->VGA_B << 16 | top->VGA_G << 8 | top->VGA_R;
			video.Clock(top->VGA_HB, top->VGA_VB, top->VGA_HS, top->VGA_VS, colour);
		}

		main_time++;

		return 1;
	}
	// Stop verilating and cleanup
	top->final();
	delete top;
	exit(0);
	return 0;
}

unsigned char mouse_clock = 0;
unsigned char mouse_buttons= 0;
unsigned char mouse_x = 0;
unsigned char mouse_y = 0;

char spinner_toggle = 0;

int main(int argc, char** argv, char** env) {

	// Create core and initialise
	top = new Vemu();
	Verilated::commandArgs(argc, argv);

#ifdef WIN32
	// Attach debug console to the verilated code
	Verilated::setDebug(console);
#endif

	// Attach bus
	bus.ioctl_addr = &top->ioctl_addr;
	bus.ioctl_index = &top->ioctl_index;
	bus.ioctl_wait = &top->ioctl_wait;
	bus.ioctl_download = &top->ioctl_download;
	//bus.ioctl_upload = &top->ioctl_upload;
	bus.ioctl_wr = &top->ioctl_wr;
	bus.ioctl_dout = &top->ioctl_dout;
	//bus.ioctl_din = &top->ioctl_din;
	input.ps2_key = &top->ps2_key;

	// Set up input module
	input.Initialise();
#ifdef WIN32
	input.SetMapping(input_up, DIK_UP);
	input.SetMapping(input_right, DIK_RIGHT);
	input.SetMapping(input_down, DIK_DOWN);
	input.SetMapping(input_left, DIK_LEFT);
	input.SetMapping(input_a, DIK_Z); // A
	input.SetMapping(input_b, DIK_X); // B
	input.SetMapping(input_x, DIK_A); // X
	input.SetMapping(input_y, DIK_S); // Y
	input.SetMapping(input_l, DIK_Q); // L
	input.SetMapping(input_r, DIK_W); // R
	input.SetMapping(input_select, DIK_1); // Select
	input.SetMapping(input_start, DIK_2); // Start

#else
	input.SetMapping(input_up, SDL_SCANCODE_UP);
	input.SetMapping(input_right, SDL_SCANCODE_RIGHT);
	input.SetMapping(input_down, SDL_SCANCODE_DOWN);
	input.SetMapping(input_left, SDL_SCANCODE_LEFT);
	input.SetMapping(input_a, SDL_SCANCODE_A);
	input.SetMapping(input_b, SDL_SCANCODE_B);
	input.SetMapping(input_x, SDL_SCANCODE_X);
	input.SetMapping(input_y, SDL_SCANCODE_Y);
	input.SetMapping(input_l, SDL_SCANCODE_L);
	input.SetMapping(input_r, SDL_SCANCODE_R);
	input.SetMapping(input_select, SDL_SCANCODE_1);
	input.SetMapping(input_start, SDL_SCANCODE_2);
#endif
	// Setup video output
	if (video.Initialise(windowTitle) == 1) { return 1; }

	// Initial reset
	resetSim();

#ifdef WIN32
	MSG msg;
	ZeroMemory(&msg, sizeof(msg));
	while (msg.message != WM_QUIT)
	{
		if (PeekMessage(&msg, NULL, 0U, 0U, PM_REMOVE))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
			continue;
		}
#else
	bool done = false;
	while (!done)
	{
		SDL_Event event;
		while (SDL_PollEvent(&event))
		{
			ImGui_ImplSDL2_ProcessEvent(&event);
			if (event.type == SDL_QUIT)
				done = true;
		}
#endif
		video.StartFrame();

		input.Read();


		// Draw GUI
		// --------
		ImGui::NewFrame();

		console.Draw("Debug Log", &showDebugWindow);
		ImGui::Begin(debugWindowTitle);
		ImGui::SetWindowPos(debugWindowTitle, ImVec2(580, 10), ImGuiCond_Once);
		ImGui::SetWindowSize(debugWindowTitle, ImVec2(1000, 1000), ImGuiCond_Once);

		if (ImGui::Button("RESET")) { resetSim(); } ImGui::SameLine();
		if (ImGui::Button("START")) { run_enable = 1; } ImGui::SameLine();
		if (ImGui::Button("STOP")) { run_enable = 0; } ImGui::SameLine();
		if (ImGui::Button("LOAD"))
			ImGuiFileDialog::Instance()->OpenDialog("ChooseFileDlgKey", "Choose File", ".bin", ".");
		ImGui::Checkbox("RUN", &run_enable);
		ImGui::SliderInt("Batch size", &batchSize, 1, 250000);

		if (single_step == 1) { single_step = 0; }
		if (ImGui::Button("Single Step")) { run_enable = 0; single_step = 1; }
		ImGui::SameLine();
		if (multi_step == 1) { multi_step = 0; }
		if (ImGui::Button("Multi Step")) { run_enable = 0; multi_step = 1; }
		ImGui::SameLine();

		ImGui::SliderInt("Step amount", &multi_step_amount, 8, 1024);

		ImGui::SliderInt("Rotate", &video.output_rotate, -1, 1); ImGui::SameLine();
		ImGui::Checkbox("Flip V", &video.output_vflip);

		ImGui::Text("main_time: %d frame_count: %d sim FPS: %f", main_time, video.count_frame, video.stats_fps);
		ImGui::Text("timestamp: %d actual ms: %d frame_ms: %d ", timestamp, timestamp/1000, video.count_frame * 1000);
		ImGui::Text("minx: %d maxx: %d miny: %d maxy: %d", video.stats_xMin, video.stats_xMax, video.stats_yMin, video.stats_yMax);

		// Draw VGA output
		float m = 2.0;
		ImGui::Image(video.texture_id, ImVec2(video.output_width * m, video.output_height * m));
		ImGui::End();

		/*ImGui::Begin("PGROM Editor");
		mem_edit_1.DrawContents(top->emu__DOT__system__DOT__pgrom__DOT__mem, 16384, 0);
		ImGui::End();
		ImGui::Begin("CHROM Editor");
		mem_edit_1.DrawContents(top->emu__DOT__system__DOT__chrom__DOT__mem, 2048, 0);
		ImGui::End();*/
		ImGui::Begin("WKRAM Editor");
		mem_edit_2.DrawContents(&top->emu__DOT__system__DOT__wkram__DOT__mem, 16384, 0);
		ImGui::End();
		//ImGui::Begin("CHRAM Editor");
		//mem_edit_3.DrawContents(top->emu__DOT__system__DOT__chram__DOT__mem, 2048, 0);
		//ImGui::End();
		//ImGui::Begin("COLRAM Editor");
		//mem_edit_3.DrawContents(top->emu__DOT__system__DOT__colram__DOT__mem, 2048, 0);
		//ImGui::End();

		// File Dialog to load rom 
		if (ImGuiFileDialog::Instance()->Display("ChooseFileDlgKey"))
		{
			// action if OK
			if (ImGuiFileDialog::Instance()->IsOk())
			{
				std::string filePathName = ImGuiFileDialog::Instance()->GetFilePathName();
				std::string filePath = ImGuiFileDialog::Instance()->GetCurrentPath();
				// action
				bus.QueueDownload(filePathName, 0, true);
			}

			// close
			ImGuiFileDialog::Instance()->Close();
		}

		ImGui::Begin("CPU Registers");
		ImGui::Spacing();
		ImGui::Text("PC      0x%04X", top->emu__DOT__system__DOT__T80x__DOT__i_tv80_core__DOT__PC);
		ImGui::Text("ACC     0x%04X", top->emu__DOT__system__DOT__T80x__DOT__i_tv80_core__DOT__ACC);
		ImGui::End();

		video.UpdateTexture();

		// Pass inputs to sim
		top->joystick_0 = 0;
		for (int i = 0; i < input.inputCount; i++)
		{
			if (input.inputs[i]) { top->joystick_0 |= (1 << i); }
		}
		top->joystick_1 = top->joystick_0;

		top->joystick_l_analog_0 += 1;
		top->joystick_l_analog_0 -= 256;
		top->joystick_r_analog_0 += 1;
		top->joystick_r_analog_0 -= 256;

		top->joystick_l_analog_1 += 1;
		top->joystick_l_analog_1 -= 256;
		top->joystick_r_analog_1 += 1;
		top->joystick_r_analog_1 -= 256;

		top->joystick_l_analog_2 = 40;
		top->joystick_l_analog_2 += 1024;
		top->joystick_r_analog_2 = 50;
		top->joystick_r_analog_2 += 1024;

		top->joystick_l_analog_3 = 60;
		top->joystick_l_analog_3 += 2048;
		top->joystick_r_analog_3 = 70;
		top->joystick_r_analog_3 += 2048;

		top->joystick_l_analog_4 = 80;
		top->joystick_l_analog_4 += 4096;
		top->joystick_r_analog_4 = 90;
		top->joystick_r_analog_4 += 4096;

		top->joystick_l_analog_5 = 100;
		top->joystick_l_analog_5 += 8192;
		top->joystick_r_analog_5 = 110;
		top->joystick_r_analog_5 += 8192;

		top->paddle_0 += 1;

		if (input.inputs[0] || input.inputs[1]) {
			spinner_toggle = !spinner_toggle;
			top->spinner_0 = (input.inputs[0]) ? 4 : -4;
			for (char b = 8; b < 16; b++) {
				top->spinner_0 &= ~(1UL << b);
			}
			if (spinner_toggle) { top->spinner_0 |= 1UL << 8; }
		}

		mouse_buttons += 1;
		mouse_x += 1;
		mouse_y -= 1;
		unsigned long mouse_temp = mouse_buttons;
		mouse_temp += (mouse_x << 8);
		mouse_temp += (mouse_y << 16);
		if (mouse_clock) { mouse_temp |= (1UL << 24); }

		mouse_clock  = !mouse_clock;

		top->ps2_mouse = mouse_temp;
		//top->ps2_mouse_ext -= 1;

		// Run simulation
		if (run_enable) {
			for (int step = 0; step < batchSize; step++) { verilate(); }
		}
		else {
			if (single_step) { verilate(); }
			if (multi_step) {
				for (int step = 0; step < multi_step_amount; step++) { verilate(); }
			}
		}
	}


	// Clean up before exit
	// --------------------

	video.CleanUp();
	input.CleanUp();

	return 0;
}
