/*============================================================================
	Aznable (custom 8-bit computer system) - Deikun (music engine)

	Author: Jim Gregory - https://github.com/JimmyStones/
	Version: 0.1
	Date: 2021-11-20

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

`timescale 1ps / 1ps

module music #(
	parameter ROM_WIDTH = 17
)(
	input				clk,
	input				ce_2,
	input				reset,
	
	input		[1:0]	addr,
	input		[7:0]	data_in,
	output		[7:0]	data_out,
	input				write,

	input		[7:0]	musicrom_data_out,
	output reg [ROM_WIDTH-1:0]	musicrom_addr,
	output		[9:0]	audio_out
	);

	// Music system state machine (ym player)
	// - Currently recognises YM5/YM6 formats
	// - Handles interleaved/non-interleaved data
	// - Ignores DigiDrum samples completely
	// - Variable play rate (50/60hz)
	// - Recognises loop point

	reg  [7:0] regarray[3:0];
	// Music control registers
	// 0 - 1 = play, 2 = loop, 3 = stop
	// 1-3 - Start address of music to play in ROM

	assign data_out = { 6'b0, ymp_loop, ymp_playing };

	// YM2149 audio_out generator
	reg  [7:0] snd_data_in;
	reg        snd_wr;

	jt49 jt49_music(
		.clk(clk),
		.clk_en(ce_2),
		.rst_n(~(reset || ymp_state == YM_INIT || ymp_state == YM_STOPPED )), // Hold YM2149 in reset while player state is initialising or stopped
		.addr(ymp_register),
		.din(snd_data_in),
		.dout(),
		.sound(audio_out),
		.sample(),
		.A(),
		.B(),
		.C(),
		.sel(1'b1),
		.cs_n(1'b0),
		.wr_n(~snd_wr),
		.IOA_in(),
		.IOA_out(),
		.IOB_in(),
		.IOB_out()
	);
	
	localparam YM_INIT = 0;
	localparam YM_WAIT = 1;
	localparam YM_GETMODE = 2;
	localparam YM_GETLENGTH_0 = 3;
	localparam YM_GETLENGTH_1 = 4;
	localparam YM_GETFREQUENCY = 5;
	localparam YM_GETLOOP_0 = 6;
	localparam YM_GETLOOP_1 = 7;
	localparam YM_SKIPSTRINGS = 8;
	localparam YM_STOPPED = 9;
	
	localparam YM_WAITFORFRAME = 12;
	localparam YM_GETREGISTER = 13;
	localparam YM_SETREGISTER = 14;
	localparam YM_NEXTREGISTER = 15;

	localparam YM_REGCOUNT = 16;

	reg  [ROM_WIDTH-1:0] ymp_trackoffset;
	reg			ymp_playing;
	reg			ymp_loop;
	
	reg   [3:0] ymp_state;
	reg   [3:0] ymp_state_next;
	reg  [ROM_WIDTH-1:0] ymp_frame;
	reg   [3:0] ymp_register;
	reg			ymp_interleave;
	reg			ymp_is_50hz;
	reg   [2:0] ymp_skipstringindex = 3'b0;
	reg  [ROM_WIDTH-1:0] ymp_firstframe;

	reg  [ROM_WIDTH-1:0] ymp_length; 
	reg  [ROM_WIDTH-1:0] ymp_looppoint;
	reg  [(YM_REGCOUNT * 8)-1:0] ymp_registermask = {
			8'b00000000,
			8'b00000000,
			8'b00001111,
			8'b11111111,
			8'b11111111,
			8'b00011111,
			8'b00011111,
			8'b00011111,
			8'b11111111,
			8'b00011111,
			8'b00001111,
			8'b11111111,
			8'b00001111,
			8'b11111111,
			8'b00001111,
			8'b11111111
	};

	reg [19:0] frame_timer_50;
	reg [19:0] frame_timer_60;
	localparam [19:0] frame_timer_max_50 = 20'd480000;
	localparam [19:0] frame_timer_max_60 = 20'd400000;

	reg frame_ready;

	//`define YM_DEBUG

	always @(posedge clk)
	begin

		// Frame timers
		frame_timer_50 <= frame_timer_50 + 20'd1;
		if(frame_timer_50 == frame_timer_max_50) 
		begin
			frame_timer_50 <= 20'd0;
			if(ymp_is_50hz) frame_ready <= 1'b1;
		end
		frame_timer_60 <= frame_timer_60 + 20'd1;
		if(frame_timer_60 == frame_timer_max_60)
		begin
			frame_timer_60 <= 20'd0;
			if(!ymp_is_50hz) frame_ready <= 1'b1;
		end

		if( reset ) begin
			regarray[0]<=8'd0; 
			regarray[1]<=8'd0;
			regarray[2]<=8'd0;
			regarray[3]<=8'd0;
			ymp_state <= YM_INIT;
			ymp_skipstringindex <= 3'b0;
		end 
		else
		begin
			if( write ) begin
`ifdef YM_DEBUG
				$display("YM->RAM->WRITE %x %x", addr, data_in);
`endif
				regarray[addr] <= data_in;
			end
			else
			begin
				case(regarray[0])
				8'd1:
				begin
`ifdef YM_DEBUG
					$display("YM->PLAY-TRACK %d %d", {regarray[1], regarray[2], regarray[3]}, regarray[0][1:0]);
`endif
					regarray[0] <= 8'd0;
					/* verilator lint_off WIDTH */
					ymp_trackoffset <= {{regarray[1], regarray[2], regarray[3]}};
					/* verilator lint_on WIDTH */
					ymp_playing <= 1'b1;
					ymp_loop <= 1'b0;
					ymp_state <= YM_INIT;
				end
				8'd2:
				begin
`ifdef YM_DEBUG
					$display("YM->LOOP-TRACK %d %d", {regarray[1], regarray[2], regarray[3]}, regarray[0][1:0]);
`endif
					regarray[0] <= 8'd0;
					/* verilator lint_off WIDTH */
					ymp_trackoffset <= {{regarray[1], regarray[2], regarray[3]}};
					/* verilator lint_on WIDTH */
					ymp_playing <= 1'b1;
					ymp_loop <= 1'b1;
					ymp_state <= YM_INIT;
				end
				8'd3:
				begin
`ifdef YM_DEBUG
					$display("YM->STOP-TRACK");
`endif
					ymp_playing <= 0;
					regarray[0]<=8'd0; 
					regarray[1]<=8'd0;
					regarray[2]<=8'd0;
					regarray[3]<=8'd0;
					ymp_state <= YM_STOPPED;
				end
				default:
				begin
					
				end
				endcase
			end

			case (ymp_state)
			YM_INIT:
			begin			
				if(ymp_playing)
				begin
`ifdef YM_DEBUG
					$display("YM_INIT");
`endif
					// Reset player frame and register
					ymp_frame <= {ROM_WIDTH{1'b0}};
					ymp_register <= 4'b0;
					ymp_skipstringindex <= 3'b0;
					// Set address to read first song attribute byte
					musicrom_addr <= ymp_trackoffset + {{ROM_WIDTH-8{1'b0}},8'h13};

					ymp_state_next <= YM_GETMODE;
					ymp_state <= YM_WAIT;
				end
			end

			YM_WAIT:
			begin
				ymp_state <= ymp_state_next;
			end

			YM_GETMODE:
			begin
`ifdef YM_DEBUG
				$display("YM_GETMODE %x %x", musicrom_addr, musicrom_data_out);
`endif
				ymp_interleave <= musicrom_data_out[0];

				// Set address to read song length byte 0
				musicrom_addr <= ymp_trackoffset + {{ROM_WIDTH-8{1'b0}},8'h0f};
				ymp_state <= YM_WAIT;
				ymp_state_next <= YM_GETLENGTH_0;
			end

			// Get song length
			YM_GETLENGTH_0:
			begin
`ifdef YM_DEBUG
				$display("YM_GETLENGTH_0 %x %x", musicrom_addr, musicrom_data_out);
`endif
				// Read song length byte 0
				ymp_length[7:0] <= musicrom_data_out;

				// Set address to read song length byte 1
				musicrom_addr <= ymp_trackoffset + {{ROM_WIDTH-8{1'b0}},8'h0e};
				ymp_state <= YM_WAIT;
				ymp_state_next <= YM_GETLENGTH_1;
			end
			YM_GETLENGTH_1:
			begin
`ifdef YM_DEBUG
				$display("YM_GETLENGTH_1 %x %x", musicrom_addr, musicrom_data_out);
`endif
				// Read song length byte 1
				ymp_length[14:8] <= musicrom_data_out[6:0];
				// Set address to frequency point
				musicrom_addr <= ymp_trackoffset + {{ROM_WIDTH-8{1'b0}},8'h1b};
				ymp_state <= YM_WAIT;
				ymp_state_next <= YM_GETFREQUENCY;
			end

			// Get song playback frequency
			YM_GETFREQUENCY:
			begin
`ifdef YM_DEBUG
				$display("YM_GETFREQUENCY %x %x", musicrom_addr, musicrom_data_out);
`endif
				// Read song length byte 1
				ymp_is_50hz <= musicrom_data_out[7:0] == 8'd50;
				// Set address to loop point
				musicrom_addr <= ymp_trackoffset + {{ROM_WIDTH-8{1'b0}},8'h1f};
				ymp_state <= YM_WAIT;
				ymp_state_next <= YM_GETLOOP_0;
			end

			// Get song loop point
			YM_GETLOOP_0:
			begin
`ifdef YM_DEBUG
				$display("YM_GETLOOP_0 %x %x", musicrom_addr, musicrom_data_out);
`endif
				// Read song loop point byte 0
				ymp_looppoint[7:0] <= musicrom_data_out;

				// Set address to read song length byte 1
				musicrom_addr <= ymp_trackoffset + {{ROM_WIDTH-8{1'b0}},8'h1e};
				ymp_state <= YM_WAIT;
				ymp_state_next <= YM_GETLOOP_1;
			end
			YM_GETLOOP_1:
			begin
`ifdef YM_DEBUG
				$display("YM_GETLOOP_1 %x %x", musicrom_addr, musicrom_data_out);
`endif
				// Read song loop point byte 1
				ymp_looppoint[14:8] <= musicrom_data_out[6:0];
				// Set address to read past NT-string data
				musicrom_addr <= ymp_trackoffset + {{ROM_WIDTH-8{1'b0}},8'h22};
				ymp_state <= YM_WAIT;
				ymp_state_next <= YM_SKIPSTRINGS;
			end

			// Skip past null terminated strings to find first frame data point
			YM_SKIPSTRINGS:
			begin
`ifdef YM_DEBUG
				$display("YM_SKIPSTRINGS %x %x", musicrom_addr, musicrom_data_out);
`endif
				if(musicrom_data_out == 8'b0)
				begin
					if(ymp_skipstringindex == 3'd2)
					begin
						ymp_firstframe <= musicrom_addr - ymp_trackoffset;
						ymp_state <= YM_WAITFORFRAME;
					end
					else
					begin
						ymp_skipstringindex <= ymp_skipstringindex + 3'b1;
					end
				end
				musicrom_addr <= musicrom_addr + {{ROM_WIDTH-1{1'b0}},1'b1};
			end
		
			// Main loop - wait for next vertical blank
			YM_WAITFORFRAME:
			begin
				if(!ymp_playing)
				begin
`ifdef YM_DEBUG
					$display("ymp_playing %d - STOPPING MUSIC", ymp_playing);
`endif
					ymp_state <= YM_INIT;
				end
				if(frame_ready)
				begin
`ifdef YM_DEBUG
					$display("YM_WAITFORFRAME f=%d l=%d ff=%d", ymp_frame, ymp_length, ymp_firstframe);
`endif
					frame_ready <= 1'b0;
					ymp_register <= 4'b0;
					ymp_state <= YM_WAIT;
					ymp_state_next <= YM_GETREGISTER;
				end
			end

			YM_GETREGISTER:
			begin
				// Calculate address for this frame+register combo in ROM
				// - If ymp_interleave=1 then position is (register * length) + frame
				// - If ymp_interleave=0 then position is (frame * 16) + register
`ifdef YM_DEBUG
				$display("YM_GETREGISTER I %d F %d / %d R %d - A %x D %x", ymp_interleave, ymp_frame, ymp_length, ymp_register, musicrom_addr, musicrom_data_out);
`endif
				if(ymp_interleave)
				begin
					musicrom_addr <= ymp_trackoffset + (ymp_register * ymp_length) + ymp_frame + ymp_firstframe;
				end
				else
				begin
					musicrom_addr <= ymp_trackoffset + {ymp_frame[11:0], 4'b0} + ymp_firstframe;
				end
				ymp_state <= YM_WAIT;
				ymp_state_next <= YM_SETREGISTER;
			end

			YM_SETREGISTER:
			begin
`ifdef YM_DEBUG
				$display("YM_SETREGISTER I %d F %d / %d R %d - A %x D %x", ymp_interleave,ymp_frame, ymp_length, ymp_register, musicrom_addr, musicrom_data_out);
`endif
				snd_data_in <= musicrom_data_out & ymp_registermask[{ymp_register, 3'b0}+:8];
				snd_wr <= 1'b1;
				ymp_state <= YM_NEXTREGISTER;
			end

			YM_NEXTREGISTER:
			begin
`ifdef YM_DEBUG
				$display("YM_NEXTREGISTER I %d F %d / %d R %d - A %x D %x", ymp_interleave,ymp_frame, ymp_length, ymp_register, musicrom_addr, musicrom_data_out);
`endif
				snd_wr <= 1'b0;
				if(ymp_register == 4'd13)
				begin
					ymp_frame <= ymp_frame + 16'd1;
					ymp_state <= YM_WAITFORFRAME;
					if((ymp_frame + 16'd1)== ymp_length )
					begin
						if(ymp_loop)
						begin
							// Set frame back to loop start
`ifdef YM_DEBUG
						$display("YM LOOP I %d F %d / %d R %d - A %x D %x", ymp_interleave,ymp_frame, ymp_length, ymp_register, musicrom_addr, musicrom_data_out);
`endif
						ymp_frame <= ymp_looppoint;
						end
						else
						begin
							// Stop playing
							ymp_playing <= 0;
							regarray[0]<=8'd0; 
							regarray[1]<=8'd0;
							regarray[2]<=8'd0;
							regarray[3]<=8'd0;
							ymp_state <= YM_STOPPED;
						end
					end
				end
				else
				begin
					ymp_register <= ymp_register + 4'b1;
					ymp_state <= YM_GETREGISTER;
				end

			end

			endcase
		end
	end
endmodule