module CPU(
	input					clock,
	input					resetN,
	input		[15:0]	data_RAM,
	input		[7:0]		clock_random_generator,		// 8-bits clock for generating random pseudo-numbers
	input					draw_collision,				// previous sprite draw had collision
	output	[11:0]	address_RAM,					// address to read next instruction (PC)
	output reg			clear_display,
	output reg			beep_on,
	output	[11:0]	write_address,
	output				write_en[16],
	output	[7:0]		write_byte[16]
);

reg [7:0]	RegisterV[16];		// 16 8-bits general purpose registers
reg [11:0]	RegisterI;
reg [11:0]	RegisterPC;			// Program Counter register
reg [3:0]	RegisterSP;			// Stack Pointer register
reg [7:0]	RegisterST;			// Sound Timer register
reg [7:0]	RegisterDT;			// Delay Timer register
reg [11:0]	Stack[16];			// Stack for PC

reg [11:0] 	nnn;
reg [7:0]	nn;
reg [3:0]	n;
reg [3:0]	x;
reg [3:0]	y;
reg [7:0]	kk;

integer i;	// generic loop iterator.

always @(posedge clock or negedge resetN) begin
	if (!resetN) begin
		for (i = 0; i < 16; i = i + 1) begin
			RegisterV[i] <= 8'h00;
		end
		RegisterI <= 12'h000;
		RegisterPC <= 12'h200;
		RegisterSP <= 4'h0;
		RegisterST <= 8'h00;
		RegisterDT <= 8'h00;
	end
	else begin
		clear_display = 1'b0;
		beep_on = 1'b0;
		write_address = 12'h000;
		for (i = 0; i < 16; i = i + 1) begin
			write_en[i] = 1'b0;
			write_byte[i] = 8'h00;
		end
	
	
		nnn <= data_RAM[11:0];
		nn <= data_RAM[7:0];
		n <= data_RAM[3:0];
		x <= data_RAM[11:8];
		y <= data_RAM[7:4];
		kk <= data_RAM[7:0];

		case (data_RAM[15:12])
			4'h0: begin
				case (data_RAM[11:0])
					12'h0E0: begin		// 00E0 - CLS
						// Clear the display.
						clear_display = 1'b1;
						RegisterPC = RegisterPC + 12'h2;
					end
					12'h0EE: begin		// 00EE - RET
						// Return from a subroutine.
						RegisterSP = RegisterSP - 4'h1;
						RegisterPC = Stack[RegisterSP] + 12'h2;
					end
					default: begin		// SYS addr
						// Unimplemented SYS, just jump to next instruction.
						RegisterPC = RegisterPC + 12'h2;
					end
				endcase
			end
			
			4'h1: begin		// 1nnn - JP addr
				// Jump to location nnn.
				RegisterPC = nnn;
			end
			
			4'h2: begin		// 2nnn - CALL addr
				// Call subroutine at nnn.
				Stack[RegisterSP] = RegisterPC;
				RegisterSP = RegisterSP + 4'h1;
				RegisterPC = nnn;
			end
			
			4'h3: begin		// 3xkk - SE Vx, byte
				// Skip next instruction if Vx = kk.
				if (RegisterV[x] == kk) begin
					RegisterPC = RegisterPC + 12'h4;
				end else begin
					RegisterPC = RegisterPC + 12'h2;
				end
			end
			
			4'h4: begin		// 4xkk - SNE Vx, byte
				// Skip next instruction if Vx != kk.
				if (RegisterV[x] != kk) begin
					RegisterPC = RegisterPC + 12'h4;
				end else begin
					RegisterPC = RegisterPC + 12'h2;
				end
			end
			
			4'h5: begin		// 5xy0 - SE Vx, Vy
				// Skip next instruction if Vx = Vy.
				if (RegisterV[x] == RegisterV[y]) begin
					RegisterPC = RegisterPC + 12'h4;
				end else begin
					RegisterPC = RegisterPC + 12'h2;
				end
			end
			
			4'h6: begin		// 6xkk - LD Vx, byte
				// Set Vx = kk.
				RegisterV[x] = kk;
				RegisterPC = RegisterPC + 12'h2;
			end
			
			4'h7: begin		// 7xkk - ADD Vx, byte
				// Set Vx = Vx + kk.
				RegisterV[x] = RegisterV[x] + kk;
				RegisterPC = RegisterPC + 12'h2;
			end
			
			4'h8: begin
				case (n)
					4'h0: begin		// 8xy0 - LD Vx, Vy
						// Set Vx = Vy.
						RegisterV[x] = RegisterV[y];
						RegisterPC = RegisterPC + 12'h2;
					end
					4'h1: begin		// 8xy1 - OR Vx, Vy
						// Set Vx = Vx OR Vy.
						RegisterV[x] = RegisterV[x] | RegisterV[y];
						RegisterPC = RegisterPC + 12'h2;
					end
					4'h2: begin		// 8xy2 - AND Vx, Vy
						// Set Vx = Vx AND Vy.
						RegisterV[x] = RegisterV[x] & RegisterV[y];
						RegisterPC = RegisterPC + 12'h2;
					end
					4'h3: begin		// 8xy3 - XOR Vx, Vy
						// Set Vx = Vx XOR Vy.
						RegisterV[x] = RegisterV[x] ^ RegisterV[y];
						RegisterPC = RegisterPC + 12'h2;
					end
					4'h4: begin		// 8xy4 - ADD Vx, Vy
						// Set Vx = Vx + Vy, set VF = carry.
						RegisterV[x] = RegisterV[x] + RegisterV[y];
						RegisterV[15] = ((9'(RegisterV[x]) + 9'(RegisterV[y])) > 9'hFF) ? 8'h01 : 8'h00;
						RegisterPC = RegisterPC + 12'h2;
					end
					4'h5: begin		// 8xy5 - SUB Vx, Vy
						// Set Vx = Vx - Vy, set VF = NOT borrow.
						RegisterV[15] = (RegisterV[x] >= RegisterV[y]) ? 8'h01 : 8'h00;
						RegisterV[x] = RegisterV[x] - RegisterV[y];
						RegisterPC = RegisterPC + 12'h2;
					end
					4'h6: begin		// 8xy6 - SHR Vx
						// Set Vx = Vy SHR 1.
						RegisterV[15] = RegisterV[x] & 8'h01;
						RegisterV[x] = RegisterV[x] >> 1;
						RegisterPC = RegisterPC + 12'h2;
					end
					4'h7: begin		// 8xy7 - SUBN Vx, Vy
						// Set Vx = Vy - Vx, set VF = NOT borrow.
						RegisterV[x] = RegisterV[y] - RegisterV[x];
						RegisterV[15] = (RegisterV[y] > RegisterV[x]) ? 8'h01 : 8'h00;
						RegisterPC = RegisterPC + 12'h2;
					end
					4'hE: begin		// 8xyE - SHL Vx
						// Set Vx = Vx SHL 1.
						RegisterV[15] = 8'(RegisterV[x][7:7]);
						RegisterV[x] = RegisterV[x] << 1;
						RegisterPC = RegisterPC + 12'h2;
					end
				endcase
			end
			
			4'h9: begin		// 9xy0 - SNE Vx, Vy
				// Skip next instruction if Vx != Vy.
				if (RegisterV[x] != RegisterV[y]) begin
					RegisterPC = RegisterPC + 12'h4;
				end else begin
					RegisterPC = RegisterPC + 12'h2;
				end
			end
			
			4'hA: begin		// Annn - LD I, addr
				// Set I = nnn.
				RegisterI = nnn;
				RegisterPC = RegisterPC + 12'h2;
			end
			
			4'hB: begin		// Bnnn - JP V0, addr
				// Jump to location nnn + V0.
				RegisterPC = nnn + RegisterV[0];
			end
			
			4'hC: begin		// Cxkk - RND Vx, byte
				// Set Vx = random byte AND kk.
				RegisterV[x] = 8'(clock_random_generator) & kk;
				RegisterPC = RegisterPC + 12'h2;
			end
			
			4'hD: begin		// Dxyn - DRW Vx, Vy, nibble
				// Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision.
/*** COMPLETE ***/
				RegisterPC = RegisterPC + 12'h2;
			end
			
			4'hE: begin
				case (nn)
					8'h9E: begin		// Ex9E - SKP Vx
						// Skip next instruction if key with the value of Vx is pressed.
/*** COMPLETE ***/
						RegisterPC = RegisterPC + 12'h2;
					end
					8'hA1: begin		// ExA1 - SKNP Vx
						// Skip next instruction if key with the value of Vx is not pressed.
/*** COMPLETE ***/
						RegisterPC = RegisterPC + 12'h2;
					end
				endcase
			end
			
			4'hF: begin
				case (nn)
					8'h07: begin		// Fx07 - LD Vx, DT
						// Set Vx = delay timer value.
						RegisterV[x] = RegisterDT;
						RegisterPC = RegisterPC + 12'h2;
					end
					8'h0A: begin		// Fx0A - LD Vx, K
/*** COMPLETE ***/
						RegisterPC = RegisterPC + 12'h2;
					end
					8'h15: begin		// Fx15 - LD DT, Vx
						// Set delay timer = Vx.
						RegisterDT = RegisterV[x];
						RegisterPC = RegisterPC + 12'h2;
					end
					8'h18: begin		// Fx18 - LD ST, Vx
						// Set sound timer = Vx.
						RegisterST = RegisterV[x];
						RegisterPC = RegisterPC + 12'h2;
					end
					8'h1E: begin		// Fx1E - ADD I, Vx
						// Set I = I + Vx.
						RegisterI = RegisterI + RegisterV[x];
						RegisterPC = RegisterPC + 12'h2;
					end
					8'h29: begin		// Fx29 - LD F, Vx
						// Set I = location of sprite for digit Vx.
/*** COMPLETE ***/
						RegisterPC = RegisterPC + 12'h2;
					end
					8'h33: begin		// Fx33 - LD B, Vx
						// Store BCD representation of Vx in memory locations I, I+1, and I+2.
						write_address = RegisterI;
						write_en[0] = 1'b1;
						write_byte[0] = 8'(RegisterV[x] / 100);
						write_en[1] = 1'b1;
						write_byte[1] = 8'((RegisterV[x] / 10) % 10);
						write_en[2] = 1'b1;
						write_byte[2] = 8'(RegisterV[x] % 10);
						RegisterPC = RegisterPC + 12'h2;
					end
					8'h55: begin		// Fx55 - LD [I], Vx
						// Store registers V0 through Vx in memory starting at location I.
						write_address = RegisterI;
						for (i = 0; i < x; i = i + 1) begin
							write_en[i] = 1'b1;
							write_byte[0] = RegisterV[i];
						end
						RegisterPC = RegisterPC + 12'h2;
					end
					8'h65: begin		// Fx65 - LD Vx, [I]
						// Read registers V0 through Vx from memory starting at location I.
/*** COMPLETE ***/		
						RegisterPC = RegisterPC + 12'h2;
					end
				endcase
			end
			
			default: begin
			end
		endcase
		
		// set output address RAM to current PC for reading next instruction on next cycle
		address_RAM <= RegisterPC;
		if (RegisterST > 0) begin
			beep_on = 1'b1;
		end
	end
end

endmodule
