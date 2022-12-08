library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LSM is
    port
    (   inp                 :in std_logic_vector(7 downto 0);
        clk,LM_SM,reset     :in std_logic;
        reg_addr,mem_addr   :out std_logic_vector(2 downto 0);
        PC_en,w_en,t_en     :out std_logic);
end LSM;

architecture v2 of LSM is
---------------Defining state type here-----------------------------
type state is (s0,s1,s2,s3,s4,s5,s6,s7);
---------------Defining signals of state type-----------------------
signal y_present,y_next: state:=s0;
signal me_addr: std_logic_vector(2 downto 0):="000";

function p_enc(A: in std_logic_vector(7 downto 0); index : integer) return integer is
    --variable op : std_logic_vector(3 downto 0):= (others=>'0');
    variable k  : integer := 0;
  begin

    for i in index to 8 loop
        if i>7 then
            k := i; 
            exit;
        elsif A(i) = '1' then
            k := i; 
            exit;
        end if;
    end loop;

    -- op := std_logic_vector(to_unsigned(i,4));

  return k;
end p_enc;

begin

clock_proc:process(clk,reset)
begin
    if(clk='1' and clk' event) then
        if(reset='1') then
            y_present<= s0 ; 
        else
            y_present<= y_next ;
        end if;
    end if;
    
end process;

mem_proc:process(clk,reset,y_present)
begin
    if(clk='1' and clk' event) then
        if reset = '1' or y_present = s0 then
            me_addr<= "000";
        else
            me_addr<= std_logic_vector(unsigned(me_addr) + 1);
        end if;
    end if;
    
end process;

state_transition_proc:process(inp,y_present)
    variable int_inp0 : integer := p_enc(inp,0);
    variable int_inp1 : integer := p_enc(inp,1);
    variable int_inp2 : integer := p_enc(inp,2);
    variable int_inp3 : integer := p_enc(inp,3);
    variable int_inp4 : integer := p_enc(inp,4);
    variable int_inp5 : integer := p_enc(inp,5);
    variable int_inp6 : integer := p_enc(inp,6);
    variable int_inp7 : integer := p_enc(inp,7);
begin
    case y_present is
        when s0=>
            if int_inp0 = 0 then
                y_next<= s1; 
            elsif int_inp0 = 1 then
                y_next <= s2;
            elsif int_inp0 = 2 then
                y_next <= s3;
            elsif int_inp0 = 3 then
                y_next <= s4;
            elsif int_inp0 = 4 then
                y_next <= s5;
            elsif int_inp0 = 5 then
                y_next <= s6;
            elsif int_inp0 = 6 then
                y_next <= s7;
            else
                y_next <= s0;
            end if;
		when s1=>
            if int_inp1 = 1 then
                y_next <= s2;
            elsif int_inp1 = 2 then
                y_next <= s3;
            elsif int_inp1 = 3 then
                y_next <= s4;
            elsif int_inp1 = 4 then
                y_next <= s5;
            elsif int_inp1 = 5 then
                y_next <= s6;
            elsif int_inp1 = 6 then
                y_next <= s7;
            else
                y_next <= s0;
            end if;

        when s2=>
            if int_inp2 = 2 then
                y_next <= s3;
            elsif int_inp2 = 3 then
                y_next <= s4;
            elsif int_inp2 = 4 then
                y_next <= s5;
            elsif int_inp2 = 5 then
                y_next <= s6;
            elsif int_inp2 = 6 then
                y_next <= s7;
            else 
                y_next <= s0;
            end if;

        when s3=>
            if int_inp3 = 3 then
                y_next <= s4;
            elsif int_inp3 = 4 then
                y_next <= s5;
            elsif int_inp3 = 5 then
                y_next <= s6;
            elsif int_inp3 = 6 then
                y_next <= s7;
            else 
                y_next <= s0;
            end if;

		when s4=>
            if int_inp4 = 4 then
                y_next <= s5;
            elsif int_inp4 = 5 then
                y_next <= s6;
            elsif int_inp4 = 6 then
                y_next <= s7;
            else 
                y_next <= s0;
            end if;
		when s5=>
            if int_inp5 = 5 then
                y_next <= s6;
            elsif int_inp5 = 6 then
                y_next <= s7;
            else 
                y_next <= s0;
            end if;
        when s6=>
            if int_inp6 = 6 then
                y_next <= s7;
            else 
                y_next <= s0;
            end if;
        when s7=>
            y_next <= s0;

		  end case;
end process;

output_proc: process(y_present,inp,LM_SM)
begin

        if LM_SM = '0' then
            reg_addr <= "000";        
            PC_en    <= '1';
            w_en     <= '0';
            t_en     <= '1'; 
        else
            case y_present is
                when s0=>
                    if p_enc(inp,0) = 8 then
                        reg_addr <= "000";        
                        PC_en    <= '1';
                        w_en     <= '0';
                        t_en     <= '1';                                     
                    else
                        reg_addr <= std_logic_vector(to_unsigned(p_enc(inp,0),reg_addr'length));        
                        PC_en    <= '0';
                        w_en     <= '1';
                        t_en     <= '1';                                                             
                    end if;
                when s1=>
                    if p_enc(inp,1) = 8 then
                        reg_addr <= "000";        
                        PC_en    <= '1';
                        w_en     <= '0';
                        t_en     <= '1';                                     
                    else
                        reg_addr <= std_logic_vector(to_unsigned(p_enc(inp,1),reg_addr'length));        
                        PC_en    <= '0';
                        w_en     <= '1';
                        t_en     <= '0';                                                             
                    end if;

                when s2=>
                    if p_enc(inp,2) = 8 then
                        reg_addr <= "000";        
                        PC_en    <= '1';
                        w_en     <= '0';
                        t_en     <= '1';                                     
                    else
                        reg_addr <= std_logic_vector(to_unsigned(p_enc(inp,2),reg_addr'length));        
                        PC_en    <= '0';
                        w_en     <= '1';
                        t_en     <= '0';                                                             
                    end if;

                when s3=>
                    if p_enc(inp,3) = 8 then
                        reg_addr <= "000";        
                        PC_en    <= '1';
                        w_en     <= '0';
                        t_en     <= '1';                                     
                    else
                        reg_addr <= std_logic_vector(to_unsigned(p_enc(inp,3),reg_addr'length));        
                        PC_en    <= '0';
                        w_en     <= '1';
                        t_en     <= '0';                                                             
                    end if;

                when s4=>
                    if p_enc(inp,4) = 8 then
                        reg_addr <= "000";        
                        PC_en    <= '1';
                        w_en     <= '0';
                        t_en     <= '1';                                     
                    else
                        reg_addr <= std_logic_vector(to_unsigned(p_enc(inp,4),reg_addr'length));        
                        PC_en    <= '0';
                        w_en     <= '1';
                        t_en     <= '0';                                                             
                    end if;

                when s5=>
                    if p_enc(inp,5) = 8 then
                        reg_addr <= "000";        
                        PC_en    <= '1';
                        w_en     <= '0';
                        t_en     <= '1';                                     
                    else
                        reg_addr <= std_logic_vector(to_unsigned(p_enc(inp,5),reg_addr'length));        
                        PC_en    <= '0';
                        w_en     <= '1';
                        t_en     <= '0';                                                             
                    end if;

                when s6=>
                    if p_enc(inp,6) = 8 then
                        reg_addr <= "000";        
                        PC_en    <= '1';
                        w_en     <= '0';
                        t_en     <= '1';                                     
                    else
                        reg_addr <= std_logic_vector(to_unsigned(p_enc(inp,6),reg_addr'length));        
                        PC_en    <= '0';
                        w_en     <= '1';
                        t_en     <= '0';                                                             
                    end if;

                when s7=>
                    if p_enc(inp,7) = 8 then
                        reg_addr <= "000";        
                        PC_en    <= '1';
                        w_en     <= '0';
                        t_en     <= '1';                                     
                    else
                        reg_addr <= std_logic_vector(to_unsigned(p_enc(inp,7),reg_addr'length));        
                        PC_en    <= '0';
                        w_en     <= '1';
                        t_en     <= '0';                                                             
                    end if;

            end case;
    
        end if;
    
end process;
    mem_addr<=me_addr;
end v2;