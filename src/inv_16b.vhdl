LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Invert 16-Bits

-- INPUTS: Din,en
-- OUTPUTS: Dout

entity inv_16b is  
  port(en : in std_logic;
       din   		 : in std_logic_vector(15 downto 0);  
       dout  	    : out std_logic_vector(15 downto 0)
      );  
end inv_16b;

architecture struct of inv_16b is       
  begin
	dout <= (x"FFFF" xor din) when en = '1' else (x"0000" xor din) ;
end struct;
