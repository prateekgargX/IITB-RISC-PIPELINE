library IEEE;
use IEEE.STD_LOGIC_1164.all;
 
entity mux_2x1_3b is
 port(
 
     x0,x1:in STD_LOGIC_vector(2 downto 0);
     sel:in STD_LOGIC;
     y : out STD_LOGIC_vector(2 downto 0)
  );
end mux_2x1_3b;
 
architecture Behavioral of mux_2x1_3b is
begin
  y <= x0 when sel = '0' else x1; 
end Behavioral;