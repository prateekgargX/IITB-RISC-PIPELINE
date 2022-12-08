library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_textio.all;
use std.textio.all;

entity iROM is
	generic
	(
		ADDR_WIDTH	: integer := 8; -- log2MAX instructions memory can hold
		DATA_WIDTH	: integer := 16; -- 2 bytes on each addr.
		INIT_FILE   : string  := "LIL_INSTR.txt" -- file to initialize memory from 
	);
	
	port
	(
		clk,reset		: in  std_logic;
		din				: in  std_logic_vector(DATA_WIDTH - 1 downto 0); --data to be written into the memory
		mem_a			: in  std_logic_vector(ADDR_WIDTH - 1 downto 0); --single port 
		wr_en			: in  std_logic; --write enable
		dout			: out std_logic_vector(DATA_WIDTH - 1 downto 0) --M[mem_a]
	);
end iROM;

-- din  = stored into memory,
-- dout = loaded from memory.

architecture behave of iROM is
	type mem_array is array(0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
	-- function to load instructions into memory
	function load_from(file_name : in string) return mem_array is
		file 	 mif_file : text open read_mode is file_name;
		variable mif_line : line;
		variable temp_bv  : bit_vector(DATA_WIDTH-1 downto 0);
		variable temp_mem : mem_array;
	begin
		
		for i in mem_array'range loop
			if not endfile(mif_file) then
				readline(mif_file, mif_line); -- Read into mifline
				read(mif_line, temp_bv); -- Read into a bit vector
				temp_mem(i) := to_stdlogicvector(temp_bv); --convert it std vec and store
			else
			temp_mem(i) := x"0000";
			end if;
			end loop;
		return temp_mem;
	end function;

	signal memory_block : mem_array := load_from(INIT_FILE);

begin
    dout <= memory_block(to_integer(unsigned(mem_a)));			
	process(clk,reset) -- reads can be async while writes are sync.
	begin
		if (clk'event and clk = '1') then
            if reset = '1' then
                memory_block <= load_from(INIT_FILE);
            elsif (wr_en = '1') then
			    memory_block(to_integer(unsigned(mem_a))) <= din;
			end if;
		end if;
	end process;

end behave;
