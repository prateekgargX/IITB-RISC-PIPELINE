library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package mux_p is
    constant SEL_WIDTH	: integer := 8; 
    constant DATA_WIDTH	: integer := 16;
    type logic_array is array (0 to (2**SEL_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
end package;
  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.mux_p.all;

entity uMUX is
    generic
	(
		SEL_WIDTH	: integer := 8; 
		DATA_WIDTH	: integer := 16 
    );
	port 
    (
        --x    : in array(0 to (2**SEL_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
        x    : in logic_array;
	    sel  : in STD_LOGIC_VECTOR (SEL_WIDTH-1 downto 0);
	    y    : out std_logic_vector(DATA_WIDTH-1 downto 0));
end uMUX ;

architecture Behavioral of uMUX is
begin

    y<=x(to_integer(unsigned(sel)));
    -- process (x,sel)
-- begin
-- 	case sel is
-- 	when "000"=>y<=x(0);
-- 	when "001"=>y<=x(1);
-- 	when "010"=>y<=x(2);
-- 	when "011"=>y<=x(3);
-- 	when "100"=>y<=x(4);
-- 	when "101"=>y<=x(5);
-- 	when "110"=>y<=x(6);
-- 	when "111"=>y<=x(7);
-- 	when others=> null;
-- 	end case;
-- end process;
end Behavioral;