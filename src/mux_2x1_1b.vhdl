library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux_2x1_1b is
 port(
 
     x0,x1:in STD_LOGIC;
     sel:in STD_LOGIC;
     y : out STD_LOGIC
  );
end mux_2x1_1b ;
 
architecture Behavioral of mux_2x1_1b  is

begin
  y <= x0 when sel = '0' else x1; 
end Behavioral;