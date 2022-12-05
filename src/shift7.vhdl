library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

-- Shift by 7
-- Extends 9bit vector to 16bit vector, significant bits are filled 

-- INPUTS: din
-- OUTPUTS: dout


entity shift7 is
  port ( din  : in std_logic_vector(8 downto 0) ;
         dout	: out std_logic_vector(15 downto 0) 
			) ;
end entity shift7 ;

architecture Struct of shift7 is
begin 
  dout(6 downto 0) <= (others =>'0') ;
  dout(15 downto 7) <= din;
 --   dout <= std_logic_vector(resize(unsigned(ir_5_0), dout'length));
end Struct;