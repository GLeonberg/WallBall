library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity vga_ctrl is
	port (clk25: in std_logic;
			h, v: out std_logic_vector (9 downto 0);
			hs, vs, vid: out std_logic);
end vga_ctrl;

architecture ctrl of vga_ctrl is
	signal hcount, vcount : std_logic_vector (9 downto 0) := "0000000000";
begin

	-- assign output wires
	h <= hcount;
	v <= vcount;

	-- counters for vertical and horizontal sync pulses
	process (clk25) is begin

		if(rising_edge(clk25)) then
		
			hcount <= hcount + "0000000001";
			
			if(hcount = "1100100000") then
				hcount <= (others => '0');
				vcount <= vcount + "0000000001";
			end if;
			
			if(vcount = "1000001001") then
				vcount <= (others => '0');
			end if;
			
		end if;
	end process;
	
	-- hsync pulse creation
	process (hcount) is begin
		if (hcount >= std_logic_vector(to_unsigned(660, 10) )) and (hcount < std_logic_vector(to_unsigned(756, 10)) )
      then
			hs <= '0';
		else
			hs <= '1';
		end if;
	end process;
	
	-- vsync pulse creation
	process (vcount) is begin
		if (vcount >= std_logic_vector(to_unsigned(494, 10)) ) and (vcount < std_logic_vector(to_unsigned(495, 10)) )
		then
			vs <= '0';
		else
			vs <= '1';
		end if;
	end process;
	
	-- generate video on signal
	process (hcount, vcount) is begin
		if (hcount >= std_logic_vector(to_unsigned(0, 10))) -- 0
		 and (hcount < std_logic_vector(to_unsigned(640, 10))) -- 640
		 and (vcount >= std_logic_vector(to_unsigned(0, 10))) -- 0
		 and (vcount < std_logic_vector(to_unsigned(480, 10))) -- 480
		then
			vid <= '1';
		else
			vid <= '0';
		end if;
	end process;
			
end ctrl;