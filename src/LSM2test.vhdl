library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity LSMtest is
end LSMtest;

architecture behav of LSMtest is
  
  component LSM is
    port
    (   inp                 :in std_logic_vector(7 downto 0);
        clk,LM_SM,reset     :in std_logic;
        reg_addr,mem_addr   :out std_logic_vector(2 downto 0);
        PC_en,w_en,t_en     :out std_logic);
  end component;

  for DUT: LSM use entity work.LSM;
  signal LM_SM: std_logic:='0';
  signal clk,PC_en,reset,w_en,t_en: std_logic;
  signal reg_addr,mem_addr: std_logic_vector(2 downto 0);
  signal mask: std_logic_vector(7 downto 0):= "01010000";

  constant clk_period : time := 1 ns;
  constant num_cycles : integer := 10;
begin
  --  Component instantiation.
  DUT: LSM port map (inp=> mask,clk=>clk,LM_SM=>LM_SM,reset=>reset,reg_addr=>reg_addr,mem_addr=>mem_addr,PC_en=>PC_en,w_en=>w_en,t_en=>t_en);
    reset<='0';
  process --generates clock at the given rate for required number of cycles.
  begin
    for i in 1 to num_cycles loop
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end loop;
    wait;
  end process;

    process(clk) begin
    if(clk='1' and clk' event) then
        LM_SM <= '1';
        mask  <= "01010000";
    end if;
    end process;

end behav;
