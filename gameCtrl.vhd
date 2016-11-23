library ieee;
use ieee.std_logic_1164.all;

entity gameCtrl is
	port (rstIn, pauseIn, ballDead: in std_logic;
			pause, reset, status: out std_logic);
end gameCtrl;

architecture behav of gameCtrl is
begin

	-- determine reset from rstIn (active low)
	reset <= not rstIn;
	
	-- determine pause from pauseIn (active high)
	pause <= pauseIn;
	
	-- output status of ball (active high)
	status <= ballDead;

end behav;