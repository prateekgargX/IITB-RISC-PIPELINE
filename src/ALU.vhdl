library IEEE;
use IEEE.STD_LOGIC_1164.all;      
use ieee.numeric_std.all;
-- Arithmatic Logic Unit

-- INPUTS: alu_a, alu_b, op_code
-- OUTPUTS: C-out,Z_out,alu_out

entity ALU is
     port(
            alu_a   : in  STD_LOGIC_VECTOR(15 downto 0);
			alu_b   : in  STD_LOGIC_VECTOR(15 downto 0);
			op_code : in  STD_LOGIC; --2 types fo alu instruction(ADD and NAND)
			alu_out : out STD_LOGIC_VECTOR(15 downto 0);
			z_out   : out STD_LOGIC;
			c_out   : out STD_LOGIC);
end ALU;

architecture behave of ALU is
	signal C: STD_LOGIC_VECTOR(16 downto 0);     
	begin
	alu_proc : process (alu_a,alu_b,op_code) is
		begin
			if (op_code='1') then --add
			-- C = A + B
			C <= STD_LOGIC_VECTOR(resize(unsigned(alu_a),17) + resize(unsigned(alu_b),17)); 
			else --nand
			c(16)<='0'; --set manually
			C<= alu_a nand alu_b;
			end if;
		end process alu_proc;
		alu_out <= C(15 downto 0);
		c_out   <= C(16); -- most significant bit
		z_out   <= '0' when unsigned(C(15 downto 0)) = 0 else '1';

end behave;
