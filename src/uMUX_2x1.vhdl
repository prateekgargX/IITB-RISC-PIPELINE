library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity uMUX is
    generic
	(
		DATA_WIDTH	: integer := 16 
    );
	port 
    (
        x0,x1    : in std_logic_vector(DATA_WIDTH-1 downto 0);
	    sel  : in STD_LOGIC ;
	    y    : out std_logic_vector(DATA_WIDTH-1 downto 0));
end uMUX ;

architecture Behavioral of uMUX is
begin
    y <= x0 when sel = '0' else x1; 
end Behavioral;