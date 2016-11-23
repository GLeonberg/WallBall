library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity scoreCount is
	port (clk, reset, point: in std_logic;
			score: out std_logic_vector(7 downto 0));
end scoreCount;

architecture behav of scoreCount is
	signal s: std_logic_vector(7 downto 0);
begin

	-- assign signal
	score <= s;
	
	process(clk, reset) begin
		
		if reset = '1' then
			
			s <= (others => '0');
			
		elsif rising_edge(clk) then
		
			if point = '1' then
			
				s <= s + 1;
			
			else
			
				s <= s;
			
			end if;
		
		end if;
		
	end process;

end behav;