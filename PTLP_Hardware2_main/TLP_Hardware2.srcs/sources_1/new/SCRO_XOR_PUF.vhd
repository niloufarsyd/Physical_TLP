library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use work.SCRO_L.all;
library UNISIM;
use UNISIM.VComponents.all;

entity SCRO_XOR_PUF is
    generic (
    INPUT_WIDTH    : integer :=64;
    OUTPUT_WIDTH   : integer :=64;
    SEL_WIDTH      : integer :=  5;
    K_XOR          : integer :=  5;
    COUNTER_WIDTH  : integer := 64;
    RING_OSC_DEPTH : integer := 32);
    Port (
        clk      : in  STD_LOGIC;
        reset_clk: in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        puf_start: in  STD_LOGIC;
        --ena      : in  STD_LOGIC;
        challenge: in  STD_LOGIC_VECTOR(INPUT_WIDTH-1 downto 0);
        PUF_DONE : OUT STD_LOGIC;
        puf_busy : OUT STD_LOGIC;
        led0 : out std_logic;
        led1 : out std_logic;
        led2 : out std_logic;
        led3 : out std_logic;
        --CI1, CI2      : in  STD_LOGIC_VECTOR(63 downto 0);
--        SEL1     : in  STD_LOGIC_VECTOR(4 downto 0); -- Select which RO in SCRO1
--        SEL2     : in  STD_LOGIC_VECTOR(4 downto 0); -- Select which RO in SCRO2
--          puf_response2  : out STD_LOGIC_VECTOR(7 downto 0) --temporary
        puf_response  : out STD_LOGIC_VECTOR(OUTPUT_WIDTH-1 downto 0)
    );

end SCRO_XOR_PUF;

architecture Behavioral of SCRO_XOR_PUF is

    -- Components
    component RO_DCU
        Port (
            CI    : in  STD_LOGIC_VECTOR (63 downto 0);
            RO_EN : in  STD_LOGIC;
            X_i   : in  integer;
            RO_F  : out STD_LOGIC
        );
    end component;
    component RO_DCU64
        Port (
            CI    : in  STD_LOGIC_VECTOR (63 downto 0);
            RO_EN : in  STD_LOGIC;
            X_i : in integer;
            RO_F  : out STD_LOGIC
        );
    end component;    
    
--    component clk_wiz_0
--        port (
--            clk_in1  : in  STD_LOGIC;
--            clk_out1 : out STD_LOGIC;
--            clk_out2 : out STD_LOGIC;
--            clk_out3 : out STD_LOGIC;
--            reset    : in  STD_LOGIC;
--            locked   : out std_logic
--        );
--    end component;

    component mux32to1
        Port (
            data_in : in  STD_LOGIC_VECTOR(31 downto 0);
            sel : in  STD_LOGIC_VECTOR(4 downto 0);
            data_out : out STD_LOGIC
        );
    end component;

--    component counter
--        Port (
--            clk : in  STD_LOGIC;
--            rstn : in  STD_LOGIC;
--            enable : in  STD_LOGIC;
--            count : out UNSIGNED(15 downto 0) -- 16-bit counter
--        );
--    component counter is
--        generic (
--          WIDTH : integer;
--          MuxCountRange: integer);
--        port (
--          clk      : in  std_logic;
--          rstn     : in  std_logic;
--          ena      : in  std_logic;
--          finished : out std_logic;
--          count    : out std_logic_vector(63 downto 0));
--    end component counter;
    component ro_counter is
        generic (
          COUNTER_WIDTH : integer;
          RING_OSC_DEPTH: integer);
        port (
          clk      : in  std_logic;
          rst      : in  std_logic;
          start    : in  std_logic;
          ro_in    : in  std_logic;
          count_out: out unsigned(COUNTER_WIDTH-1 downto 0);
          done     : out std_logic
          );

    end component ro_counter;

    component comparator is 
        generic (
          WIDTH : integer);
        Port (
            val_a : in  unsigned(WIDTH-1 downto 0);
            val_b : in  unsigned(WIDTH-1 downto 0);
            result : out STD_LOGIC
        );
    end component;
    
    component shiftReg 
        Port (
            clk     : in  STD_LOGIC;
            clr_shift : in  STD_LOGIC;
            data_in : in  STD_LOGIC;
            en      : in  STD_LOGIC;
            data_out: out STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0)
        );
    end component;
    
    component LFSR
      generic (
        g_Num_Bits : integer
        );
      port (
        i_Clk    : in std_logic;
        i_Rst    : in std_logic;
        i_Enable : in std_logic;
     
        -- Optional Seed Value
        i_Seed_DV   : in std_logic;
        i_Seed_Data : in std_logic_vector(g_Num_Bits-1 downto 0);
         
        o_LFSR_Data : out std_logic_vector(g_Num_Bits-1 downto 0);
        o_LFSR_Done : out std_logic
        );
   end component;
   
   component encoder128
  port(
    x : in  std_logic_vector(127 downto 0);
    y : out std_logic_vector(7 downto 0)
  );
  end component;
    
    constant xx  : integer := K_XOR;
    -- Internal signals
    signal clk_sys : STD_LOGIC;
    signal clk_aux : STD_LOGIC;
    signal CI1, CI2: STD_LOGIC_VECTOR(INPUT_WIDTH-1 downto 0):=(others =>'0');
    signal SEL1    : STD_LOGIC_VECTOR(SEL_WIDTH-1 downto 0); -- Select which RO in SCRO1
    signal SEL2    : STD_LOGIC_VECTOR(SEL_WIDTH-1 downto 0);
    signal c : STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0):=(others =>'0');
    signal shift_out : STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0);
    signal ro_f1, ro_f2 : STD_LOGIC_VECTOR (31 downto 0);
--    signal ro_en1 : STD_LOGIC;
    signal ro_en1 : std_logic_vector(2*K_XOR-1 downto 0);
    signal ro_f1_out, ro_f2_out : STD_LOGIC_VECTOR (31 downto 0);
    type count_mem is array (0 to 2*K_XOR-1) of unsigned(COUNTER_WIDTH-1 downto 0);
    signal count : count_mem; 
    signal count_latched: count_mem;   
    signal clk_out: STD_LOGIC;
    signal puf_bit: STD_LOGIC;
    signal srEN_gated :std_logic;
    signal comp_out: std_logic_vector(K_XOR-1 downto 0);
    signal refcount,cnt_rst, refEN, srEN,roEN,countEN,countReset,en_shiftReg , lfsrEN, seed_DV, LFSR_done: STD_LOGIC;
    signal finished1, finished2 :std_logic_vector(2*K_XOR-1 downto 0);
    signal finished_and : std_logic_vector(2*K_XOR-1 downto 0);
    signal finished_all  : std_logic;
    signal shift_done, shift_clr : std_logic;
    signal cnt_start :std_logic_vector(2*K_XOR-1 downto 0);
    signal xor_chain : std_logic_vector(K_XOR-2 downto 0);
--    signal puf_response : STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0);--delete it with enc
    
    attribute keep_hierarchy : string;
    attribute DONT_TOUCH     : string;
    attribute RLOC_ORIGIN    : string;
    
attribute keep_hierarchy of RODCU_0 : label is "TRUE";
attribute dont_touch     of RODCU_0 : label is "TRUE";
attribute keep_hierarchy of RODCU_1 : label is "TRUE";
attribute dont_touch     of RODCU_1 : label is "TRUE";
attribute keep_hierarchy of RODCU_2 : label is "TRUE";
attribute dont_touch     of RODCU_2 : label is "TRUE";
attribute keep_hierarchy of RODCU_3 : label is "TRUE";
attribute dont_touch     of RODCU_3 : label is "TRUE";
attribute keep_hierarchy of RODCU_4 : label is "TRUE";
attribute dont_touch     of RODCU_4 : label is "TRUE";
attribute keep_hierarchy of RODCU_5 : label is "TRUE";
attribute dont_touch     of RODCU_5 : label is "TRUE";
attribute keep_hierarchy of RODCU_6 : label is "TRUE";
attribute dont_touch     of RODCU_6 : label is "TRUE";
attribute keep_hierarchy of RODCU_7 : label is "TRUE";
attribute dont_touch     of RODCU_7 : label is "TRUE";
attribute keep_hierarchy of RODCU_8 : label is "TRUE";
attribute dont_touch     of RODCU_8 : label is "TRUE";
attribute keep_hierarchy of RODCU_9 : label is "TRUE";
attribute dont_touch     of RODCU_9 : label is "TRUE";

attribute keep_hierarchy of COUNTER_Instances : label is "TRUE";
attribute dont_touch     of COUNTER_Instances : label is "TRUE";
attribute keep_hierarchy of COMP_Instances : label is "TRUE";
attribute dont_touch     of COMP_Instances : label is "TRUE";
attribute keep_hierarchy of gen_xor : label is "TRUE";
attribute dont_touch     of gen_xor : label is "TRUE";  
attribute keep_hierarchy of u_ShiftRegister : label is "TRUE";
attribute dont_touch     of u_ShiftRegister : label is "TRUE";
attribute keep_hierarchy of u_LFSR : label is "TRUE";
attribute dont_touch     of u_LFSR : label is "TRUE";
attribute keep_hierarchy of control_inst : label is "TRUE";
attribute dont_touch     of control_inst : label is "TRUE";


attribute DONT_TOUCH of ro_en1 : signal is "TRUE";
attribute KEEP_HIERARCHY of gen_roen : label is "TRUE";


attribute RLOC_ORIGIN of COUNTER_Instances : label is "X29Y0";

begin
-- CI1 <=c(INPUT_WIDTH-1 downto 64);
 CI1 <= c;
-- ro_en1 <= roEN;
--gen_roen : for i in 0 to 2*K_XOR-1 generate
--begin
--  ro_en_reg : process(clk)
--  begin
--    if rising_edge(clk) then
--      ro_en1(i) <= roEN;
--    end if;
--  end process;
--end generate;
gen_roen : for i in 0 to 9 generate
begin
  roen_ff : FDRE
    generic map (INIT => '0')
    port map (
      Q => ro_en1(i),
      C => clk,
      CE => '1',
      R => '0',
      D => roEN
    );
end generate;

-- CI2 <=c(INPUT_WIDTH-1 downto 64);
-- SEL1<=c(SEL_WIDTH-1 downto 0);
-- SEL2<=c(SEL_WIDTH+SEL_WIDTH-1 downto SEL_WIDTH);
    -- Clock Wizard
--    u_clk_wiz: clk_wiz_0
--        port map (
--            clk_out1 => open,  -- 100MHz
--            clk_out2 => clk_out, --50Mhz
--            clk_out3 => open, --20MHz
--            reset => reset_clk,  -- Reset signal for the Clocking Wizard
--            clk_in1 => clk,
--            locked => open
--        );

--     RO_Instances: 
    
--    for i in 0 to 2*K_XOR-1 generate
--    attribute keep_hierarchy of RODCU_i : label is "TRUE";
--    attribute DONT_TOUCH     of RODCU_i : label is "TRUE";
----    attribute RLOC_ORIGIN    of RODCU_i : label is "SLICE_X"&INTEGER'image(2*i )&"Y"& INTEGER'image(50);
--    begin
--        RODCU_i: RO_DCU64 
--        port map (
--            CI    => CI1,
--            RO_EN => RO_EN1(i),
--            X_i => 2*i, --this cause warning for LOC
--            RO_F  => ro_f1(i)
--        );
--    end generate RO_Instances;

RODCU_0 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+19)--it was 0
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(0),
    X_i   => 2*xx+19, -- it was 2*xx-10         -- column for LOC-based version (your current port)
    RO_F  => ro_f1(0)
  );

-- If you use RLOCs in RO_DCU64, you can also give an origin per instance:
-- attribute RLOC_ORIGIN of RODCU_0 : label is "X0Y50";

-- RO #1
RODCU_1 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+21) --it was 1
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(1),
    X_i   => 2*xx+21, --it was 2*xx-9
    RO_F  => ro_f1(1)
  );

-- attribute RLOC_ORIGIN of RODCU_1 : label is "X2Y50";

-- RO #2
RODCU_2 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+23)
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(2),
    X_i   => 2*xx+23,--it was 2*xx-8
    RO_F  => ro_f1(2)
  );

-- RO #3
RODCU_3 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+25)
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(3),
    X_i   => 2*xx+25,--it was 2*xx-7
    RO_F  => ro_f1(3)
  );
  
-- RO #4
RODCU_4 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+27)
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(4),
    X_i   => 2*xx+27,--it was 2*xx-6
    RO_F  => ro_f1(4)
  );

-- RO #5
RODCU_5 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+29)
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(5),
    X_i   => 2*xx+29,--it was 2*xx-5
    RO_F  => ro_f1(5)
  );

-- RO #6
RODCU_6 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+31)
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(6),
    X_i   => 2*xx+31,--it was 2*xx-4
    RO_F  => ro_f1(6)
  );

-- RO #7
RODCU_7 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+33)
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(7),
    X_i   => 2*xx+33,--it was 2*xx-3
    RO_F  => ro_f1(7)
  );

-- RO #8
RODCU_8 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+35)
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(8),
    X_i   => 2*xx+35,-- it was 2*xx-2
    RO_F  => ro_f1(8)
  );

-- RO #9
RODCU_9 : entity work.RO_DCU64
  generic map (X_COL=>2*xx+37)--it was 9
  port map (
    CI    => CI1,
    RO_EN => RO_EN1(9),
    X_i   => 2*xx+37,---it was 2*xx-1
    RO_F  => ro_f1(9)
  );


ro_f1_out(2*K_XOR-1 downto 0) <=ro_f1(2*K_XOR-1 downto 0);
--------------------------------------------------------------------------
-- RO Counters :----------------------------------------------------------

    COUNTER_Instances: 
    for i in 0 to 2*K_XOR-1 generate
    begin
        COUNTER_i: ro_counter 
        generic map (
        COUNTER_WIDTH => COUNTER_WIDTH,
        RING_OSC_DEPTH => RING_OSC_DEPTH)
      port map (
        clk      => clk,
        rst      => cnt_rst,
        start    => cnt_start(i),
        ro_in    => ro_f1_out(i),        
        count_out=> count(i),
        done     => finished1(i)
        );
    end generate COUNTER_Instances;
    -- Latch counter results only when done = '1' :
    process(clk)
    begin
      if rising_edge(clk) then
        for i in 0 to 2*K_XOR-1 loop
          if finished1(i) = '1' then
            count_latched(i) <= count(i);
          end if;
        end loop;
      end if;
    end process;

    -- Reduction AND: high only when all counters are finished
finished_and(0) <= finished1(0);

gen_and: for i in 1 to 2*K_XOR-1 generate
begin
  finished_and(i) <= finished_and(i-1) and finished1(i);
end generate;

finished_all <= finished_and(2*K_XOR-1);

--------------------------------------------------------------------------
-- Comparators use latched values (stable):    
    COMP_Instances: 
    for i in 0 to K_XOR-1 generate
    begin
        COMP_i: comparator
        generic map ( WIDTH => COUNTER_WIDTH)
        port map (
            val_a => count_latched(i),
            val_b => count_latched(2*K_XOR-1-i),
            result => comp_out(i)
        );
    end generate COMP_Instances;
--------------------------------------------------------------------------
-- XOR tree: -------------------------------------------------------------   
    xor_chain(0) <= comp_out(0) xor comp_out(1);

    gen_xor: for i in 2 to K_XOR-1 generate
    begin
        xor_chain(i-1) <= xor_chain(i-2) xor comp_out(i);
    end generate;

    puf_bit <= xor_chain(K_XOR-2);  -- Final XOR output

--------------------------------------------------------------------------
-- Shift Register: only enabled when all counters are finished -----------   
    u_ShiftRegister: entity work.shiftReg
    generic map (
        WIDTH => OUTPUT_WIDTH)
        port map (
            clk => clk,
            clr_shift => shift_clr,
            data_in => puf_bit,
            en => srEN_gated,
            data_out =>shift_out,
            done  => shift_done 
        );
        puf_response<= shift_out;
--        srEN_gated <=srEN and finished_all;
        srEN_gated <=srEN;
        
    u_LFSR: entity work.LFSR
      generic map(
        g_Num_Bits => INPUT_WIDTH
        )
      port map(
        i_Clk    => clk,
        i_Rst    => reset,
        i_Enable => lfsrEN,    
        i_Seed_DV   => seed_DV,
        i_Seed_Data => challenge,
         
        o_LFSR_Data => c
        );
--     control_inst : entity work.control_PUF
--        port map (
--            clk => clk,
--            start => puf_start,
--            refcount => refcount,
--            lfsrDV => seed_DV,
--            countEN => countEN,
--            refEN => refEN,
--            lfsrEN => lfsrEN,
--            srEN => srEN,
--            roEN => roEN,
--            countReset => countReset,
--            done => open
--        ); 
control_inst : entity work.control_PUF
  generic map (
    OUTPUT_WIDTH => OUTPUT_WIDTH,
    N_COUNTERS   => 2*K_XOR
  )
  port map (
    clk         => clk,
    rst         => reset,
    start       => puf_start,

    finished_all=> finished_all,
    shift_done  => shift_done,

    lfsrDV      => seed_DV,
    lfsrEN      => lfsrEN,
    roEN        => roEN,          -- if you don't gate ROs globally, leave open
    cnt_start   => cnt_start,           -- your ena(i) to ro_counters
    cnt_rst     => cnt_rst,
    srEN        => srEN,          -- replaces your old srEN wiring
    shift_clr   => shift_clr,          -- connect when you add clr to shiftReg
    puf_done    => puf_done,           -- or drive PUF_DONE from here instead of shift_done
    led0    => led0,
    led1    => open,
    led2    => led2,
    led3    => led3,
    busy        => puf_busy
  );
led1<=shift_done;
--  puf_done <= shift_done; 
       
--   enc: encoder128
--  port map(
--    x =>puf_response,
--    y => puf_response2
--  );   
end Behavioral;