library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity clk10 is
	port (clk, pause: in std_logic;
			clk10: out std_logic);
end clk10;

architecture div of clk10 is
	signal s: integer := 0;
	signal ck: std_logic := '0';
begin

	clk10 <= ck;
	
	process(clk) begin
		
		if rising_edge(clk) and pause = '0' then
			s <= s + 1;
		else
			s <= s;
		end if;
		
		if s = 625000 then
			s <= 0;
			ck <=not ck;
		end if;

	end process;

end div;