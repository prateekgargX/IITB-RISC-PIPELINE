library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity COMPARATOR is
    generic
	(
		DATA_WIDTH	: integer := 16 
    );

    port 
    (
	    a,b  : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
	    y    : out std_logic);
end COMPARATOR ;

architecture Behavioral of COMPARATOR is
begin

    y<= '1' when a = b else '0';
end Behavioral;