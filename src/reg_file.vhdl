library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
        port
        ( 
                do1,do2      : out std_logic_vector(15 downto 0);----- Read outputs 
                din          : in  std_logic_vector(15 downto 0);----- Write Input 
                wr_en     : in  std_logic;
                ao1,ao2,ain  : in  std_logic_vector(2 downto 0);			----- Addresses
                clk,reset    : in  std_logic 
    );
end reg_file;

architecture behave of reg_file is
	type R is array(0 to 7) of std_logic_vector(15 downto 0); 
    --Eight 16-bit registers R(0) to R(7)
    signal registers : R := (others => (others => '0') ) ;
    
    begin
        process(clk,reset)
                begin
                        if (clk'event and clk = '1') then
                                if reset = '1' then
                                        registers <= (others => (others => '0') ) ;
                                elsif (wr_en = '1') then
                                        registers(to_integer(unsigned(ain))) <= din;
                                end if;
                        end if;
        end process;
        do1 <= registers(to_integer(unsigned(ao1))); 
        do2 <= registers(to_integer(unsigned(ao1)));
    
	end behave;

