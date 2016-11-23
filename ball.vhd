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
			flags: out std_logic_vector (3 downto 0);
			pixel: out std_logic_vector (23 downto 0);
			death, point: out std_logic;
			xbeg, ybeg, xend, yend: out std_logic_vector (9 downto 0) );
end ball;

architecture behav of ball is
	signal dir: std_logic_vector(2 downto 0) := "100"; -- direction (45 deg intervals)
	signal x: std_logic_vector(9 downto 0) := "0100110111";
	signal y: std_logic_vector(9 downto 0) := "0000110010";
	signal x2, y2: std_logic_vector(9 downto 0);
	signal padCol, padSideCol, wallCol, ceilCol, dead, colReset: std_logic := '0';
begin

	-- assign signals
	xbeg <= x;
	ybeg <= y;
	x2 <= x + 15;
	y2 <= y + 15;
	xend <= x2;
	yend <= y2;
	death <= dead;
	point <= padCol;
	flags <= padCol & padSideCol & wallCol & ceilCol;
	
	-- asynchronously output a white square of pixels
	process(xaddr, yaddr) begin
		case yaddr & xaddr is
			when others =>
				pixel <= "111111111111111111111111";
		end case;
	end process;
	
	-- synchronously check for collision events (paddle top, paddle side, wall, ceiling, floor)
	process(clk, reset, padxbeg, padybeg, padxend, padyend, x, y, x2, y2) begin
	
		if colReset = '1' then
		
			padCol <= '0';
			padSideCol <= '0';
			ceilCol <= '0';
			dead <= '0';
			wallCol <= '0';
		
		elsif rising_edge(clk) then
		
			-- paddle top collision
			if (y2 = (padybeg + 1)) and (x < padxend) and (x2 > padxbeg) then
				padCol <= '1';
				
			-- paddle side collision
			elsif ((x2 = padxbeg-1) or (x = padxend+1)) and ((y2 <= padybeg) and (y >= padyend)) then 
				padSideCol <= '1';
				
			-- ceiling collision
			elsif y <= 0 then
				ceilCol <= '1';
				
			-- floor collision
			elsif y2 >= 479 then
				dead <= '1';
				
			-- wall collision
			elsif (x <= 0) or (x2 >= 639) then
				wallCol <= '1';
	
			end if;
			
		end if;
		
	end process;
	
	-- synchronously process collisions
	-- NOTE: for upper corners, ceiling takes precedence over wall
	-- NOTE: for lower corners, floor takes precedence over wall
	process(clk, reset, padCol, padSideCol, wallCol, ceilCol) begin
	
		if reset = '1' then
			dir <= "100";
		
		elsif rising_edge(clk) then
			-- process collision with celing
			if ceilCol = '1' then
				case dir is
					when "000" => dir <= "100"; -- N  => S
					when "001" => dir <= "101"; -- NE => SW
					when "111" => dir <= "011"; -- NW => SE
					when others => dir <= "100"; -- invalid state goes to S
				end case; 
				colReset <= '1';
				
			-- process collision with wall
			elsif wallCol = '1' then
				case dir is
					when "111" => dir <= "001"; -- NW => NE
					when "001" => dir <= "111"; -- NE => NW
					when "101" => dir <= "011"; -- SW => SE
					when "011" => dir <= "101"; -- SE => SW
					when "010" => dir <= "110"; -- E  => W
					when "110" => dir <= "010"; -- W  => E
					when others => dir <= "111"; -- invalid states goes to NW
				end case;
				colReset <= '1';
				
			-- process collision with paddle
			elsif padCol = '1' then
			
				colReset <= '1';
				
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
			
			-- process collision with side of paddle
			elsif padSideCol = '1' then
			
				colReset <= '1';
				
				-- left side
				if x2 = padxbeg then
					dir <= "110"; -- W
				
				-- right side
				else
					dir <= "010"; -- E
					
				end if;
				
			-- no collision processing needed
			else
				dir <= dir;
				
			end if;
			
		end if;
		
	end process;
	
	-- synchronously determine movement, only when ball not dead
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