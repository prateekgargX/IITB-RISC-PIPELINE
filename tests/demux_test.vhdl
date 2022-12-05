library ieee;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all; 
--  A testbench has no ports.
entity testy is

end testy;
    
architecture behav of testy is
      --  Declaration of the component that will be instantiated.
      component demux_1x2_16b is
        port
        (
           x:in STD_LOGIC_vector(15 downto 0);
           sel:in STD_LOGIC;
           y0, y1 : out STD_LOGIC_vector(15 downto 0)
        );  
      end component;
    
      --  Specifies which entity is bound with the component.
      for DUT: demux_1x2_16b use entity work.demux_1x2_16b;
        signal sel : std_logic;
        signal x,y0,y1:std_logic_vector(15 downto 0);  
      begin
      --  Component instantiation.
      DUT: demux_1x2_16b port map(x=>x,sel=>sel,y0=>y0,y1=>y1);
      --  This process does the real job.
      process
        -- type pattern_type is record
        --   --  The inputs of the adder.
        --   i0, i1, ci : bit;
        --   --  The expected outputs of the adder.
        --   s, co : bit;
        -- end record;
        --  The patterns to apply.
        -- type pattern_array is array (natural range <>) of std_logic_vector(1 downto 0);
        -- constant patterns : pattern_array :=
        --   (('0', '0', '0', '0', '0'),
        --    ('0', '0', '1', '1', '0'),
        --    ('0', '1', '0', '1', '0'),
        --    ('0', '1', '1', '0', '1'),
        --    ('1', '0', '0', '1', '0'),
        --    ('1', '0', '1', '0', '1'),
        --    ('1', '1', '0', '0', '1'),
        --    ('1', '1', '1', '1', '1'));
      begin
        --  Check each pattern.
        for i in 0 to 31 loop
               
            --  Set the inputs.
            if (i mod 3) = 0 or (i mod 2) = 0 then
                sel <= '0';
            else 
                sel <= '1';
            end if;
      
            x <= std_logic_vector(to_unsigned(i, x'length));
          --  Wait for the results.
                    wait for 1 ns;

        end loop;

        assert false report "end of test" severity note;
        --  Wait forever; this will finish the simulation.
        wait;
      end process;
    
end behav;