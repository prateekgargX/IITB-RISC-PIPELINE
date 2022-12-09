library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- 1x2 Demultiplexer 16-Bits

-- INPUTS: x,sel
-- OUTPUTS: y0,y1

entity demux_1x2_16b is
  port
  (
     x:in STD_LOGIC_vector(15 downto 0);
     sel:in STD_LOGIC;
     y0, y1 : out STD_LOGIC_vector(15 downto 0)
  );
end demux_1x2_16b ;
 
architecture Behavioral of demux_1x2_16b  is
begin
  dem: process (x,sel)
    begin
      if sel = '0' then
        y0<=x;
        y1<=x"0000";
      else
        y1<=x;
        y0<=x"0000";
      end if;
  end process;

end Behavioral;