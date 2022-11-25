
module vChip8 (
	clk_clk,
	periphery_control_external_connection_export,
	reset_reset_n,
	switch_control_external_connection_export,
	video_buffer_external_connection_export);	

	input		clk_clk;
	input	[7:0]	periphery_control_external_connection_export;
	input		reset_reset_n;
	input	[15:0]	switch_control_external_connection_export;
	output	[15:0]	video_buffer_external_connection_export;
endmodule
