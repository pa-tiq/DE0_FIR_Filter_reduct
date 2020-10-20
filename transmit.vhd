library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmit is
generic ( 
	Wout 		     : INTEGER 	);
port (
	clk          : in  std_logic ;							
	reset        : in  std_logic ;
	data_enable	 : in  std_logic ;
	data_buffer  : in std_logic_vector( Wout-1 downto 0)
	data_valid   : out std_logic ;
	serial_error : out std_logic ;
	serial_out   : out std_logic );
end transmit;

architecture rtl of transmit is

signal r_data_enable  : std_logic;
signal r_data         : std_logic_vector(Wout-1 downto 0);
signal r_count        : integer range 0 to Wout;

begin
	o_data_valid    <= r_data_enable;
	o_data          <= r_data(Wout-1);
	p_paralle2serial : process(clk,reset)
	begin
  		if(reset='0') then
			r_count              <= Wout-1;
			r_data_enable        <= '0';
			r_data               <= (others=>'0');
			o_error_serialize_pulse    <= '0';
 		elsif(rising_edge(clk)) then
			if(r_count<Wout-1) and (i_data_ena='1') then
	  			o_error_serialize_pulse    <= '1';
			else
	  			o_error_serialize_pulse    <= '0';
			end if;
			if(i_data_ena='1') then
				r_count        <= 0;
				r_data_enable  <= '1';
				r_data         <= i_data;
			elsif(r_count<Wout-1) then
				r_count        <= r_count + 1;
				r_data_enable  <= '1';
				r_data         <= r_data(Wout-2 downto 0)&'0';
			else
			r_data_enable  <= '0';
			end if;
  		end if;
	end process p_paralle2serial;
end rtl;