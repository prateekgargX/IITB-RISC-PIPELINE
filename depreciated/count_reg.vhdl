library ieee;
use ieee.std_logic_1164.all;
-- Counter for LM/SM -- Needs a review
-- INPUTS: clk,reset,C_en, Z_en,C_in,Z_in
-- OUTPUTS: C,Z

entity mod8counter is
	port
	(
		clk,en : in std_logic;
		y:out std_logic_vector(2 downto 0)
	);
		
end entity mod8counter;

architecture behav of mod8counter is

signal state:std_logic_vector(3 downto 0) := "1000";

constant s_0:std_logic_vector(3 downto 0):="0000";
constant s_1:std_logic_vector(3 downto 0):="0001";
constant s_2:std_logic_vector(3 downto 0):="0010";
constant s_3:std_logic_vector(3 downto 0):="0011";
constant s_4:std_logic_vector(3 downto 0):="0100";
constant s_5:std_logic_vector(3 downto 0):="0101";
constant s_6:std_logic_vector(3 downto 0):="0110";
constant s_7:std_logic_vector(3 downto 0):="0111";
constant s_8:std_logic_vector(3 downto 0):="1000";

begin 

count_process: process(clk)
begin
if en='1' then 
	if(clk'event and clk='1')then                                                                                                                                                           
	case state is  
      when s_0=>
		state<=s_1;
		when s_1=>
		state<=s_2;
		when s_2=>
		state<=s_3;
		when s_3=>
		state<=s_4;
		when s_4=>
		state<=s_5;
		when s_5=>
		state<=s_6;
		when s_6=>
		state<=s_7;
		when s_7=>
		state<=s_8;
        when others=> 
        state<=s_0;
      end case; 
	end if;
end if;

end process count_process;
-- output logic concurrent statemet or one more process
y<=state(2 downto 0);
end behav;