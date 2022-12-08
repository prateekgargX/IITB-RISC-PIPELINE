library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- staller will generate and insert NOPs. Controller assume NOPs.
-- LSM_PC_en to staller
-- BEQ_COM -- also to staller/HazardUnit
-- Branch_detector in fetch stage.,
-- also need to create a leftshifter. ugh.

entity controller is
    port
    (   opcode              :in std_logic_vector(3 downto 0);
        CZ                  :in std_logic_vector(3 downto 0); -- last 2 bits of Instructions for conditional execution
        LSM_wr_en           :in std_logic; -- whether to treat current LS/LM instruction as a NOP.
        -- Branch_taken,
        LM_SM               :out std_logic;-- to LSM telling this is LM/SM instruction
        RegWrite_mux        :out std_logic_vector(1 downto 0);
        RegBread_mux        :out std_logic;  
        TargetBranch_mux    :out std_logic_vector(1 downto 0); --specifies which addr to branch to 
        RF_wr_en            :out std_logic; -- all except SW SM BEQ JRI
        ALU_op1_mux         :out std_logic_vector(1 downto 0); -- 1ST ALU OP
        ALU_op2_mux         :out std_logic; -- 2nd operand of alu
        ALU_op_code         :out std_logic; -- all instructions use as adder if do except NDU 
        C_dep,Z_dep         :out std_logic; -- specifies whether instructions execution is C, Z dependent. Changes RF_wr_en on the fly
        CCR_C_en,CCR_Z_en   :out std_logic; -- specifies if instr can modify C,Z
        left_shift_B        :out std_logic; -- for ADL
        mem_din_mux         :out std_logic; -- data written into memory is multiplexed.
        mem_wr_en           :out std_logic; -- store into mem
        is_branch           :out std_logic -- is a branch instruction(to staller)
    );
end controller;

architecture v2 of controller is
-- Arithmatic Instructions
constant ADD:std_logic_vector(3 downto 0):="0001"; -- ADC,ADZ,ADL
constant ADI:std_logic_vector(3 downto 0):="1111"; -- assigned by me
constant NDU:std_logic_vector(3 downto 0):="0001"; -- NDC,NDZ
-- Load/Store Instructions
constant LHI:std_logic_vector(3 downto 0):="1110"; -- assigned by me
constant LW :std_logic_vector(3 downto 0):="0111";
constant SW :std_logic_vector(3 downto 0):="0101";
constant LM :std_logic_vector(3 downto 0):="1100";
constant SM :std_logic_vector(3 downto 0):="1101";
-- Branch Instructions
constant BEQ:std_logic_vector(3 downto 0):="1000";
constant JAL:std_logic_vector(3 downto 0):="1001";
constant JLR:std_logic_vector(3 downto 0):="1010";
constant JRI:std_logic_vector(3 downto 0):="1011"; 
-- to support staller
constant NOP:std_logic_vector(3 downto 0):="0000"; -- assigned by me

begin
    -- special units
    LM_SM <= '1' when opcode = LM or opcode = SM else '0';
    left_shift_B <= '1' when opcode = ADD and CZ = "11" else '0';

    with opcode select
    TargetBranch_mux <= "00" when BEQ,
                        "01" when JAL,
                        "10" when JLR,
                        "11" when others; -- JRI or any non-branch
    
    mem_din_mux <= '1' when opcode = LM or opcode = SM else '0'; -- '0' RA, '1' RB/Count

    mem_wr_en   <= LSM_wr_en when opcode = SM else
                   '1'       when opcode = SW else
                   '0';

    -- specifies which instructions can modify C,Z
    CCR_C_en <= '1' when opcode = ADD or opcode = ADI or opcode = NDU else '0'; 
    CCR_Z_en <= '1' when opcode = ADD or opcode = ADI or opcode = NDU or opcode = LW else '0';

    ALU_op_code <= '0' when opcode = NDU else '1';

    RF_wr_en <= LSM_wr_en when opcode = SM else 
               '1' when opcode = SW or opcode = BEQ or opcode = JRI else 
               '0'; -- all except SW SM BEQ JRI
    
    ALU_op2_mux <= '1' when opcode = LM or opcode = SM else '0';

    ALU_op1_mux <= "00" when opcode = ADD or opcode = NDU else
                   "01" when opcode = LM or opcode = SM else -- Treg 
                   "10" ; -- IMM6, LW/SW
    
    regwrite_proc: process(opcode)
    begin
        if opcode = ADD or opcode = NDU then
            RegWrite_mux <= "00"; -- RC
        elsif opcode = ADI then
            RegWrite_mux <= "01"; -- RB
        elsif opcode = LW or opcode = SW or opcode = JAL or opcode = JLR then
            RegWrite_mux <= "10"; -- RA
        else
            RegWrite_mux <= "11"; -- LSM count            
        end if; 
    end process regwrite_proc;            

    regread_proc: process(opcode)
    begin
        if opcode = LM or opcode = SM then
            RegBread_mux <= '0'; -- LSM count
        else
            RegBread_mux <= '1'; -- RB            
        end if;              
    end process regread_proc;            

    CZ_dep_proc: process(opcode,CZ)
    begin
        if opcode = ADD or opcode = NDU then
            if CZ = "10" then
                C_dep<='1';
                Z_dep<='0';
            elsif CZ = "01" then
                C_dep<='0';
                Z_dep<='1';                
            end if;
        else
            C_dep<='0';
            Z_dep<='0'; 
        end if;
    end process CZ_dep_proc;

end v2;