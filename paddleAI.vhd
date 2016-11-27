library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity paddleAI is
	port (death: in std_logic;
			padxbeg, padxend: in std_logic_vector (9 downto 0);
			ballxbeg, ballxend: in std_logic_vector (9 downto 0);
			ctrl: out std_logic_vector(3 downto 0) );
end paddleAI;

architecture AI of paddleAI is
begin

	-- "lazy" AI only moves paddle when ball is not directly above paddle
	
	-- eventually devolved "ideal" scenario where ball bounces off center 
	-- of paddle and paddle stops moving
	process(ballxbeg, ballxend, padxbeg, padxend) begin
	
		if death = '0' then
		
			if ballxbeg < padxbeg then
				ctrl <= "0111";
				
			elsif ballxend > padxend then
				ctrl <= "1011";
				
			else
				ctrl <= "1111";
				
			end if;
		
		else
			ctrl <= "1111";
			
		end if;
	
	end process;


end AI;