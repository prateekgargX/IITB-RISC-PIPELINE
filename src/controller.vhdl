library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- staller will generate and insert NOPs. Controller assume NOPs.
-- LSM_PC_en to staller
-- BEQ_COM -- also to staller/HazardUnit

entity controller is
    port
    (   opcode              :in std_logic_vector(3 downto 0);
        CZ                  :in std_logic_vector(3 downto 0); -- last 2 bits of Instructions for conditional execution
        LSM_wr_en           :in std_logic; -- whether to treat current LS/LM instruction as a NOP.
        Branch_taken,LM_SM  :out std_logic; 
        RegWrite_mux        :out std_logic_vector(1 downto 0);
        RegBread_mux        :out std_logic;  
        TargetBranch_mux    :out std_logic_vector(1 downto 0);
        RF_wr_en            :out std_logic;
        ALU_op1_mux         :out std_logic_vector(2 downto 0);
        ALU_op2_mux         :out std_logic;
        ALU_op_code         :out std_logic;
        C_dep,Z_dep         :out std_logic; -- specifies whether instructions execution is C, Z dependent. Changes RF_wr_en on the fly
        CCR_C_en,CCR_Z_en   :out std_logic;
        left_shift_B        :out std_logic;
        mem_din_mux         :out std_logic;
        PC_en,mem_wr_en     :out std_logic;
        is_branch           :out std_logic -- is a branch instruction(to staller)
    );
end controller;

architecture v2 of controller is
-- Arithmatic 
constant ADD:std_logic_vector(3 downto 0):="0001"; -- ADC,ADZ,ADL
constant ADI:std_logic_vector(3 downto 0):="1111"; -- assigned by me
constant NDU:std_logic_vector(3 downto 0):="0001"; -- NDC,NDZ
-- Load/Store
constant LHI:std_logic_vector(3 downto 0):="1110"; -- assigned by me
constant LW :std_logic_vector(3 downto 0):="0111";
constant SW :std_logic_vector(3 downto 0):="0101";
constant LM :std_logic_vector(3 downto 0):="1100";
constant SM :std_logic_vector(3 downto 0):="1101";
-- Branch Instruction
constant BEQ:std_logic_vector(3 downto 0):="1000";
constant JAL:std_logic_vector(3 downto 0):="1001";
constant JLR:std_logic_vector(3 downto 0):="1010";
constant JRI:std_logic_vector(3 downto 0):="1011"; 
-- to support staller
constant NOP:std_logic_vector(3 downto 0):="0000"; -- assigned by me

begin
    
end v2;