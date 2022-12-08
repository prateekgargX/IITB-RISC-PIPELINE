library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity adder is
    generic
	(
		DATA_WIDTH	: integer := 16 
    );

    port 
    (
	    a,b  : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
	    y    : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0));
end adder ;

architecture Behavioral of adder is
begin

    y<= std_logic_vector(unsigned(a) + unsigned(b));
end Behavioral;