library ieee;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all; 
--  A testbench has no ports.
entity memtest is
  --port (dout : out std_logic_vector(16 - 1 downto 0));
end memtest;

architecture behav of memtest is
  --  Declaration of the component that will be instantiated.
  component memory is
    generic
    (
      ADDR_WIDTH	: integer := 8; -- bytes of storage/2 OR MAX instructions memory can hold
      DATA_WIDTH	: integer := 16; -- 2 bytes on each addr.
      INIT_FILE   : string  := "LIL_INSTR.txt" -- file to initialize memory from 
    );
    
    port
    (
      clk				: in  std_logic;
      din				: in  std_logic_vector(DATA_WIDTH - 1 downto 0);
      mem_a			: in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      wr_en			: in  std_logic;
      dout			: out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
  end component;

  --  Specifies which entity is bound with the component.
  for RAM: memory use entity work.memory;
  signal clk, w : std_logic;
  signal din: std_logic_vector(16 - 1 downto 0);
  signal dout: std_logic_vector(16 - 1 downto 0);
  signal addr: std_logic_vector(5 - 1 downto 0);
  constant clk_period : time := 1 ns;

begin
  --  Component instantiation.
  RAM: memory generic map( ADDR_WIDTH => 5,DATA_WIDTH => 16,INIT_FILE  => "LIL_INSTR.txt") 
                 port map (       clk  =>clk,
                                  din  =>din,
                                  mem_a=>addr, 
                                  wr_en=> w,
                                  dout => dout
              );

  -- process
  -- begin
  --   clk <= '0';
  --   wait for clk_period/2;
  --   clk <= '1';
  --   wait for clk_period/2;
  -- end process;

  --  This process does the real job.
  process
    begin
      --  Check each addr.
      for i in 0 to 31 loop
        --  Set the inputs.
        
        clk <= '0';

        -- if (i mod 2) = 0 then
        --   clk <= '0';
        -- else 
        --   clk <= '1';
        -- end if;

        din <= x"A72B";

        w <= '1';
        addr <= std_logic_vector(to_unsigned(i, addr'length));

        --  Wait for the results.
        wait for 1 ns;
        --  Check the outputs.
        -- report "0x" & to_hstring(dout);

      end loop;
      assert false report "end of test" severity note;
      --  Wait forever; this will finish the simulation.
      wait;
  end process;

end behav;
