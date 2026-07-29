library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use work.SCRO_L.all;

entity SCRO_PUF is
    generic (
    INPUT_WIDTH    : integer := 128;
    OUTPUT_WIDTH   : integer :=128;
    SEL_WIDTH      : integer := 5;
    RING_OSC_DEPTH : integer := 32);
    Port (
        clk      : in  STD_LOGIC;
        reset_clk: in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        ena      : in  STD_LOGIC;
        challenge: in  STD_LOGIC_VECTOR(127 downto 0);
        --CI1, CI2      : in  STD_LOGIC_VECTOR(63 downto 0);
--        SEL1     : in  STD_LOGIC_VECTOR(4 downto 0); -- Select which RO in SCRO1
--        SEL2     : in  STD_LOGIC_VECTOR(4 downto 0); -- Select which RO in SCRO2
        puf_response  : out STD_LOGIC_VECTOR(127 downto 0)
    );
end SCRO_PUF;

architecture Behavioral of SCRO_PUF is

    -- Components
    component SCRO_L
        Port (
            CI    : in  STD_LOGIC_VECTOR (63 downto 0);
            RO_EN : in  STD_LOGIC;
            SEL   : in  STD_LOGIC;
            RO_F  : out STD_LOGIC
        );
    end component;
    
    
    component clk_wiz_0
        port (
            clk_in1  : in  STD_LOGIC;
            clk_out1 : out STD_LOGIC;
            clk_out2 : out STD_LOGIC;
            clk_out3 : out STD_LOGIC;
            reset    : in  STD_LOGIC
        );
    end component;

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
    component counter is
        generic (
          WIDTH : integer);
        port (
          clk      : in  std_logic;
          rstn     : in  std_logic;
          ena      : in  std_logic;
          finished : out std_logic;
          count    : out std_logic_vector(63 downto 0));
    end component counter;


    component comparator
        Port (
            count1 : in  UNSIGNED(15 downto 0);
            count2 : in  UNSIGNED(15 downto 0);
            result : out STD_LOGIC
        );
    end component;
    
    component shiftReg 
        Port (
            clk     : in  STD_LOGIC;
            data_in : in  STD_LOGIC;
            en      : in  STD_LOGIC;
            data_out: out STD_LOGIC_VECTOR (127 downto 0)
        );
    end component;
    
    component LFSR
      generic (
        g_Num_Bits : integer := 128
        );
      port (
        i_Clk    : in std_logic;
        i_Enable : in std_logic;
     
        -- Optional Seed Value
        i_Seed_DV   : in std_logic;
        i_Seed_Data : in std_logic_vector(g_Num_Bits-1 downto 0);
         
        o_LFSR_Data : out std_logic_vector(g_Num_Bits-1 downto 0);
        o_LFSR_Done : out std_logic
        );
   end component;
    -- Internal signals
    signal clk_sys : STD_LOGIC;
    signal clk_aux : STD_LOGIC;
    signal CI1, CI2: STD_LOGIC_VECTOR(63 downto 0);
    signal SEL1    : STD_LOGIC_VECTOR(SEL_WIDTH-1 downto 0); -- Select which RO in SCRO1
    signal SEL2    : STD_LOGIC_VECTOR(SEL_WIDTH-1 downto 0);
    signal c : STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0);
    signal ro_f1, ro_f2 : STD_LOGIC_VECTOR (31 downto 0);
    signal ro_en1, ro_en2 : STD_LOGIC_VECTOR (31 downto 0);
    signal ro_f1_out, ro_f2_out : STD_LOGIC;
    signal counter1, counter2 : std_logic_vector(63 downto 0);
    signal clk_out: STD_LOGIC;
    signal puf_bit: STD_LOGIC;
    signal start, refcount, refEN, srEN,roEN,countEN,countReset,done,en_shiftReg , lfsrEN, seed_DV, LFSR_done: STD_LOGIC;
    signal finished1, finished2 :STD_LOGIC;
begin
-- <= c(127 downto 53) xor c(74 downto 0)
 CI1 <=c(INPUT_WIDTH-1 downto 64);
 CI2 <=c(INPUT_WIDTH-1 downto 64);
 SEL1<=c(SEL_WIDTH-1 downto 0);
 SEL2<=c(SEL_WIDTH+SEL_WIDTH-1 downto SEL_WIDTH);
    -- Clock Wizard
    u_clk_wiz: clk_wiz_0
        port map (
            clk_out1 => open,  -- 100MHz
            clk_out2 => clk_out, --50Mhz
            clk_out3 => open, --20MHz
            reset => reset_clk,  -- Reset signal for the Clocking Wizard
            clk_in1 => clk
        );

 
    SCRO_Instances1: 
    for i in 0 to 31 generate
    begin
        SCRO_i: SCRO_L 
        port map (
            CI    => CI1,
            RO_EN => RO_EN1(i),
            SEL => CI1(0),
            RO_F  => ro_f1(i)
        );
    end generate SCRO_Instances1;
    
    SCRO_Instances2: 
    for i in 0 to 31 generate
    begin
        SCRO_i: SCRO_L 
        port map (
            CI    => CI2,
            RO_EN => RO_EN2(i),
            SEL => CI2(0),
            RO_F  => ro_f2(i)
        );
    end generate SCRO_Instances2;
    
    mux1: mux32to1
        port map (
            data_in => ro_f1,
            sel => SEL1,
            data_out => ro_f1_out
            );
    mux2: mux32to1
        port map (
            data_in => ro_f2,
            sel => SEL2,
            data_out => ro_f2_out 
            );

    U1_COUNTER : counter
      generic map (
        WIDTH => 64)
      port map (
        clk      => ro_f1_out,
        rstn     => reset,
        ena      => ena,
        finished => finished1,
        count    => counter1);

    U2_COUNTER : counter
      generic map (
        WIDTH => 64)
      port map (
        clk      => ro_f2_out,
        rstn     => reset,
        ena      => ena,
        finished => finished2,
        count    => counter2);
    -- Comparator to generate the PUF bit
    u_comparator: comparator
        port map (
            count1 => UNSIGNED(counter1),
            count2 => UNSIGNED(counter2),
            result => puf_bit
        );
--    u_ShiftRegister: shiftReg
--        port map (
--            clk => clk_out,
--            data_in => puf_bit,
--            en => en_shiftReg,
--            data_out => puf_response
--        );
    u_ShiftRegister: entity work.shiftReg
        port map (
            clk => clk_out,
            data_in => puf_bit,
            en => en_shiftReg,
            data_out => puf_response
        );
    u_LFSR: entity work.LFSR
      generic map(
        g_Num_Bits => 128
        )
      port map(
        i_Clk    => clk_out,
        i_Enable => lfsrEN,
     
        -- Optional Seed Value
        i_Seed_DV   => seed_DV,
        i_Seed_Data => challenge,
         
        o_LFSR_Data => c,
        o_LFSR_Done => LFSR_done
        );
     control_inst : entity work.control_PUF
        port map (
            clk => clk,
            start => start,
            refcount => refcount,
            lfsrDV => seed_DV,
            countEN => countEN,
            refEN => refEN,
            lfsrEN => lfsrEN,
            srEN => srEN,
            roEN => roEN,
            countReset => countReset,
            done => done
        );    
end Behavioral;