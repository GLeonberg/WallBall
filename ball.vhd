library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

-- 16x16 square white ball
-- ball is aware of paddle coordinates for collision detection
--
--                         (000, 001, 010, 011, 100, 101, 110, 111)
-- travels in 8 directions (N  , NE , E  , SE , S  , SW , W  , NW ) in binary encoding

-- Undefined Behavior: stuck between paddle and wall, paddle and ceiling, paddle and corner

entity ball is
	port (clk, reset: in std_logic;
			padxbeg, padybeg, padxend, padyend: in std_logic_vector (9 downto 0);
			xaddr, yaddr: in std_logic_vector (3 downto 0);
			pixel: out std_logic_vector (23 downto 0);
			death, point: out std_logic;
			xbeg, ybeg, xend, yend: out std_logic_vector (9 downto 0) );
end ball;

architecture behav of ball is
	signal dir: std_logic_vector(2 downto 0) := "100"; -- direction (45 deg intervals)
	signal x: std_logic_vector(9 downto 0) := "0100110111";
	signal y: std_logic_vector(9 downto 0) := "0000110010";
	signal x2, y2: std_logic_vector(9 downto 0);
	signal dead: std_logic := '0';
begin

	-- assign signals
	xbeg <= x;
	ybeg <= y;
	x2 <= x + 15;
	y2 <= y + 15;
	xend <= x2;
	yend <= y2;
	death <= dead;
	
	-- asynchronously output a white square of pixels
	process(xaddr, yaddr) begin
		case yaddr & xaddr is
			when others =>
				pixel <= "111111111111111111111111";
		end case;
	end process;
	
	-- synchronous point calculation
	process(clk, reset, x, y, x2, y2, padxbeg, padybeg, padxend, padyend) begin
		
		if reset = '1' then
			point <= '0';
		elsif rising_edge(clk) then
			if ((y2 = (padybeg + 1)) and (x < padxend) and (x2 > padxbeg)) then
				point <= '1';
			else
				point <= '0';
			end if;
		end if;
		
	end process;
	
	-- synchronously check for collision events (paddle top, paddle side, wall, ceiling, floor)
	process(clk, reset, padxbeg, padybeg, padxend, padyend, x, y, x2, y2) begin
	
		if reset = '1' then
			dir <= "100";
		
		elsif rising_edge(clk) then
		
			-- paddle top collision
			if (y2 = (padybeg + 1)) and (x < padxend) and (x2 > padxbeg) then
				
				-- left third of paddle, NW
				if x <= padxbeg + 42 then
					dir <= "111";
					
				-- middle third of paddle, N
				elsif x <= padxbeg + 86 then
					dir<= "000"; 
					
				-- right third of paddle, NE
				else
					dir <= "001";	
				end if;
				
			end if;
			
			-- paddle side collision
			if (x2 = padxbeg) or (x = padxend) then 
				-- left side
				if x2 = padxbeg then
					dir <= "110"; -- W
				
				-- right side
				else
					dir <= "010"; -- E	
				end if;
			end if;
			
			-- ceiling collision
			if y = 0 then
				case dir is
					when "000" => dir <= "100"; -- N  => S
					when "001" => dir <= "101"; -- NE => SW
					when "111" => dir <= "011"; -- NW => SE
					when others => dir <= "100"; -- invalid state goes to S
				end case;
			end if;
			
			-- floor collision
			if y2 = 479 then
				dead <= '1';
			end if;
			
			-- wall collision
			if (x = 0) or (x2 = 639) then
				case dir is
					when "111" => dir <= "001"; -- NW => NE
					when "001" => dir <= "111"; -- NE => NW
					when "101" => dir <= "011"; -- SW => SE
					when "011" => dir <= "101"; -- SE => SW
					when "010" => dir <= "110"; -- E  => W
					when "110" => dir <= "010"; -- W  => E
					when others => dir <= "111"; -- invalid states goes to NW
				end case;
			end if;
			
		end if;
		
	end process;
	
	-- synchronously determine position, only when ball not dead
	process(reset, dir, clk) begin
	 
		if reset = '1' then
			x <= "0100110111";
			y <= "0000110010";

		elsif rising_edge(clk) then
			
			if dead = '0' then
			
				case dir is
				
					when "000" => -- N
						x <= x;
						y <= y - 1;
					
					when "001" => -- NE
						x <= x + 1;
						y <= y - 1;
					
					when "010" => -- E
						x <= x + 1;
						y <= y;
					
					when "011" => -- SE
						x <= x + 1;
						y <= y + 1;
					
					when "100" => -- S
						x <= x ;
						y <= y + 1;
					
					when "101" => -- SW
						x <= x - 1;
						y <= y + 1;
					
					when "110" => -- W
						x <= x - 1;
						y <= y;
					
					when "111" => -- NW
						x <= x - 1;
						y <= y - 1;
				
				end case;
				
			end if;
			
		end if;
		
	end process;

end behav;