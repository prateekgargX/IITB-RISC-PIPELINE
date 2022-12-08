LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity reg is  
  port(clk,reset,wr_en : in std_logic;
       din   		       : in std_logic_vector(15 downto 0);  
       dout  	         : out std_logic_vector(15 downto 0)
      );  
end reg;

architecture struct of reg is  
  signal data: std_logic_vector(15 downto 0);
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
end struct;                      