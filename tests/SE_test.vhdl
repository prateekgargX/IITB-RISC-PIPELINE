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
      component SE6_16b is
        port ( din : in std_logic_vector(5 downto 0) ;
               dout	: out std_logic_vector(15 downto 0) 
                  ) ;
     end component;
    
      --  Specifies which entity is bound with the component.
      for DUT: SE6_16b use entity work.SE6_16b;
        signal din : std_logic_vector(5 downto 0);
        signal dout: std_logic_vector(15 downto 0);  
      begin
      --  Component instantiation.
      DUT: SE6_16b port map (din => din,dout =>dout);
    
      --  This process does the real job.
      process
        
      begin
        --  Check each pattern.
        for i in -32 to 31 loop
               
            din <= std_logic_vector(to_signed(i, din'length));
          --  Wait for the results.
                    wait for 1 ns;

        end loop;

        assert false report "end of test" severity note;
        --  Wait forever; this will finish the simulation.
        wait;
      end process;
    
end behav;