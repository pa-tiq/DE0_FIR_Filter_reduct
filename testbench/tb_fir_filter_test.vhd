library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE n_bit_int IS
	SUBTYPE COEFF_TYPE IS STD_LOGIC_VECTOR(10 DOWNTO 0);
	TYPE ARRAY_COEFF IS ARRAY (NATURAL RANGE <>) OF COEFF_TYPE;
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_fir_filter_test is
	generic( 
		Win 			: INTEGER 	:= 11		;-- Input bit width
		Wmult			: INTEGER 	:= 22    	;-- Multiplier bit width 2*Win
		Wadd 			: INTEGER 	:= 30		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 30		;-- Output bit width: between Win and Wadd
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		PATTERN_SIZE	: INTEGER 	:= 256		;
		RANGE_LOW 		: INTEGER 	:= -1024	; --pattern range: power of 2
		RANGE_HIGH 		: INTEGER 	:= 1023		; --must change pattern too
		LFilter  		: INTEGER 	:= 512		); -- Filter length
end tb_fir_filter_test;

architecture behave of tb_fir_filter_test is

component fir_filter_test
generic( 
	Win 			: INTEGER 	; -- Input bit width
	Wmult			: INTEGER 	;-- Multiplier bit width 2*W1
	Wadd 			: INTEGER 	;-- Adder width = Wmult+log2(L)-1
	Wout 			: INTEGER 	;-- Output bit width
	BUTTON_HIGH 	: STD_LOGIC ;
	PATTERN_SIZE	: INTEGER 	;
	RANGE_LOW 		: INTEGER 	; --pattern range: power of 2
	RANGE_HIGH 		: INTEGER 	; --must change pattern too
	LFilter  		: INTEGER 	); -- Filter length
port (
	clk                   	: in  std_logic;
	reset                  	: in  std_logic;
	o_data_buffer           : out std_logic_vector( Wout-1 downto 0);
	o_fir_coeff             : out std_logic_vector( Win-1 downto 0);
	o_input                 : out std_logic_vector( Win-1 downto 0);
	read_out                : out integer );
end component;

signal clk                     : std_logic:='0';
signal reset                   : std_logic;
signal read_out                : integer;
signal o_data_buffer           : std_logic_vector( Wout-1 downto 0);
signal o_fir_coeff             : std_logic_vector( Win-1 downto 0);
signal o_input             : std_logic_vector( Win-1 downto 0);

begin

clk   <= not clk after 5 ns;
reset  <= '0', '1' after 132 ns;

u_fir_filter_test : fir_filter_test
generic map( 
	Win 	   	 => Win			 ,
	Wmult 	   	 => Wmult		 ,
	Wadd 	   	 => Wadd		 ,
	Wout 	  	 => Wout		 ,
	LFilter 	 => LFilter		 ,
	RANGE_LOW 	 => RANGE_LOW	 ,
	RANGE_HIGH 	 => RANGE_HIGH	 ,
	BUTTON_HIGH  => BUTTON_HIGH	 ,
	PATTERN_SIZE => PATTERN_SIZE )
port map(
	clk              	 => clk                  ,
	reset                => reset                ,
	o_data_buffer        => o_data_buffer        ,	
	o_fir_coeff          => o_fir_coeff        ,
	o_input				 => o_input,	
	read_out             => read_out        );	

p_dump  : process(reset,read_out)
file x   : text open write_mode is "x.txt";
file f   : text open write_mode is "f.txt";
file y   : text open write_mode is "y.txt";
file yr   : text open write_mode is "yr.txt";
file yi   : text open write_mode is "yi.txt";
variable row          : line;
begin
  
	if(reset='0') then
	------------------------------------
	-->>>>>>>>>>>>>> x*f=y
	--else
	--	if(read_out>=0) then
	--		if(read_out<512) then
	--			write(row,to_integer(signed(o_fir_coeff)), left, 10);			
	--			writeline(f,row);
	--			write(row,to_integer(signed(o_input)), left, 10);			
	--			writeline(x,row);
	--		end if;
	--		if(read_out>3 and read_out<1024+4) then
	--			write(row,to_integer(signed(o_data_buffer)), left, 10);			
	--			writeline(y,row);
	--		end if;
	--	end if;
	--end if;
	-----------------------------------
	-->>>>>>>>>>>> OFDM
	elsif(read_out<1572 and read_out>=0) then
		write(row,to_integer(signed(o_data_buffer)), left, 11);			
		writeline(yi,row);
	end if; 
	--------------------------------------
end process p_dump;

end behave;

