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
const int input_fire1 = 4;
const int input_fire2 = 5;
const int input_start_1 = 6;
const int input_start_2 = 7;
const int input_coin_1 = 8;
const int input_coin_2 = 9;
const int input_coin_3 = 10;
const int input_pause = 11;

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

vluint64_t main_time = 0;	// Current simulation time.
double sc_time_stamp() {	// Called by $time in Verilog.
	return main_time;
}

SimClock clk_sys(1);

void resetSim() {
	main_time = 0;
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

		// Set system clock in core
		top->clk_sys = clk_sys.clk;

		// Simulate both edges of system clock
		if (clk_sys.clk != clk_sys.old) {
			if (clk_sys.clk) { bus.BeforeEval(); }
			top->eval();
			if (clk_sys.clk) { bus.AfterEval(); }
		}

		// Output pixels on rising edge of pixel clock
		if (clk_sys.IsRising() && top->emu__DOT__ce_pix ) {
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

char ps2_scancode = 0;
char ps2_toggle = 0;
char ps2_timer = 0;


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

	// Set up input module
	input.Initialise();
#ifdef WIN32
	input.SetMapping(input_up, DIK_UP);
	input.SetMapping(input_right, DIK_RIGHT);
	input.SetMapping(input_down, DIK_DOWN);
	input.SetMapping(input_left, DIK_LEFT);
	input.SetMapping(input_fire1, DIK_SPACE);
	input.SetMapping(input_start_1, DIK_1);
	input.SetMapping(input_start_2, DIK_2);
	input.SetMapping(input_coin_1, DIK_5);
	input.SetMapping(input_coin_2, DIK_6);
	input.SetMapping(input_coin_3, DIK_7);
	input.SetMapping(input_pause, DIK_P);
#else
	input.SetMapping(input_up, SDL_SCANCODE_UP);
	input.SetMapping(input_right, SDL_SCANCODE_RIGHT);
	input.SetMapping(input_down, SDL_SCANCODE_DOWN);
	input.SetMapping(input_left, SDL_SCANCODE_LEFT);
	input.SetMapping(input_fire1, SDL_SCANCODE_SPACE);
	input.SetMapping(input_start_1, SDL_SCANCODE_1);
	input.SetMapping(input_start_2, SDL_SCANCODE_2);
	input.SetMapping(input_coin_1, SDL_SCANCODE_3);
	input.SetMapping(input_coin_2, SDL_SCANCODE_4);
	input.SetMapping(input_coin_3, SDL_SCANCODE_5);
	input.SetMapping(input_pause, SDL_SCANCODE_P);
#endif
	// Setup video output
	if (video.Initialise(windowTitle) == 1) { return 1; }

	//bus.QueueDownload("../src/os.bin", 0);
	//bus.QueueDownload("../MiSTer.pf", 1);


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
		mem_edit_2.DrawContents(top->emu__DOT__system__DOT__wkram__DOT__mem, 16384, 0);
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

		top->joystick_analog_0 += 1;
		top->joystick_analog_0 -= 256;

		top->joystick_analog_1 -= 1;
		top->joystick_analog_1 += 256;

		top->paddle_0 += 1;
		top->paddle_1 -= 1;

		top->spinner_0 += 1;
		top->spinner_1 -= 1;


		if (video.frameChanged) {
			top->ps2_key = 0;

			ps2_timer++;
			if (ps2_timer == 2) {
				ps2_scancode =0x16;
				ps2_toggle = !ps2_toggle;

				ps2_timer = 0;
			}
			if (ps2_toggle) {
				top->ps2_key &= ~(1UL << 10);
			}
			else {
				top->ps2_key |= (1UL << 10);
			}

			for (char b = 0; b < 8; b++) {
				char bit = (ps2_scancode >> b) & 1U;
				if (bit == 1) {
					top->ps2_key |= (1UL << b);
				}
			}
		}
		video.frameChanged = 0;

		if (!bus.HasQueue() && input.inputs[input_pause]) {
			bus.QueueDownload("../src/os.bin", 0);
		}

		top->ps2_mouse += 1;
		top->ps2_mouse_ext -= 1;

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
