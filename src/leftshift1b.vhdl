library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

-- Shift by 7
-- Extends 9bit vector to 16bit vector, significant bits are filled 

-- INPUTS: din
-- OUTPUTS: dout


entity shiftleft is
  port ( en : in std_logic;
         din  : in std_logic_vector(15 downto 0) ;
         dout	: out std_logic_vector(15 downto 0) 
			) ;
end entity shiftleft ;

architecture Struct of shiftleft is
begin 

    process(din,en) begin
        if en  = '1' then
        dout(0) <= '0' ;
        dout(15 downto 1) <= din(14 downto 0);
        else
        dout <= din;
        end if;
    end process;
    
end Struct;