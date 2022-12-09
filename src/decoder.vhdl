library IEEE;
use IEEE.STD_LOGIC_1164.all;      
use ieee.numeric_std.all;
-- Arithmatic Logic Unit

-- INPUTS: alu_a, alu_b, op_code
-- OUTPUTS: C-out,Z_out,alu_out

entity decoder is
     port(
            instr    : in  STD_LOGIC_VECTOR(15 downto 0);
			RA,RB,RC : out STD_LOGIC_VECTOR(2 downto 0);
			opcode   : out STD_LOGIC_VECTOR(3 downto 0);
            CZ       : out STD_LOGIC_VECTOR(1 downto 0);
            IMM9     : out STD_LOGIC_VECTOR(8 downto 0);
            IMM6     : out STD_LOGIC_VECTOR(5 downto 0);
            mask     : out STD_LOGIC_VECTOR(7 downto 0));
end decoder;

architecture behave of decoder is     
begin
    RA <= instr(11 downto 9);
    RB <= instr(8 downto 6);
    RC <= instr(5 downto 3);
    opcode <= instr(15 downto 12);
    CZ <= instr(1 downto 0);
    IMM9 <= instr(8 downto 0);
    IMM6 <= instr(5 downto 0);
    mask <= instr(7 downto 0);
end behave;
