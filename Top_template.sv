// Designer: Mor (Mordechai) Dahan, Avi Salmon,
// Sep. 2022
// ***********************************************

`define ENABLE_ADC_CLOCK
`define ENABLE_CLOCK1
`define ENABLE_CLOCK2
`define ENABLE_SDRAM
`define ENABLE_HEX0
`define ENABLE_HEX1
`define ENABLE_HEX2
`define ENABLE_HEX3
`define ENABLE_HEX4
`define ENABLE_HEX5
`define ENABLE_KEY
`define ENABLE_LED
`define ENABLE_SW
`define ENABLE_VGA
`define ENABLE_ACCELEROMETER
`define ENABLE_ARDUINO
`define ENABLE_GPIO

module Top_template(

	//////////// ADC CLOCK: 3.3-V LVTTL //////////
`ifdef ENABLE_ADC_CLOCK
	input 		          		ADC_CLK_10,
`endif
	//////////// CLOCK 1: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK1
	input 		          		MAX10_CLK1_50,
`endif
	//////////// CLOCK 2: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK2
	input 		          		MAX10_CLK2_50,
`endif

	//////////// SDRAM: 3.3-V LVTTL //////////
`ifdef ENABLE_SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,
`endif

	//////////// SEG7: 3.3-V LVTTL //////////
`ifdef ENABLE_HEX0
	output		     [7:0]		HEX0,
`endif
`ifdef ENABLE_HEX1
	output		     [7:0]		HEX1,
`endif
`ifdef ENABLE_HEX2
	output		     [7:0]		HEX2,
`endif
`ifdef ENABLE_HEX3
	output		     [7:0]		HEX3,
`endif
`ifdef ENABLE_HEX4
	output		     [7:0]		HEX4,
`endif
`ifdef ENABLE_HEX5
	output		     [7:0]		HEX5,
`endif

	//////////// KEY: 3.3 V SCHMITT TRIGGER //////////
`ifdef ENABLE_KEY
	input 		     [1:0]		KEY,
`endif

	//////////// LED: 3.3-V LVTTL //////////
`ifdef ENABLE_LED
	output		     [9:0]		LEDR,
`endif

	//////////// SW: 3.3-V LVTTL //////////
`ifdef ENABLE_SW
	input 		     [9:0]		SW,
`endif

	//////////// VGA: 3.3-V LVTTL //////////
`ifdef ENABLE_VGA
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,
`endif

	//////////// Accelerometer: 3.3-V LVTTL //////////
`ifdef ENABLE_ACCELEROMETER
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,
`endif

	//////////// Arduino: 3.3-V LVTTL //////////
`ifdef ENABLE_ARDUINO
	output 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,
`endif

	//////////// GPIO, GPIO connect to GPIO Default: 3.3-V LVTTL //////////
`ifdef ENABLE_GPIO
	inout 		    [35:0]		GPIO
`endif
);


//=======================================================
//  REG/WIRE declarations
//=======================================================

// clock signals
wire				clk_25;
wire				clk_50;
wire				clk_100;

// Screens signals
wire	[31:0]	pxl_x;
wire	[31:0]	pxl_y;
wire				h_sync_wire;
wire				v_sync_wire;
wire	[3:0]		vga_r_wire;
wire	[3:0]		vga_g_wire;
wire	[3:0]		vga_b_wire;
wire	[7:0]		lcd_db;
wire				lcd_reset;
wire				lcd_wr;
wire				lcd_d_c;
wire				lcd_rd;
wire				lcd_buzzer;
wire				lcd_status_led;
wire	[3:0]		Red_level;
wire	[3:0]		Green_level;
wire	[3:0]		Blue_level;

// Intel module move and draw signals
wire	[3:0]		r_intel;
wire	[3:0]		g_intel;
wire	[3:0]		b_intel;
wire				draw_intel;
wire	[31:0]	topLeft_x_intel;
wire	[31:0]	topLeft_y_intel;

// Ghost module move and draw signals
wire	[3:0]		r_ghost;
wire	[3:0]		g_ghost;
wire	[3:0]		b_ghost;
wire				draw_ghost;
wire 				ghost_x_direction;
wire	[31:0]	topLeft_x_ghost;
wire	[31:0]	topLeft_y_ghost;

// Periphery signals
wire	A;
wire	B;
wire	Select;
wire	Start;
wire	Right;
wire	Left;
wire	Up;
wire	Down;
wire [11:0]	Wheel;


// Screens Assigns
assign ARDUINO_IO[7:0]	= lcd_db;
assign ARDUINO_IO[8] 	= lcd_reset;
assign ARDUINO_IO[9]		= lcd_wr;
assign ARDUINO_IO[10]	= lcd_d_c;
assign ARDUINO_IO[11]	= lcd_rd;
assign ARDUINO_IO[12]	= lcd_buzzer;
assign ARDUINO_IO[13]	= lcd_status_led;
assign VGA_HS = h_sync_wire;
assign VGA_VS = v_sync_wire;
assign VGA_R = vga_r_wire;
assign VGA_G = vga_g_wire;
assign VGA_B = vga_b_wire;


// Screens control (LCD and VGA)
Screens_dispaly Screen_control(
	.clk_25(clk_25),
	.clk_100(clk_100),
	.Red_level(Red_level),
	.Green_level(Green_level),
	.Blue_level(Blue_level),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.Red(vga_r_wire),
	.Green(vga_g_wire),
	.Blue(vga_b_wire),
	.h_sync(h_sync_wire),
	.v_sync(v_sync_wire),
	.lcd_db(lcd_db),
	.lcd_reset(lcd_reset),
	.lcd_wr(lcd_wr),
	.lcd_d_c(lcd_d_c),
	.lcd_rd(lcd_rd)
);


// Utilities

// 25M clk generation
/*pll25	pll25_inst(
	.areset(1'b0),
	.inclk0(MAX10_CLK1_50 ),
	.c0(clk_25),
	.c1(clk_50),
	.c2(clk_100),
	.locked()
);*/

wire				clk_12_5;
wire				clk_6_25;
pll6_25 pll6_25_inst(
	.areset(1'b0),
	.inclk0(MAX10_CLK1_50),
	.c0(clk_100),
	.c1(clk_25),
	.c2(clk_12_5),
	.c3(clk_6_25),
	.locked()
);

//7-Seg default assign (all leds are off)
assign HEX0 = 8'b11111111;
assign HEX1 = 8'b11111111;
assign HEX2 = 8'b11111111;
assign HEX3 = 8'b11111111;

// periphery_control module for external units: joystick, wheel and buttons (A,B, Select and Start) 
periphery_control periphery_control_inst(
	.clk(clk_25),
	.A(A),
	.B(B),
	.Select(Select),
	.Start(Start),
	.Right(Right),
	.Left(Left),
	.Up(Up),
	.Down(Down),
	.Wheel(Wheel)
);

wire resetChip8 = Select & A & B;
	
// Leds and 7-Seg show periphery_control outputs
assign LEDR[0] = A; 			// A
assign LEDR[1] = B; 			// B
assign LEDR[2] = Select;	// Select
assign LEDR[3] = Start; 	// Start
assign LEDR[9] = Left; 		// Left
assign LEDR[8] = Right; 	// Right
assign LEDR[7] = Up; 		// UP
assign LEDR[6] = Down; 		// DOWN

seven_segment ss5(
	.in_hex(Wheel[11:8]),
	.out_to_ss(HEX5)
);

seven_segment ss4(
	.in_hex(Wheel[7:4]),
	.out_to_ss(HEX4)
);

wire [15:0] switch_control_external_connection_export;
wire [7:0] periphery_control_external_connection_export;
wire [15:0] video_buffer_external_connection_export;

assign switch_control_external_connection_export[9] = SW[9];
assign switch_control_external_connection_export[8] = SW[8];
assign switch_control_external_connection_export[7] = SW[7];
assign switch_control_external_connection_export[6] = SW[6];
assign switch_control_external_connection_export[5] = SW[5];
assign switch_control_external_connection_export[4] = SW[4];
assign switch_control_external_connection_export[3] = SW[3];
assign switch_control_external_connection_export[2] = SW[2];
assign switch_control_external_connection_export[1] = SW[1];
assign switch_control_external_connection_export[0] = SW[0];

assign periphery_control_external_connection_export[7] = A;
assign periphery_control_external_connection_export[6] = B;
assign periphery_control_external_connection_export[5] = Select;
assign periphery_control_external_connection_export[4] = Start;
assign periphery_control_external_connection_export[3] = Left;
assign periphery_control_external_connection_export[2] = Right;
assign periphery_control_external_connection_export[1] = Up;
assign periphery_control_external_connection_export[0] = Down;

vChip8 vChip8_inst(
/*IN*/	.clk_clk(clk_12_5/*clk_25*//*MAX10_CLK1_50*/),
/*IN*/	.reset_reset_n(~resetChip8/*1'b1*/),
/*IN*/	.switch_control_external_connection_export(switch_control_external_connection_export),
/*IN*/	.periphery_control_external_connection_export(periphery_control_external_connection_export),
/*OUT*/	.video_buffer_external_connection_export(video_buffer_external_connection_export)
);

Video_Buffer Video_Buffer_inst(
/*IN*/	.clock(clk_12_5/*clk_25*/),
/*IN*/	.resetN(~resetChip8/*1'b1*/),
/*IN*/	.buffer_command(video_buffer_external_connection_export),
/*IN*/	.pxl_x(pxl_x),
/*IN*/	.pxl_y(pxl_y),
/*OUT*/	.Red_level(Red_level),
/*OUT*/	.Green_level(Green_level),
/*OUT*/	.Blue_level(Blue_level),
);


endmodule
