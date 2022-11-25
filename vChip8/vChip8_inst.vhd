	component vChip8 is
		port (
			clk_clk                                      : in  std_logic                     := 'X';             -- clk
			periphery_control_external_connection_export : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- export
			reset_reset_n                                : in  std_logic                     := 'X';             -- reset_n
			switch_control_external_connection_export    : in  std_logic_vector(15 downto 0) := (others => 'X'); -- export
			video_buffer_external_connection_export      : out std_logic_vector(15 downto 0)                     -- export
		);
	end component vChip8;

	u0 : component vChip8
		port map (
			clk_clk                                      => CONNECTED_TO_clk_clk,                                      --                                   clk.clk
			periphery_control_external_connection_export => CONNECTED_TO_periphery_control_external_connection_export, -- periphery_control_external_connection.export
			reset_reset_n                                => CONNECTED_TO_reset_reset_n,                                --                                 reset.reset_n
			switch_control_external_connection_export    => CONNECTED_TO_switch_control_external_connection_export,    --    switch_control_external_connection.export
			video_buffer_external_connection_export      => CONNECTED_TO_video_buffer_external_connection_export       --      video_buffer_external_connection.export
		);

