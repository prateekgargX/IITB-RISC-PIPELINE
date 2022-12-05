library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity SE9_16b is
  port ( din : in std_logic_vector(8 downto 0) ;
         dout	: out std_logic_vector(15 downto 0) 
			) ;
end entity SE9_16b ;

architecture Struct of SE9_16b is
begin 
  dout(8 downto 0) <= din ;
  dout(15 downto 9) <= (others =>din(7));
 --   dout <= std_logic_vector(resize(unsigned(ir_5_0), dout'length));
end Struct;