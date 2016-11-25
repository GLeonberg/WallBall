library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity paddle is
	port (clk, reset: in std_logic;
			ctrl: in std_logic_vector(3 downto 0);
			xaddr: in std_logic_vector(6 downto 0);
			yaddr: in std_logic_vector(3 downto 0);
			pixel: out std_logic_vector(23 downto 0);
			xbeg, ybeg, xend, yend: out std_logic_vector(9 downto 0));
end paddle;

architecture rom of paddle is
	signal x, x2: std_logic_vector (9 downto 0) := "0011111111";
	signal y, y2: std_logic_vector (9 downto 0) := "0110101110";
begin

	-- assign signals
	xbeg <= x;
	ybeg <= y;
	x2 <= x + 127;
	y2 <= y + 15;
	xend <= x2;
	yend <= y2;
	
	-- if keys pressed, update paddle position
	process(ctrl, clk, reset) begin
	
		if reset = '1' then
			x <= "0011111111";
			y <= "0110101110";
		
		elsif rising_edge(clk) then
		
			if ctrl(3) = '0' and x > 0 then
				x <= x - 1;
			end if;
			
			if ctrl(2) = '0' and x2 < 640 then
				x <= x + 1;
			end if;
			
			if ctrl(1) = '0' and y > 0 then
				y <= y - 1;
			end if;
			
			if ctrl(0) = '0' and y2 < 480 then
				y <= y + 1;
			end if;
			
		end if;
		
	end process;
	
	-- get pixel rgb values
	process(xaddr, yaddr) begin
	
		case yaddr & xaddr is
		
			when others => pixel <= "111111110000000000000000";
			
		end case;
	
	end process;

end rom;