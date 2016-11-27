library ieee;
use ieee.std_logic_1164.all;

entity pongTop is
	port (CLOCK_50: in std_logic;
			KEY: in std_logic_vector (3 downto 0);
			SW: in std_logic_vector (2 downto 0);
			HEX0, HEX1: out std_logic_vector (6 downto 0);
			LEDR: out std_logic_vector (0 downto 0);
			VGA_R, VGA_G, VGA_B: out std_logic_vector (7 downto 0);
			VGA_HS, VGA_VS: out std_logic;
			VGA_BLANK_N, VGA_SYNC_N, VGA_CLK: out std_logic);
end pongTop;

architecture structural of pongTop is

	-- 25 MHz clock divider
	component clockDiv
	port (clk: in std_logic;
			div: out std_logic);
	end component;
	
	-- VGA sync pulse controller
	component vga_ctrl
	port (clk25: in std_logic;
			h, v: out std_logic_vector (9 downto 0);
			hs, vs, vid: out std_logic);
	end component;
	
	-- score counter
	component scoreCount
	port (clk, reset, point: in std_logic;
			score: out std_logic_vector(7 downto 0));
	end component;

	-- game state controller
	component gameCtrl is
	port (rstIn, pauseIn, ballDead: in std_logic;
			pause, reset, status: out std_logic);
	end component;
	
	-- seven segment decoder
	component fourBinToSevenSeg
	port (bin: in std_logic_vector(3 downto 0);
			hex: out std_logic_vector(6 downto 0) );	
	end component;
	
	-- pixel generator
	component screenGen 
	port (vid: in std_logic;
			hcount, vcount: in std_logic_vector (9 downto 0);
			bxbeg, bybeg, bxend, byend: in std_logic_vector (9 downto 0);
			pxbeg, pybeg, pxend, pyend: in std_logic_vector (9 downto 0);
			bpixel, ppixel: in std_logic_vector (23 downto 0);
			pxaddr: out std_logic_vector (6 downto 0);
			pyaddr: out std_logic_vector (3 downto 0);
			bxaddr, byaddr: out std_logic_vector (3 downto 0);
			r, g, b: out std_logic_vector (7 downto 0));
	end component;
	
	-- ball module
	component ball
	port (clk, reset: in std_logic;
			padxbeg, padybeg, padxend, padyend: in std_logic_vector (9 downto 0);
			xaddr, yaddr: in std_logic_vector (3 downto 0);
			pixel: out std_logic_vector (23 downto 0);
			death, point: out std_logic;
			xbeg, ybeg, xend, yend: out std_logic_vector (9 downto 0) );
	end component;
	
	-- paddle module
	component paddle
	port (clk, reset: in std_logic;
			ctrl: in std_logic_vector(3 downto 0);
			xaddr: in std_logic_vector(6 downto 0);
			yaddr: in std_logic_vector(3 downto 0);
			pixel: out std_logic_vector(23 downto 0);
			xbeg, ybeg, xend, yend: out std_logic_vector(9 downto 0));
	end component;
	
	-- paddle AI module
	component paddleAI
		port (death: in std_logic;
				padxbeg, padxend: in std_logic_vector (9 downto 0);
				ballxbeg, ballxend: in std_logic_vector (9 downto 0);
				ctrl: out std_logic_vector(3 downto 0) );
	end component;
	
	-- intermediate signals for wiring
	signal CLOCK_25, CLOCK_60, horz, vert, vidOn, reset, pause, dead, point, aiCtrl: std_logic;
	signal hcount, vcount, bxbeg, bybeg, bxend, byend, pxbeg, pybeg, pxend, pyend: std_logic_vector (9 downto 0);
	signal bxaddr, byaddr, pyaddr, ctrl, padCtrl: std_logic_vector (3 downto 0);
	signal pxaddr: std_logic_vector (6 downto 0);
	signal bpixel, ppixel: std_logic_vector (23 downto 0);
	signal score: std_logic_vector (7 downto 0);

begin

	-- game updates during vertical sync pulse (old version)
	CLOCK_60 <= (not vert) and (not pause);
	
	-- assign vga control signals
	VGA_CLK <= CLOCK_25; 
	VGA_HS <= horz;
	VGA_VS <= vert;
	VGA_BLANK_N <= '1';
	VGA_SYNC_N <= '1';
	
	-- AI control selection switch
	aiCtrl <= SW(2);
	
	-- AI control application determination
	process(CLOCK_60, aiCtrl) begin
		if rising_edge(CLOCK_60) then
			if aiCtrl = '1' and KEY = "1111" then
				padCtrl <= ctrl;
			else
				padCtrl <= KEY;
			end if;
		end if;
	end process;
	
	-- 25 mHz clock
	clock25: clockDiv port map (CLOCK_50, CLOCK_25);
	
	-- vga sync controller
	ctr: vga_ctrl port map (CLOCK_25, hcount, vcount, horz, vert, vidOn);
	
	-- game state controller
	gctrl: gameCtrl port map (SW(1), SW(0), dead, pause, reset, LEDR(0));
	
	-- score counter
	sc: scoreCount port map (CLOCK_60, reset, point, score);
	
	-- score display units
	scoreD1: fourBinToSevenSeg port map (score(7 downto 4), HEX1);
	scoreD0: fourBinToSevenSeg port map (score(3 downto 0), HEX0);
	
	-- paddle module
	pad: paddle port map (CLOCK_60, reset, padCtrl, pxaddr, pyaddr, ppixel, pxbeg, pybeg, pxend, pyend);
	
	-- paddle AI module
	padAI: paddleAI port map (dead, pxbeg, pxend, bxbeg, bxend, ctrl);
	
	-- ball module
	bal: ball port map (	CLOCK_60, reset, pxbeg, pybeg, pxend, pyend, bxaddr, byaddr,
								 bpixel, dead, point, bxbeg, bybeg, bxend, byend);
								
	-- pixel generator
	screen: screenGen port map (	vidOn, hcount, vcount, bxbeg, bybeg, bxend, byend,
											pxbeg, pybeg, pxend, pyend, bpixel, ppixel, pxaddr,
											pyaddr, bxaddr, byaddr, VGA_R, VGA_G, VGA_B);										

end structural;