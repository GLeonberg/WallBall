library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity clk40 is
	port (clk, pause: in std_logic;
			clk40: out std_logic);
end clk40;

architecture div of clk40 is
	signal s: integer := 0;
	signal ck: std_logic := '0';
begin

	clk40 <= ck;
	
	process(clk) begin
		
		if rising_edge(clk) and pause = '0' then
			s <= s + 1;
		else
			s <= s;
		end if;
		
		if s = 312500 then
			s <= 0;
			ck <=not ck;
		end if;

	end process;

end div;