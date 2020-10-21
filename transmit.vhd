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
	data_in      : in std_logic_vector( Wout-1 downto 0);
	data_valid   : out std_logic ;
	serial_error : out std_logic ;
	serial_out   : out std_logic );
end transmit;

architecture rtl of transmit is

signal valid_to_transmit  : std_logic;
signal r_data             : std_logic_vector(Wout-1 downto 0);
signal out_data           : std_logic;
signal count              : integer range 0 to Wout;

begin
	data_valid    <= valid_to_transmit;
	serial_out    <= out_data;
	parallel2serial : process(clk,reset)
	begin
  		if(reset='0') then
			count                <= Wout-1;
			valid_to_transmit    <= '0';
			r_data               <= (others=>'0');
			serial_error         <= '0';
 		elsif(rising_edge(clk)) then
			if(count<Wout-1) and (data_enable='1') then
				serial_error    <= '1';
			else
				serial_error    <= '0';
			end if;
			if(data_enable='1') then
				count             <= 0;
				valid_to_transmit <= '0';
				r_data            <= data_in;
			elsif(count<Wout-1) then
				count             <= count + 1;
				valid_to_transmit <= '1';
				out_data          <= r_data(count);
			else
				valid_to_transmit  <= '0';
			end if;
  		end if;
	end process parallel2serial;
end rtl;