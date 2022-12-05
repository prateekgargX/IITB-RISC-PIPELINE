library ieee;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all; 
--  A testbench has no ports.
entity countest is

end countest;

architecture behav of countest is
  --  Declaration of the component that will be instantiated.
  component mod8counter is
	port
	(
		clk,en: in std_logic;
		y:out std_logic_vector(2 downto 0)
	);
  end component;
  --  Specifies which entity is bound with the component.
  for DUT: mod8counter use entity work.mod8counter;
  
  signal clk, en : std_logic;
  signal y: std_logic_vector(2 downto 0);
  -- defining parameters to generate clk signal
  constant clk_period : time := 1 ns;
  constant num_cycles : integer := 20;
begin
  --  Component instantiation.
  DUT: mod8counter port map (clk=>clk,en=>en,y=>y);

  process
  begin
    for i in 1 to num_cycles loop
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end loop;
    wait;
    end process;

    process
    begin
        en <='0';
        wait for 0.5 ns;
        en<='1';
        for i in 1 to num_cycles loop
            wait for clk_period;
        end loop;
        wait;
    end process;
  
  --  This process does the real job.
  process
    begin
      --  Check each addr.
    --   for i in 0 to num_cycles-1 loop
    --     --  Set the inputs.
        
    --     -- clk <= '0';
    --     -- en<='1';
    --     if (i mod 2 = 0) or (i mod 3 = 0) then
    --       en <= '0';
    --     else 
    --       en <= '1';
    --     end if;

    --     --  Wait for the results.
    --     wait for 1 ns;
    --   end loop;
    wait for 20 ns;
      assert false report "end of test" severity note;
      --  Wait forever; this will finish the simulation.
      wait;
  end process;

end behav;
