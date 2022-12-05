LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- Conditional Code Register

-- INPUTS: clk,reset,C_en, Z_en,C_in,Z_in
-- OUTPUTS: C,Z

entity CCR is  
  port
  (
    clk,reset  : in  std_logic;
    C_en, Z_en : in  std_logic; -- Enables writes to C and Z
    C_in,Z_in  : in  std_logic; -- Din
    C,Z  	     : out std_logic  -- Outputs
  );  
end CCR;

architecture struct of CCR is  
  begin  
    process (clk,reset)  
      begin  
      if (clk'event and clk = '1') then
  		  if(reset = '1') then
	  		  C <= '0';
          Z <= '0';
        else  
          if(C_en ='1') then
            C <= C_in;   
            end if;
          if(Z_en='1') then
          Z <= Z_in;   
          end if;

        end if;
      end if;  
    end process;  
end struct;                      