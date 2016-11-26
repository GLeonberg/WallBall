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
			if y = 0 then
				point <= '1';
			else
				point <= '0';
			end if;
		end if;
		
	end process;
	
	-- synchronously determine whether paddle is dead or not
	process(clk, reset, y2) begin
	
		if reset = '1' then 
			dead <= '0';
			
		elsif rising_edge(clk) then
			if y2 = 479 then
				dead <= '1';
			end if;
		end if;
		
	end process;
	
	-- synchronously check for collision events (paddle top, paddle side, wall, ceiling)
	process(clk, reset, dir, padxbeg, padybeg, padxend, padyend, x, y, x2, y2) begin
	
		if reset = '1' then
			dir <= "100";
			x <= "0100110111";
			y <= "0000110010";
		
		elsif rising_edge(clk) then
		
			if dead = '0' then
				-- paddle top collision
				if (y2 = (padybeg-1)) and (x < padxend) and (x2 > padxbeg) then
					
					-- left third of paddle, NW
					if x <= padxbeg + 42 then
						dir <= "111";
						x <= x - 1;
						y <= y - 1;
						
					-- middle third of paddle, N
					elsif x <= padxbeg + 86 then
						dir<= "000";
						x <= x;
						y <= y - 1;	
						
					-- right third of paddle, NE
					else
						dir <= "001";	
						x <= x + 1;
						y <= y - 1;
					end if;
				
				-- paddle side collision
				elsif ((x2 = padxbeg-1) or (x = padxend+1)) and (y < padyend) and (y2 > padybeg) then 
				
					-- left side
					if x2 = padxbeg-1 then
						dir <= "110"; -- W
						x <= x - 1;
						y <= y;
					
					-- right side
					else
						dir <= "010"; -- E	
						x <= x + 1;
						y <= y;
					end if;
				
				-- ceiling collision
				elsif y = 0 then
					case dir is
					
						when "000" => 
							dir <= "100"; -- N  => S
							x <= x;
							y <= y + 1;
							
						when "001" => 
							dir <= "101"; -- NE => SW
							x <= x - 1;
							y <= y + 1;
						
						when "111" => 
							dir <= "011"; -- NW => SE
							x <= x + 1;
							y <= y + 1;
						
						when others => 
							dir <= "100"; -- invalid state goes to S
							x <= x;
							y <= y + 1;
						
					end case;
				
				-- wall collision
				elsif (x = 0) or (x2 = 639) then
					case dir is
						when "111" => 
							dir <= "001"; -- NW => NE
							x <= x + 1;
							y <= y - 1;
							
						when "001" => 
							dir <= "111"; -- NE => NW
							x <= x - 1;
							y <= y - 1;
							
						when "101" => 
							dir <= "011"; -- SW => SE
							x <= x + 5;
							y <= y + 5;
							
						when "011" => 
							dir <= "101"; -- SE => SW
							x <= x - 5;
							y <= y + 5;
							
						when "010" => 
							dir <= "110"; -- E  => W
							x <= x - 1;
							y <= y;
							
						when "110" => 
							dir <= "010"; -- W  => E
							x <= x + 1;
							y <= y;
							
						when others => 
							dir <= "111"; -- invalid states and NE go to NW
							x <= x - 1;
							y <= y - 1;
							
					end case;
				
				else
				
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
							x <= x - 1;
							y <= y + 1;
								
						when "100" => -- S
							x <= x;
							y <= y + 1;
								
						when "101" => -- SW
							x <= x + 1;
							y <= y + 1;
								
						when "110" => -- W
							x <= x - 1;
							y <= y;
								
						when "111" => -- NW
							x <= x - 1;
							y <= y - 1;
							
						when others => -- assume N for invalid state
							x <= x;
							y <= y - 1;
				
					end case;
					
				end if;
				
			end if;
			
		end if;
		
	end process;

end behav;