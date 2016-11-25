library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity screenGen is 
	port (vid: in std_logic;
			hcount, vcount: in std_logic_vector (9 downto 0);
			bxbeg, bybeg, bxend, byend: in std_logic_vector (9 downto 0);
			pxbeg, pybeg, pxend, pyend: in std_logic_vector (9 downto 0);
			bpixel, ppixel: in std_logic_vector (23 downto 0);
			pxaddr: out std_logic_vector (6 downto 0);
			pyaddr: out std_logic_vector (3 downto 0);
			bxaddr, byaddr: out std_logic_vector (3 downto 0);
			r, g, b: out std_logic_vector (7 downto 0));
end screenGen;

architecture gen of screenGen is
	signal bxdiff, bydiff, pxdiff, pydiff: std_logic_vector (9 downto 0);
begin

	-- determine indexing addresses for ball and paddle pixels
	bxdiff <= hcount - bxbeg;
	bydiff <= vcount - bybeg;
	pxdiff <= hcount - pxbeg;
	pydiff <= vcount - pybeg;
	
	-- display ball and paddle
	process(hcount, vcount) begin
	
		-- while in visible area and not screen border
		if hcount > 0 and hcount < 639 and vcount > 0 and vcount < 479 then
		
			-- display ball
			if (vid = '1') and (hcount >= bxbeg) and (hcount <= bxend) and
				(vcount >= bybeg) and (vcount <= byend) then
				
				bxaddr <= bxdiff(3 downto 0);
				byaddr <= bydiff(3 downto 0);
				
				r <= bpixel(23 downto 16);
				g <= bpixel(15 downto 8);
				b <= bpixel(7 downto 0);
			
			-- display paddle
			elsif (vid = '1') and (hcount >= pxbeg) and (hcount <= pxend) and
					(vcount >= pybeg) and (vcount <= pyend) then
				
				pxaddr <= pxdiff(6 downto 0);
				pyaddr <= pydiff(3 downto 0);
				
				r <= ppixel(23 downto 16);
				g <= ppixel(15 downto 8);
				b <= ppixel(7 downto 0);
			
			-- display blank space	
			else
			
				r <= (others => '0');
				g <= (others => '0');
				b <= (others => '0');
			
			end if;
		
		-- display blue screen border for centering image
		elsif hcount = 0 or hcount = 639 or vcount = 0 or vcount = 479 then
		
			r <= (others => '0');
			g <= (others => '0');
			b <= (others => '1');
		
		-- blank vga signal for off screen black level calibration
		else
			
			r <= (others => '0');
			g <= (others => '0');
			b <= (others => '0');
		
		end if;
	
	end process;


end gen;