library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity uReg is
    generic
	(
		DATA_WIDTH	: integer := 16 
    );
	port 
    (
        clk,reset,wr_en  : in std_logic;
        din   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
	    dout  : out std_logic_vector(DATA_WIDTH-1 downto 0));
end uReg ;

architecture Behavioral of uReg is
begin
    signal data: std_logic_vector(DATA_WIDTH-1 downto 0);
    begin  
      process (clk,reset)  
        begin  
        if (clk'event and clk = '1') then
          if reset = '1' then
            data <= (others => '0' ) ;
          elsif (wr_en = '1') then
            data <= din;
          end if;
        end if;
      end process;  
    dout<= data;
end Behavioral;