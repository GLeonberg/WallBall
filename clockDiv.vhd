library ieee;
use ieee.std_logic_1164.all;

entity clockDiv is
	port (clk: in std_logic;
			div: out std_logic);
end clockDiv;

architecture div of clockDiv is
	signal newclk : std_logic := '0';
begin

	div <= newclk;

	process(clk) begin
		if rising_edge(clk) then
			newclk <= not newclk;
		end if;
	end process;

end div;