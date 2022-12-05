library ieee;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all; 
--  A testbench has no ports.
entity LSMtest is

end LSMtest;

architecture behav of LSMtest is
  --  Declaration of the component that will be instantiated.
  component LSM is
    port
    (
      clk,reset : in std_logic;
          LM_SM: in std_logic; --tells if current executing instrucion is LM/SM
          din  : in std_logic_vector(15 downto 0); --RA
          PC_en: out std_logic;
          dout : out std_logic_vector(15 downto 0); 
      count: out std_logic_vector(2 downto 0)
    );    
  end component;
  --  Specifies which entity is bound with the component.
  for DUT: LSM use entity work.LSM;
  
  signal clk,LM_SM,PC_en,reset: std_logic;
  signal count: std_logic_vector(2 downto 0);
  signal dout : std_logic_vector(15 downto 0); 

  -- defining parameters to generate clk signal
  constant clk_period : time := 1 ns;
  constant num_cycles : integer := 20;
begin
  --  Component instantiation.
  DUT: LSM port map (clk=>clk,reset=>reset,LM_SM=>LM_SM,din=>x"FA04",PC_en=>PC_en,dout=>dout,count=>count);
  --reset <= '1', '0' after 0.5 ns;

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
        LM_SM <='0';
        wait for 0.5 ns;
        LM_SM <='1';
        for i in 1 to num_cycles loop
            wait for clk_period;
        end loop;
        wait;
    end process;
  
  --  This process does the real job.
  process
    begin
    wait for 30 ns;
      assert false report "end of test" severity note;
      --  Wait forever; this will finish the simulation.
      wait;
  end process;

end behav;
