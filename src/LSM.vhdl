library ieee;
use ieee.std_logic_1164.all;
-- library work;
-- use work.all;

entity LSM is
	port
	(
		clk,reset : in std_logic;
        LM_SM: in std_logic; --tells if current executing instrucion is LM/SM
        din  : in std_logic_vector(15 downto 0); --RA
        PC_en: out std_logic;
        dout : out std_logic_vector(15 downto 0); 
		count: out std_logic_vector(2 downto 0)
	);
		
end entity LSM;

architecture behav of LSM is

    -- to store immediate value of RA, might get modifed later
    component reg is  
    port(clk,reset,wr_en : in std_logic;
         din   		     : in std_logic_vector(15 downto 0);  
         dout  	         : out std_logic_vector(15 downto 0)
        );
    end component;

    -- hack to store enable signal for counter and register
    component CCR is  
    port
    (
        clk,reset  : in  std_logic;
        C_en, Z_en : in  std_logic; -- Enables writes to C and Z
        C_in,Z_in  : in  std_logic; -- Din
        C,Z  	   : out std_logic  -- Outputs
    );  
    end component;

    for mem_addr: reg use entity work.reg;
    for en_reg: CCR use entity work.CCR;

signal reg_en,reg_en_i     : std_logic  :='1';
signal count_en,count_en_i : std_logic  :='0';
signal state_sig           : std_logic  :='0';

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
    mem_addr: reg port map(clk => clk,reset=>reset,wr_en=>reg_en,din=>din,dout=>dout);
    en_reg  : CCR port map(clk=>clk,reset=>reset,C_en=>'1',Z_en=>'1',C_in=>count_en_i,Z_in=>reg_en_i,C=>count_en,Z=>reg_en);

count_process: process(clk)
begin
if count_en='1' then 
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
-- if state == "0111" >> that signal ==1
state_sig<='1' when state = "0111" else '0';
reg_en_i<=not(LM_SM) or state_sig;
count_en_i<=LM_SM and not(state_sig);

PC_en<=not(LM_SM) or state_sig;

count<=state(2 downto 0);
end behav;