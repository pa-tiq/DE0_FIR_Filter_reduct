library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE n_bit_int IS
	SUBTYPE COEFF_TYPE IS STD_LOGIC_VECTOR(8 DOWNTO 0)	; --Win-1
	TYPE ARRAY_COEFF IS ARRAY (NATURAL RANGE <>) OF COEFF_TYPE;
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE0_FIR_Filter_reduct is
	generic ( 
		Win 			: INTEGER 	:= 9		;-- Input bit width
		Wmult			: INTEGER 	:= 18    	;-- Multiplier bit width 2*Win
		Wadd 			: INTEGER 	:= 26		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 26		;-- Output bit width: between Win and Wadd
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		PATTERN_SIZE	: INTEGER 	:= 256		;
		RANGE_LOW 		: INTEGER 	:= -512		; --pattern range: power of 2
		RANGE_HIGH 		: INTEGER 	:= 511		; --must change pattern too
		LFilter  		: INTEGER 	:= 512		); -- Filter length
port (
	-- ////////////////////	clock input	 	////////////////////	 
	pad_i_clock_50                             : in    std_logic;  --	50 MHz
	pad_i_clock_50_2                           : in    std_logic;  --	50 MHz
	-- ////////////////////	push button		////////////////////
	pad_i_button                               : in    std_logic_vector(2 downto 0);  --	pushbutton[2:0]
	-- ////////////////////	dpdt switch		////////////////////
	pad_i_sw                                   : in    std_logic_vector(9 downto 0);  -- toggle switch[9:0]
	-- ////////////////////	7-seg dispaly	////////////////////
	pad_o_hex0_d                               : out   std_logic_vector(6 downto 0);  -- seven segment digit 0
	pad_o_hex0_dp                              : out   std_logic;                     -- seven segment digit dp 0
	pad_o_hex1_d                               : out   std_logic_vector(6 downto 0);  -- seven segment digit 1
	pad_o_hex1_dp                              : out   std_logic;                     -- seven segment digit dp 1
	pad_o_hex2_d                               : out   std_logic_vector(6 downto 0);  -- seven segment digit 2
	pad_o_hex2_dp                              : out   std_logic;                     -- seven segment digit dp 2
	pad_o_hex3_d                               : out   std_logic_vector(6 downto 0);  -- seven segment digit 3
	pad_o_hex3_dp                              : out   std_logic;                     -- seven segment digit dp 3
	-- ////////////////////////	led		////////////////////////
	pad_o_ledg                                 : out   std_logic_vector(9 downto 0);  -- 	led green[9:0]
	-- ////////////////////////	uart	////////////////////////
	pad_o_uart_tx                              : out   std_logic;  -- uart transmitter
	pad_i_uart_rx                              : in    std_logic;  -- uart receiver
	pad_o_uart_cts                             : out   std_logic;  -- uart clear to send
	pad_i_uart_rts                             : in    std_logic;  -- uart request to send
	-- /////////////////////	sdram interface		////////////////
	pad_b_dram_dq                              : inout std_logic_vector(15 downto 0);  -- sdram data bus 16 bits
	pad_o_dram_addr                            : out   std_logic_vector(12 downto 0);  -- sdram address bus 13 bits
	pad_o_dram_ldqm                            : out   std_logic;  -- sdram low-byte data mask 
	pad_o_dram_udqm                            : out   std_logic;  -- sdram high-byte data mask
	pad_o_dram_we_n                            : out   std_logic;  -- sdram write enable
	pad_o_dram_cas_n                           : out   std_logic;  -- sdram column address strobe
	pad_o_dram_ras_n                           : out   std_logic;  -- sdram row address strobe
	pad_o_dram_cs_n                            : out   std_logic;  -- sdram chip select
	pad_o_dram_ba_0                            : out   std_logic;  -- sdram bank address 0
	pad_o_dram_ba_1                            : out   std_logic;  -- sdram bank address 1
	pad_o_dram_clk                             : out   std_logic;  -- sdram clock
	pad_o_dram_cke                             : out   std_logic;  -- sdram clock enable
	-- ////////////////////	flash interface		////////////////
	pad_b_fl_dq                                : inout std_logic_vector(14 downto 0);  -- flash data bus 15 bits
	pad_b_fl_dq15_am1                          : inout std_logic ;                     -- flash data bus bit 15 or address a-1
	pad_o_fl_addr                              : out   std_logic_vector(21 downto 0);  -- flash address bus 22 bits
	pad_o_fl_we_n                              : out   std_logic;  -- flash write enable
	pad_o_fl_rst_n                             : out   std_logic;  -- flash reset
	pad_o_fl_oe_n                              : out   std_logic;  -- flash output enable
	pad_o_fl_ce_n                              : out   std_logic;  -- flash chip enable
	pad_o_fl_wp_n                              : out   std_logic;  -- flash hardware write protect
	pad_o_fl_byte_n                            : out   std_logic;  -- flash selects 8/16-bit mode
	pad_i_fl_ry                                : in    std_logic;  -- flash ready/busy
	-- ////////////////////	lcd module 16x2		////////////////
	pad_o_lcd_blon                             : out   std_logic;  -- lcd back light on/off
	pad_o_lcd_rw                               : out   std_logic;  -- lcd read/write select, 0 = write, 1 = read
	pad_o_lcd_en                               : out   std_logic;  -- lcd enable
	pad_o_lcd_rs                               : out   std_logic;  -- lcd command/data select, 0 = command, 1 = data
	pad_b_lcd_data                             : inout std_logic_vector(7 downto 0);  -- lcd data bus 8 bits
	-- ////////////////////	sd_card interface	////////////////
	pad_b_sd_dat0                              : inout std_logic;  -- sd card data 0
	pad_b_sd_dat3                              : inout std_logic;  -- sd card data 3
	pad_b_sd_cmd                               : inout std_logic;  -- sd card command signal
	pad_o_sd_clk                               : out   std_logic;  -- sd card clock
	pad_o_sd_wp_n                              : out   std_logic;  -- sd card write protect
	-- ////////////////////	ps2		////////////////////////////
	pad_b_ps2_kbdat                            : inout std_logic;  -- ps2 keyboard data
	pad_b_ps2_kbclk                            : inout std_logic;  -- ps2 keyboard clock
	pad_b_ps2_msdat                            : inout std_logic;  -- ps2 mouse data
	pad_b_ps2_msclk                            : inout std_logic;  -- ps2 mouse clock
	-- ////////////////////	vga		////////////////////////////
	pad_o_vga_hs                               : out   std_logic;  -- vga h_sync
	pad_o_vga_vs                               : out   std_logic;  -- vga v_sync
	pad_o_vga_r                                : out   std_logic_vector(3 downto 0);  -- vga red[3:0]
	pad_o_vga_g                                : out   std_logic_vector(3 downto 0);  -- vga green[3:0]
	pad_o_vga_b                                : out   std_logic_vector(3 downto 0);  -- vga blue[3:0]
	-- ////////////////////	gpio	////////////////////////////
	pad_i_gpio0_clkin                          : in    std_logic_vector(1 downto 0);  -- gpio connection 0 clock in bus
	pad_o_gpio0_clkout                         : out   std_logic_vector(1 downto 0);  -- gpio connection 0 clock out bus
	pad_b_gpio0_d                              : inout std_logic_vector(31 downto 0);  -- gpio connection 0 data bus
	pad_i_gpio1_clkin                          : in    std_logic_vector(1 downto 0);  -- gpio connection 1 clock in bus
	pad_o_gpio1_clkout                         : out   std_logic_vector(1 downto 0);  -- gpio connection 1 clock out bus
	pad_b_gpio1_d                              : inout std_logic_vector(31 downto 0)  -- gpio connection 1 data bus
	);
end DE0_FIR_Filter_reduct;

architecture rtl of DE0_FIR_Filter_reduct is

component fir_filter_test
generic(
	Win 		: INTEGER	; -- Input bit width
	Wmult 		: INTEGER	;-- Multiplier bit width 2*W1
	Wadd 		: INTEGER	;-- Adder width = Wmult+log2(L)-1
	Wout 		: INTEGER	;-- Output bit width
	Lfilter 	: INTEGER	; --Filter Length
	RANGE_LOW 	: INTEGER	; --coeff range: power of 2
	RANGE_HIGH 	: INTEGER	;
	BUTTON_HIGH : STD_LOGIC ;
	PATTERN_SIZE: INTEGER   );
port (
	clk                     : in  std_logic;
	reset                   : in  std_logic;
	o_data_buffer           : out std_logic_vector( Wout-1 downto 0));
end component;

signal w_rstb               : std_logic;
signal w_clk                : std_logic;
signal data_buffer          : std_logic_vector( Wout-1 downto 0); -- to seven segment

begin
-- CLOCK and RESET
w_rstb  <= pad_i_button(0);
w_clk   <= pad_i_clock_50;

-- LED
pad_o_ledg(0)  <= '0';
pad_o_ledg(1)  <= '0';
pad_o_ledg(2)  <= '0';
pad_o_ledg(3)  <= '0';
pad_o_ledg(4)  <= '0';
pad_o_ledg(5)  <= '0';
pad_o_ledg(6)  <= '0';
pad_o_ledg(7)  <= '0';
pad_o_ledg(8)  <= '0';
pad_o_ledg(9)  <= pad_i_button(0);

pad_o_hex0_dp     <= '0';
pad_o_hex1_dp     <= '0';
pad_o_hex2_dp     <= '0';
pad_o_hex3_dp     <= '0'; 

pad_o_hex0_d	<= (others => '0');
pad_o_hex1_d	<= (others => '0');
pad_o_hex2_d	<= (others => '0');
pad_o_hex3_d	<= (others => '0');

pad_b_gpio1_d(0) <= data_buffer(Wout-1);
pad_b_gpio1_d(1) <= data_buffer(Wout-2);
pad_b_gpio1_d(2) <= data_buffer(Wout-3);
pad_b_gpio1_d(3) <= data_buffer(Wout-4);
pad_b_gpio1_d(4) <= data_buffer(Wout-5);
pad_b_gpio1_d(5) <= data_buffer(Wout-6);

u_fir_filter_test : fir_filter_test
generic map(
	Win 	   	=> Win			,
	Wmult 	   	=> Wmult		,
	Wadd 	   	=> Wadd			,
	Wout 	  	=> Wout			,
	Lfilter 	=> Lfilter		,
	RANGE_LOW 	=> RANGE_LOW	,
	RANGE_HIGH 	=> RANGE_HIGH	,
	BUTTON_HIGH => BUTTON_HIGH	,
	PATTERN_SIZE=> PATTERN_SIZE )
port map(
	clk                 	=> w_clk                   ,
	reset                   => w_rstb                  ,
	o_data_buffer           => data_buffer             );

------------------------------------------------------------------------------------------------------------------
-- ASSIGN unused pins
------------------------------------------------------------------------------------------------------------------
	-- ////////////////////////	uart	////////////////////////
	pad_o_uart_tx             <= '1';
	pad_o_uart_cts            <= '1';

	-- /////////////////////	sdram interface		////////////////
	pad_b_dram_dq         <= (others=>'Z');
	pad_o_dram_addr       <= (others=>'0');
	pad_o_dram_ldqm       <= '1';
	pad_o_dram_udqm       <= '1';
	pad_o_dram_we_n       <= '1';
	pad_o_dram_cas_n      <= '1';
	pad_o_dram_ras_n      <= '1';
	pad_o_dram_cs_n       <= '1';
	pad_o_dram_ba_0       <= '1';
	pad_o_dram_ba_1       <= '1';
	pad_o_dram_clk        <= '1';
	pad_o_dram_cke        <= '1';

	-- ////////////////////	flash interface		////////////////
	pad_b_fl_dq           <= (others=>'Z');
	pad_b_fl_dq15_am1     <= 'Z';
	pad_o_fl_addr         <= (others=>'0');
	pad_o_fl_we_n         <= '1';
	pad_o_fl_rst_n        <= '1';
	pad_o_fl_oe_n         <= '1';
	pad_o_fl_ce_n         <= '1';
	pad_o_fl_wp_n         <= '1';
	pad_o_fl_byte_n       <= '1';

	-- ////////////////////	lcd module 16x2		////////////////
	pad_o_lcd_blon        <= '0';
	pad_o_lcd_rw          <= '0';
	pad_o_lcd_en          <= '0';
	pad_o_lcd_rs          <= '0';
	pad_b_lcd_data        <= (others=>'Z');

	-- ////////////////////	sd_card interface	////////////////
	pad_b_sd_dat0         <= 'Z';
	pad_b_sd_dat3         <= 'Z';
	pad_b_sd_cmd          <= 'Z';
	pad_o_sd_clk          <= '0';
	pad_o_sd_wp_n         <= '0';

	-- ////////////////////	ps2		////////////////////////////
	pad_b_ps2_kbdat       <= 'Z';
	pad_b_ps2_kbclk       <= 'Z';
	pad_b_ps2_msdat       <= 'Z';
	pad_b_ps2_msclk       <= 'Z';

	-- ////////////////////	vga		////////////////////////////
	pad_o_vga_hs          <= '0';
	pad_o_vga_vs          <= '0';
	pad_o_vga_r           <= (others=>'0');
	pad_o_vga_g           <= (others=>'0');
	pad_o_vga_b           <= (others=>'0');

	-- ////////////////////	gpio	////////////////////////////
	pad_o_gpio0_clkout    <= "00";
	pad_b_gpio0_d         <= (others=>'Z');
	pad_o_gpio1_clkout    <= "00";
	pad_b_gpio1_d(31 downto 5)          <= (others=>'Z');

end architecture rtl;