`timescale 1ns / 1ps
/*============================================================================
	Aznable (custom 8-bit computer system) - Charles (sound engine)

	Author: Jim Gregory - https://github.com/JimmyStones/
	Version: 0.1
	Date: 2021-12-21

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

module sound #(
	parameter ROM_WIDTH
)(
	input				clk,
	input				reset,
	
	input		[3:0]	addr,
	input		[7:0]	data_in,
	input				write,

	input		[7:0]	soundrom_data_out,
	output reg [ROM_WIDTH-1:0]	soundrom_addr,
	output signed [11:0]	audio_out
	);

wire sample;						// Is m5205 requesting sample data
reg  [3:0] snd_data_in;				// 4 bit data input to m5205
reg [ROM_WIDTH-1:0] soundrom_addr_target;	// Current sample end position

reg [7:0] volume;					// Sound output volume
reg m5205_ce;						// Counter for 375KHz clock enable
reg m5205_phase;					// Memory address phase counter - 0 = 4 high bits, 1 = 4 low bits
reg playing;						// Is sound playing
reg [13:0] ce_counter;				// Counter for 375KHz clock enable

always @(posedge clk) 
begin
	if(reset)
	begin
		// Clear all signals on reset
		ce_counter <= 14'd0;
		soundrom_addr <= {ROM_WIDTH{1'b0}};
		soundrom_addr_target <= {ROM_WIDTH{1'b0}};
		playing <= 1'b0;
	end

	// Generate 375Khz clock enable
	m5205_ce <= (ce_counter == 14'd0);
	if(ce_counter == 14'd63)
	begin
		ce_counter <= 14'd0;
	end
	else
	begin
		ce_counter <= ce_counter + 14'd1;
	end

	if(write)
	begin
		// Disable playback when CPU is sending commands
		playing <= 1'b0;
		case (addr[3:2])
		2'd0:
		begin
			// Set initial address (sample beginning)
			soundrom_addr[{addr[0],3'd0} +: 8] <= data_in;
		end
		2'd1:
		begin
			// Set target address (sample end)
			soundrom_addr_target[{addr[0],3'd0} +: 8] <= data_in;
		end
		2'd2:
		begin
			// Trigger play
			//$display("playing write: start=%d  end=%d", soundrom_addr, soundrom_addr_target);
			ce_counter <= 14'd0;
			playing <= 1'b1;
		end
		2'd3:
		begin
			// Set volume
			$display("set volume: %d", data_in);
			volume <= data_in;
		end
		default:
		begin
			
		end
		endcase
	end
	
	// Generate m5205 data input
	if(playing)
	begin
		// If playing and m5205 is requesting a sample, load 4 bits from ROM and shift phase for next read
		if(sample)
		begin
			// Shift phase for next read
			m5205_phase <= m5205_phase + 1'd1;
			if(m5205_phase == 1'b1)
			begin
				// Increment music ROM address
				soundrom_addr <= soundrom_addr + {{ROM_WIDTH-1{1'b0}},1'b1};
				// Get 4 low bits from ROM
				snd_data_in <= soundrom_data_out[3:0];
				// If target address has been reach, stop playing
				if(soundrom_addr_target == soundrom_addr) playing <= 1'b0;
			end
			else
			begin
				// Get 4 high bits from ROM
				snd_data_in <= soundrom_data_out[7:4];
			end
		end
	end
	else
	begin
		snd_data_in <= 4'd0;
	end

end

// M5205
jt5205 #(.INTERPOL(0)) m5205(
    .rst(~playing),			// Hold reset while sound is not playing so it can return to zero
	.clk(clk),
    .cen(m5205_ce),			// 375Khz clock enable
	.sel(2'b10),			// 8Khz sample rate
    .din(snd_data_in),
    .sound(audio_out),
    .sample(sample),		// Requesting a sample
	.irq(),
	.vclk_o()
);

endmodule