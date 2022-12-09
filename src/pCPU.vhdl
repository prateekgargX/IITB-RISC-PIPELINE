library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pCPU is
    port
    (
        clk,reset: in std_logic
        --; can add debug signals as outputs like PC_val,IR_val etc.
    );
end entity pCPU;

architecture lilcomp of pCPU is 
    component controller is
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
    end component;

    component adder is
    generic
	(
		DATA_WIDTH	: integer := 16 
    );

    port 
    (
	    a,b  : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
	    y    : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0));

    end component;

    component ALU is
        port(
               alu_a   : in  STD_LOGIC_VECTOR(15 downto 0);
               alu_b   : in  STD_LOGIC_VECTOR(15 downto 0);
               op_code : in  STD_LOGIC; --2 types fo alu instruction(ADD and NAND)
               alu_out : out STD_LOGIC_VECTOR(15 downto 0);
               z_out   : out STD_LOGIC;
               c_out   : out STD_LOGIC);
    end component;

    component CCR is  
        port
        (
            clk,reset  : in  std_logic;
            C_en, Z_en : in  std_logic; -- Enables writes to C and Z
            C_in,Z_in  : in  std_logic; -- Din
            C,Z  	     : out std_logic  -- Outputs
        );
    end component;

    component COMPARATOR is
        generic
        (
            DATA_WIDTH	: integer := 16 
        );
    
        port 
        (
            a,b  : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            y    : out std_logic);
    end component;

    component iROM is
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
    end component;

    component LSM is
        port
        (   inp                 :in std_logic_vector(7 downto 0);
            clk,LM_SM,reset     :in std_logic;
            reg_addr,mem_addr   :out std_logic_vector(2 downto 0);
            PC_en,w_en,t_en     :out std_logic);

    end component;

    component memory is
        generic
        (
            ADDR_WIDTH	: integer := 8; -- log2MAX instructions memory can hold
            DATA_WIDTH	: integer := 16; -- 2 bytes on each addr.
            INIT_FILE   : string  := "MIF.txt" -- file to initialize memory from 
        );
        
        port
        (
            clk,reset    	: in  std_logic;
            din				: in  std_logic_vector(DATA_WIDTH - 1 downto 0); --data to be written into the memory
            mem_a			: in  std_logic_vector(ADDR_WIDTH - 1 downto 0); --single port 
            wr_en			: in  std_logic; --write enable
            dout			: out std_logic_vector(DATA_WIDTH - 1 downto 0) --M[mem_a]
        );
    end component;

    component reg_file is
        port
        ( 
                do1,do2      : out std_logic_vector(15 downto 0);----- Read outputs 
                din          : in  std_logic_vector(15 downto 0);----- Write Input 
                wr_en     : in  std_logic;
                ao1,ao2,ain  : in  std_logic_vector(2 downto 0);			----- Addresses
                clk,reset    : in  std_logic 
        );
    end component;

    component reg is  
    port(
        clk,reset,wr_en : in std_logic;
        din   		       : in std_logic_vector(15 downto 0);  
        dout  	         : out std_logic_vector(15 downto 0)
        );

    end component;

    component SE6_16b is
        port ( din : in std_logic_vector(5 downto 0) ;
               dout	: out std_logic_vector(15 downto 0) 
                  ) ;

    end component;

    component SE9_16b is
        port ( din : in std_logic_vector(8 downto 0) ;
               dout	: out std_logic_vector(15 downto 0) 
                  ) ;

    end component;

    component shift7 is
            port ( din  : in std_logic_vector(8 downto 0) ;
               dout	: out std_logic_vector(15 downto 0) 
                  ) ;

    end component;

    component uReg is
        generic
        (
            DATA_WIDTH	: integer := 16 
        );
        port 
        (
            clk,reset,wr_en  : in std_logic;
            din   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            dout  : out std_logic_vector(DATA_WIDTH-1 downto 0));

    end component;

    -- component 

    -- end component;

    -- component 

    -- end component;

    -- component 

    -- end component;
begin

end lilcomp;
