library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use  work.all;

entity pCPU is
    generic
	(
		DATA_FILE	: string  := "DATA.txt"; --  file to initialize RAM from
		INST_FILE   : string  := "INSTR.txt" -- file to initialize ROM from 
	);

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
            CZ                  :in std_logic_vector(1 downto 0); -- last 2 bits of Instructions for conditional execution
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
            WB_mux              :out std_logic_vector(1 downto 0) --controls what is written back to registers. 
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
            mem_a			: in  std_logic_vector(ADDR_WIDTH - 1 downto 0); --single port 
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

    component decoder is
     port(
        instr    : in  STD_LOGIC_VECTOR(15 downto 0);
        RA,RB,RC : out STD_LOGIC_VECTOR(2 downto 0);
        opcode   : out STD_LOGIC_VECTOR(3 downto 0);
        CZ       : out STD_LOGIC_VECTOR(1 downto 0);
        IMM9     : out STD_LOGIC_VECTOR(8 downto 0);
        IMM6     : out STD_LOGIC_VECTOR(5 downto 0);
        mask     : out STD_LOGIC_VECTOR(7 downto 0));

    end component;

    component shiftleft is
        port 
            (  en   : in std_logic;
               din  : in std_logic_vector(15 downto 0) ;
               dout	: out std_logic_vector(15 downto 0) 
            ) ;
    end component;

    -- component 

    -- end component;

-- signals flowing backwards will be generated in their respective stages
-- Global Signals
    signal IF_ID_en: std_logic:='1';
    signal IF_ID_data:std_logic_vector(48 - 1 downto 0):=(others=>'0');

    signal ID_RR_en: std_logic:='1';
    signal ID_RR_data:std_logic_vector(109 - 1 downto 0):=(others=>'0');

    signal RR_EX_en: std_logic:='1';
    signal RR_EX_data:std_logic_vector(116 - 1 downto 0):=(others=>'0');

    signal EX_MEM_en: std_logic:='1';
    signal EX_MEM_data:std_logic_vector(48 - 1 downto 0):=(others=>'0');

    signal MEM_WB_en: std_logic:='1';
    signal MEM_WB_data:std_logic_vector(48 - 1 downto 0):=(others=>'0');

-- instruction fetch(IF)
    signal pc_in,pc_out,rom_out,pc_add_out:std_logic_vector(15 downto 0):=x"0000";
    --control signals
    signal pc_en,pc_mux: std_logic :='1'; 
-- instruction decode(ID)
    signal LSM_t_en: std_logic :='1';
    signal shift7_out,se6_out,se9_out,PC_ID,PC_ADD_ID:std_logic_vector(15 downto 0):=x"0000";
    signal RA,RB,RC,regread,regwrite,LSMreg_addr,LSMmem_addr:std_logic_vector(2 downto 0):="000";
    signal opcode : std_logic_vector(3 downto 0);  
    signal CZ : std_logic_vector(1 downto 0);      
    signal IMM9 : std_logic_vector(8 downto 0);    
    signal IMM6 : std_logic_vector(5 downto 0);    
    signal mask : std_logic_vector(7 downto 0);
    --control signals
    signal LSM_nostall,LSM_w_en: std_logic :='1';
    signal LM_SM,regread_mux: std_logic :='0';
    signal regWrite_mux: std_logic_vector(1 downto 0) :="00";

    --store for later use
    signal TargetBranch_mux_ID: std_logic_vector(1 downto 0) :="00";
    signal RF_wr_en_ID: std_logic :='0';
    signal ALU_op1_mux_ID: std_logic_vector(1 downto 0):="00";
    signal ALU_op2_mux_ID: std_logic :='0';
    signal ALU_op_code_ID: std_logic :='0';
    signal C_dep_ID: std_logic :='0';
    signal Z_dep_ID: std_logic :='0';
    signal CCR_C_en_ID: std_logic :='0';
    signal CCR_Z_en_ID: std_logic :='0';
    signal left_shift_B_ID: std_logic :='0';
    signal mem_din_mux_ID: std_logic :='0';
    signal mem_wr_en_ID: std_logic :='0';
    signal WB_mux_ID: std_logic_vector(1 downto 0) :="00"; 
-- register read (RR)
    signal branchTargetAddress,t_mem_addr,dRA,dRB,DTreg,bta0,bta1,bta2:std_logic_vector(15 downto 0):=x"0000";
    signal BEQ_COM: std_logic:= '1';
    
    --control signals
-- execute (EX)
    signal alu_c_out,alu_z_out,CCR_c,CCR_z,
            regwrite_ex: std_logic:= '0';
    signal alu_a_src,alu_b_src,alu_output,lshift_out:std_logic_vector(15 downto 0):=x"0000";

    --control signals
-- memory access (MEM)
    --control signals
-- Write Back (WB)
    signal WB_reg:std_logic_vector(2 downto 0):="000";
    signal WB_data:std_logic_vector(15 downto 0):=x"0000";
    signal RF_wr_en_ID_wb:std_logic:= '0';

begin
-- instruction fetch(IF)
    PC_reg: reg port map(clk=>clk,reset=>reset,wr_en=>pc_en,din=>pc_in,dout=>pc_out);
    ROM: iROM generic map(ADDR_WIDTH => 16,DATA_WIDTH => 16,INIT_FILE  => INST_FILE)
                 port map(clk=>clk,reset=>reset,mem_a=>pc_out,dout =>rom_out);

    --port map (clk  =>clk,din  =>din,mem_a=>addr,wr_en=> w,dout => dout);

    PC_adder: adder port map(a=>x"0001",b=>pc_out,y=>pc_add_out);

    -- software MUX
    pc_in <= pc_add_out when pc_mux = '0' else branchTargetAddress;

-- instruction decode(ID)
    decode_block: decoder port map(instr=>IF_ID_data(15 downto 0),RA=>RA,RB=>RB,RC=>RC,opcode=>opcode,CZ=>CZ,IMM9=>IMM9,IMM6=>IMM6,mask=>mask);
    shifter7: shift7 port map(din=>IMM9,dout=>shift7_out);
    SE6: SE6_16b port map(din=>IMM6,dout=>se6_out);
    SE9: SE9_16b port map(din=>IMM9,dout=>se9_out);
    LSM_Unit: LSM port map(inp=>mask,clk=>clk,LM_SM=>LM_SM,reset=>reset,reg_addr=>LSMreg_addr,mem_addr=>LSMmem_addr,PC_en=>LSM_nostall,w_en=>LSM_w_en,t_en=>LSM_t_en);
    myController: controller port map(opcode=>opcode,CZ=>CZ,LSM_wr_en=>LSM_w_en,LM_SM=>LM_SM,
                                    RegWrite_mux=>regWrite_mux,RegBread_mux=>regread_mux,
                                      TargetBranch_mux=>TargetBranch_mux_ID,RF_wr_en=>RF_wr_en_ID,
                                      ALU_op1_mux=>ALU_op1_mux_ID,ALU_op2_mux=>ALU_op2_mux_ID,
                                      ALU_op_code=>ALU_op_code_ID,C_dep=>C_dep_ID,Z_dep=>Z_dep_ID,CCR_C_en=>CCR_C_en_ID,CCR_Z_en=>CCR_Z_en_ID,left_shift_B=>left_shift_B_ID,
                                      mem_din_mux=>mem_din_mux_ID,mem_wr_en=>mem_wr_en_ID,WB_mux=>WB_mux_ID); 
    -- write address 
    with RegWrite_mux select
    regwrite <= RC when "00",
                RB when "01",
                RA when "10",  
                LSMreg_addr when  others;

    -- read address
    regread <= RB when regread_mux = '0' else LSMreg_addr;

-- Register Read(RR)
    myRegisters: reg_file port map(ao1=>ID_RR_data(50  downto 48),ao2=>ID_RR_data(53  downto 51),
                                  ain=>WB_reg,clk=>clk,reset=>reset,do1=>dRA,do2=>dRB,din=>WB_data,wr_en=>RF_wr_en_ID_wb);
    LSMtreg    : reg port map (clk=>clk,reset=>reset,wr_en=>ID_RR_data(60),din=>dRA,dout=>dTreg);

    -- software MUX
    t_mem_addr <= dRA when ID_RR_data(60) = '1' else dTreg;
    BEQ_COM <= '1' when dRA = dRB else '0';

    Badder0: adder port map(a=>ID_RR_data(76  downto 61),b=>ID_RR_data(15  downto 0),y=>bta0);
    Badder1: adder port map(a=>ID_RR_data(76  downto 61),b=>ID_RR_data(31  downto 16),y=>bta1);
    Badder2: adder port map(a=>dRA,b=>ID_RR_data(15  downto 0),y=>bta2);

    with ID_RR_data(94 downto 93) select
    branchTargetAddress <= bta1 when "00",
                           bta0 when "01",
                           dRB  when "10",
                           bta2 when others; -- JRI or any non-branch


-- Execution Stage(EX)

    myCCR: CCR port map(clk=>clk,reset=>reset,C_en=>RR_EX_data(109),Z_en=>RR_EX_data(110),C_in=>alu_c_out,Z_in=>alu_c_out,C=>CCR_C,Z=>CCR_Z);
    myALU: ALU port map(alu_a=>alu_a_src,alu_b=>alu_b_src,op_code=>RR_EX_data(106),alu_out=>alu_output,z_out=>alu_z_out,c_out=>alu_c_out);
    lshift: shiftleft port map(en=>RR_EX_data(111),din=>RR_EX_data(63  downto 48),dout=>lshift_out);

    CZ_depend_proc: process(RR_EX_data(107),RR_EX_data(108))
    begin
        if RR_EX_data(107) = '1' then
            regWrite_EX <= CCR_C;
        elsif RR_EX_data(108) = '1' then
            regWrite_EX <= CCR_Z;
        else
            regWrite_EX <= RR_EX_data(102);
        end if;
    end process CZ_depend_proc;

    with RR_EX_data(104 downto 103) select
    alu_a_src <= RR_EX_data(47  downto 32) when "00", --RA
                 RR_EX_data(85  downto 70) when "01", --treg 
                 RR_EX_data(15  downto 0)  when  others;--others

    -- with RR_EX_data(105) select
    -- alu_b_src <= lshift_out when '0',
    --              (2 downto 0) => RR_EX_data(66  downto 64), others=>'0' when others;
    
    alu_b_src_proc: process(RR_EX_data(105),RR_EX_data(111),RR_EX_data(66  downto 64))
    begin
        if RR_EX_data(105) = '0' then
            alu_b_src <= lshift_out;
        else
        alu_b_src(2 downto 0) <= RR_EX_data(66  downto 64);
        alu_b_src(15 downto 3) <= (others=>'0');
        end if;
    end process alu_b_src_proc;    

    -- signal mapping
    IF_ID_RR_EX_MEM_WB : process (clk,reset) begin  
    if (clk'event and clk = '1') then 
        if reset = '1' then 
            IF_ID_data  <= (others => '0');
            ID_RR_data  <= (others => '0');
            RR_EX_data  <= (others => '0');
            EX_MEM_data <= (others => '0');
            MEM_WB_data <= (others => '0');
        else
            if (IF_ID_en = '1') then
                IF_ID_data(15  downto 0) <= rom_out;
                IF_ID_data(31  downto 16) <= pc_out;
                IF_ID_data(47  downto 32) <= pc_add_out;
            end if;
            if(ID_RR_en='1')then
                ID_RR_data(15  downto 0) <= se9_out;
                ID_RR_data(31  downto 16) <= se6_out;
                ID_RR_data(47  downto 32) <= shift7_out;
                ID_RR_data(50  downto 48) <= RA;
                ID_RR_data(53  downto 51) <= regread;
                ID_RR_data(56  downto 54) <= regwrite;
                ID_RR_data(59  downto 57) <= LSMmem_addr;
                ID_RR_data(60)            <= LSM_t_en;
                ID_RR_data(76  downto 61) <= PC_ID;
                ID_RR_data(92  downto 77) <= PC_ADD_ID;
                --- Control signals
                ID_RR_data(94 downto 93) <= TargetBranch_mux_ID;
                ID_RR_data(95) <= RF_wr_en_ID;
                ID_RR_data(97 downto 96) <= ALU_op1_mux_ID;
                ID_RR_data(98) <= ALU_op2_mux_ID;
                ID_RR_data(99) <= ALU_op_code_ID;
                ID_RR_data(100) <= C_dep_ID;
                ID_RR_data(101) <= Z_dep_ID;
                ID_RR_data(102) <= CCR_C_en_ID;
                ID_RR_data(103) <= CCR_Z_en_ID;
                ID_RR_data(104) <= left_shift_B_ID;
                ID_RR_data(105) <= mem_din_mux_ID;
                ID_RR_data(106) <= mem_wr_en_ID;
                ID_RR_data(108 downto 107) <= WB_mux_ID;
            end if;
            if(RR_EX_en='1')then
                RR_EX_data(15  downto 0) <= ID_RR_data(31  downto 16);
                RR_EX_data(31  downto 16) <= ID_RR_data(47  downto 32);
                RR_EX_data(47  downto 32) <= dRA;
                RR_EX_data(63  downto 48) <= dRB;
                RR_EX_data(66  downto 64) <= ID_RR_data(59  downto 57);
                RR_EX_data(69  downto 67) <= ID_RR_data(56  downto 54);
                RR_EX_data(85  downto 70) <= t_mem_addr;
                RR_EX_data(101  downto 86) <= ID_RR_data(92  downto 77) ;
                -- Control signals
                RR_EX_data(102) <= ID_RR_data(95);
                RR_EX_data(104 downto 103) <= ID_RR_data(97 downto 96);
                RR_EX_data(105) <= ID_RR_data(98);
                RR_EX_data(106) <= ID_RR_data(99) ;
                RR_EX_data(107) <= ID_RR_data(100) ;
                RR_EX_data(108) <= ID_RR_data(101);
                RR_EX_data(109) <= ID_RR_data(102);
                RR_EX_data(110) <= ID_RR_data(103);
                RR_EX_data(111) <= ID_RR_data(104);
                RR_EX_data(112) <= ID_RR_data(105);
                RR_EX_data(113) <= ID_RR_data(106);
                RR_EX_data(115 downto 114) <= ID_RR_data(108 downto 107) ;

            end if;
            if(EX_MEM_en='1')then
                -- EX_MEM_data(15  downto 0) <= ID_RR_data(31  downto 16);
                -- EX_MEM_data(31  downto 16) <= ID_RR_data(47  downto 32);
                -- EX_MEM_data(47  downto 32) <= dRA;
                -- EX_MEM_data(63  downto 48) <= dRB;
                -- EX_MEM_data(66  downto 64) <= ID_RR_data(59  downto 57);
                -- EX_MEM_data(69  downto 67) <= ID_RR_data(56  downto 54);
                -- EX_MEM_data(85  downto 70) <= t_mem_addr;
                -- EX_MEM_data(101  downto 86) <= ID_RR_data(92  downto 77) ;
                -- -- Control signals
                -- EX_MEM_data(102) <= ID_RR_data(95);
                -- EX_MEM_data(104 downto 103) <= ID_RR_data(97 downto 96);
                -- EX_MEM_data(105) <= ID_RR_data(98);
                -- EX_MEM_data(106) <= ID_RR_data(99) ;
                -- EX_MEM_data(107) <= ID_RR_data(100) ;
                -- EX_MEM_data(108) <= ID_RR_data(101);
                -- EX_MEM_data(109) <= ID_RR_data(102);
                -- EX_MEM_data(110) <= ID_RR_data(103);
                -- EX_MEM_data(111) <= ID_RR_data(104);
                -- EX_MEM_data(112) <= ID_RR_data(105);
                -- EX_MEM_data(113) <= ID_RR_data(106);
                -- EX_MEM_data(115 downto 114) <= ID_RR_data(108 downto 107) ;
            end if;
            if(MEM_WB_en='1')then

            end if;

        end if; 
    end if;
    end process IF_ID_RR_EX_MEM_WB;
    

end lilcomp;
