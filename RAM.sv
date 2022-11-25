`define WORD_WIDTH 8
`define WORDS_NUMBER 4096
`define FONTS_SIZE 80

module RAM(
	input					clock,
	input					resetN,
	input		[11:0]	next_instruction_address,
	input		[11:0]	write_address,
	input					write_en[16],
	input		[7:0]		write_byte[16],
	input		[11:0]	read_address,
	input					read_en[16],
	output	[15:0]	next_instruction_data,
	output	[7:0]		read_byte[16]
);

reg [`WORD_WIDTH - 1 : 0] fonts [`FONTS_SIZE - 1 : 0] = '{
	8'hF0, 8'h90, 8'h90, 8'h90, 8'hF0,		// 0
	8'h20, 8'h60, 8'h20, 8'h20, 8'h70,		// 1
	8'hF0, 8'h10, 8'hF0, 8'h80, 8'hF0,		// 2
	8'hF0, 8'h10, 8'hF0, 8'h10, 8'hF0,		// 3
	8'h90, 8'h90, 8'hF0, 8'h10, 8'h10,		// 4
	8'hF0, 8'h80, 8'hF0, 8'h10, 8'hF0,		// 5
	8'hF0, 8'h80, 8'hF0, 8'h90, 8'hF0,		// 6
	8'hF0, 8'h10, 8'h20, 8'h40, 8'h40,		// 7
	8'hF0, 8'h90, 8'hF0, 8'h90, 8'hF0,		// 8
	8'hF0, 8'h90, 8'hF0, 8'h10, 8'hF0,		// 9
	8'hF0, 8'h90, 8'hF0, 8'h90, 8'h90,		// A
	8'hE0, 8'h90, 8'hE0, 8'h90, 8'hE0,		// B
	8'hF0, 8'h80, 8'h80, 8'h80, 8'hF0,		// C
	8'hE0, 8'h90, 8'h90, 8'h90, 8'hE0,		// D
	8'hF0, 8'h80, 8'hF0, 8'h80, 8'hF0,		// E
	8'hF0, 8'h80, 8'hF0, 8'h80, 8'h80		// F
};

localparam ROM_SIZE = 478;

reg [7:0] ROM [ROM_SIZE - 1 : 0] = '{
	8'h12, 8'h4E, 8'hEA, 8'hAC, 8'hAA, 8'hEA, 8'hCE, 8'hAA, 8'hAA, 8'hAE, 8'hE0, 8'hA0, 8'hA0, 8'hE0, 8'hC0,
	8'h40, 8'h40, 8'hE0, 8'hE0, 8'h20, 8'hC0, 8'hE0, 8'hE0, 8'h60, 8'h20, 8'hE0, 8'hA0, 8'hE0, 8'h20, 8'h20,
	8'h60, 8'h40, 8'h20, 8'h40, 8'hE0, 8'h80, 8'hE0, 8'hE0, 8'hE0, 8'h20, 8'h20, 8'h20, 8'hE0, 8'hE0, 8'hA0,
	8'hE0, 8'hE0, 8'hE0, 8'h20, 8'hE0, 8'h40, 8'hA0, 8'hE0, 8'hA0, 8'hE0, 8'hC0, 8'h80, 8'hE0, 8'hE0, 8'h80,
	8'hC0, 8'h80, 8'hA0, 8'h40, 8'hA0, 8'hA0, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h00, 8'hEE, 8'hA2, 8'h02, 8'hDA,
	8'hB4, 8'h13, 8'hDC, 8'h68, 8'h01, 8'h69, 8'h05, 8'h6A, 8'h0A, 8'h6B, 8'h01, 8'h65, 8'h2A, 8'h66, 8'h2B,
	8'hA2, 8'h16, 8'hD8, 8'hB4, 8'hA2, 8'h3E, 8'hD9, 8'hB4, 8'hA2, 8'h02, 8'h36, 8'h2B, 8'hA2, 8'h06, 8'hDA,
	8'hB4, 8'h6B, 8'h06, 8'hA2, 8'h1A, 8'hD8, 8'hB4, 8'hA2, 8'h3E, 8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h45, 8'h2A,
	8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h6B, 8'h0B, 8'hA2, 8'h1E, 8'hD8, 8'hB4, 8'hA2, 8'h3E, 8'hD9, 8'hB4, 8'hA2,
	8'h06, 8'h55, 8'h60, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h6B, 8'h10, 8'hA2, 8'h26, 8'hD8, 8'hB4, 8'hA2, 8'h3E,
	8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h76, 8'hFF, 8'h46, 8'h2A, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h6B, 8'h15, 8'hA2,
	8'h2E, 8'hD8, 8'hB4, 8'hA2, 8'h3E, 8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h95, 8'h60, 8'hA2, 8'h02, 8'hDA, 8'hB4,
	8'h6B, 8'h1A, 8'hA2, 8'h32, 8'hD8, 8'hB4, 8'hA2, 8'h3E, 8'hD9, 8'hB4, 8'h22, 8'h42, 8'h68, 8'h17, 8'h69,
	8'h1B, 8'h6A, 8'h20, 8'h6B, 8'h01, 8'hA2, 8'h0A, 8'hD8, 8'hB4, 8'hA2, 8'h36, 8'hD9, 8'hB4, 8'hA2, 8'h02,
	8'hDA, 8'hB4, 8'h6B, 8'h06, 8'hA2, 8'h2A, 8'hD8, 8'hB4, 8'hA2, 8'h0A, 8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h87,
	8'h50, 8'h47, 8'h2A, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h6B, 8'h0B, 8'hA2, 8'h2A, 8'hD8, 8'hB4, 8'hA2, 8'h0E,
	8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h67, 8'h2A, 8'h87, 8'hB1, 8'h47, 8'h2B, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h6B,
	8'h10, 8'hA2, 8'h2A, 8'hD8, 8'hB4, 8'hA2, 8'h12, 8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h66, 8'h78, 8'h67, 8'h1F,
	8'h87, 8'h62, 8'h47, 8'h18, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h6B, 8'h15, 8'hA2, 8'h2A, 8'hD8, 8'hB4, 8'hA2,
	8'h16, 8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h66, 8'h78, 8'h67, 8'h1F, 8'h87, 8'h63, 8'h47, 8'h67, 8'hA2, 8'h02,
	8'hDA, 8'hB4, 8'h6B, 8'h1A, 8'hA2, 8'h2A, 8'hD8, 8'hB4, 8'hA2, 8'h1A, 8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h66,
	8'h8C, 8'h67, 8'h8C, 8'h87, 8'h64, 8'h47, 8'h18, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h68, 8'h2C, 8'h69, 8'h30,
	8'h6A, 8'h34, 8'h6B, 8'h01, 8'hA2, 8'h2A, 8'hD8, 8'hB4, 8'hA2, 8'h1E, 8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h66,
	8'h8C, 8'h67, 8'h78, 8'h87, 8'h65, 8'h47, 8'hEC, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h6B, 8'h06, 8'hA2, 8'h2A,
	8'hD8, 8'hB4, 8'hA2, 8'h22, 8'hD9, 8'hB4, 8'hA2, 8'h06, 8'h66, 8'hE0, 8'h86, 8'h6E, 8'h46, 8'hC0, 8'hA2,
	8'h02, 8'hDA, 8'hB4, 8'h6B, 8'h0B, 8'hA2, 8'h2A, 8'hD8, 8'hB4, 8'hA2, 8'h36, 8'hD9, 8'hB4, 8'hA2, 8'h06,
	8'h66, 8'h0F, 8'h86, 8'h66, 8'h46, 8'h07, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h6B, 8'h10, 8'hA2, 8'h3A, 8'hD8,
	8'hB4, 8'hA2, 8'h1E, 8'hD9, 8'hB4, 8'hA3, 8'hE8, 8'h60, 8'h00, 8'h61, 8'h30, 8'hF1, 8'h55, 8'hA3, 8'hE9,
	8'hF0, 8'h65, 8'hA2, 8'h06, 8'h40, 8'h30, 8'hA2, 8'h02, 8'hDA, 8'hB4, 8'h6B, 8'h15, 8'hA2, 8'h3A, 8'hD8,
	8'hB4, 8'hA2, 8'h16, 8'hD9, 8'hB4, 8'hA3, 8'hE8, 8'h66, 8'h89, 8'hF6, 8'h33, 8'hF2, 8'h65, 8'hA2, 8'h02,
	8'h30, 8'h01, 8'hA2, 8'h06, 8'h31, 8'h03, 8'hA2, 8'h06, 8'h32, 8'h07, 8'hA2, 8'h06, 8'hDA, 8'hB4, 8'h6B,
	8'h1A, 8'hA2, 8'h0E, 8'hD8, 8'hB4, 8'hA2, 8'h3E, 8'hD9, 8'hB4, 8'h12, 8'h48, 8'h13, 8'hDC
};

reg [`WORD_WIDTH - 1 : 0] memory [`WORDS_NUMBER - 1 : 0];
//https://stackoverflow.com/questions/354962/how-do-i-make-quartus-ii-compile-faster
//assign {memory[0], memory[1], memory[2], memory[3], memory[4]} = {8'hF0, 8'h90, 8'h90, 8'h90, 8'hF0};

//assign memory[79:0] = fonts[79:0];

integer i;	// generic loop iterator.

always @(posedge clock or negedge resetN) begin
	if (!resetN) begin
		next_instruction_data = 16'h0200;
//		$readmemb("C:\\Projects\\YACH8E\\Games\\INVADERS", memory, 12'h200);
//		assign memory[10:14] = {8'hF0, 8'h10, 8'hF0, 8'h80, 8'hF0};
// A[x+:c] = B[y+:d]; 
//		fonts <= '{8'hF0, 8'h90, 8'h90, 8'h90, 8'hF0};
		memory[79:0] = fonts[79:0];
		memory[512+ROM_SIZE-1:512] = ROM[ROM_SIZE-1:0];
	end
	else begin
		next_instruction_data = memory[next_instruction_address];
		for (i = 0; i < 16; i = i + 1) begin
			if (read_en[i] == 1'b1) begin
				read_byte[i] = memory[read_address + i];
			end
		end
		for (i = 0; i < 16; i = i + 1) begin
			if (write_en[i] == 1'b1) begin
				memory[read_address + i] = write_byte[i];
			end
		end
	end
end

endmodule
