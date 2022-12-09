library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpubench is
end cpubench;

architecture test of cpubench is
  -- constant num_cycles : integer := 50;

  signal clk: std_logic := '1';
  signal reset: std_logic;
  
  component pCPU is
    generic
	(
		DATA_FILE	: string  := "DATA.txt"; --  file to initialize RAM from
		INST_FILE   : string  := "INSTR.txt" -- file to initialize ROM from 
	);

    port
    (
        clk,reset: in std_logic
        --; can add debug signals as outputs like PC_val,IR_val etc.
    );
  end component;

  constant clk_period : time := 1 ns; --1 Ghz

begin

  -- start off with a short reset
  reset <= '1', '0' after 1 ns;

process
begin
    reset <='1';
    wait for 1 ns;
    reset <='0';
end process;

  -- create a clock
  process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  cpuinstance: pCPU generic map(DATA_FILE => "DATA.txt",INST_FILE => "INSTR.txt")
                port map( clk=>clk, reset=>reset);

end test;
