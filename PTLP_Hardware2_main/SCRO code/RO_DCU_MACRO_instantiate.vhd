----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:44:42 11/29/2020 
-- Design Name: 
-- Module Name:    RO_DCU_MACRO_instantiate - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

--entity RO_DCU_MACRO_instantiate is
--	PORT(
--		CI : IN std_logic_vector(4 downto 0);
--		RO_EN  : IN  std_logic_vector(31 downto 0);         
--		RO_F  : OUT std_logic_vector(31 downto 0)
--		);
--end RO_DCU_MACRO_instantiate;

entity PUF1 is
	PORT(
		CLK   :in std_logic;
		cnt_EN:in std_logic;
		latch_en:in std_logic;
		aCLR	:in std_logic;
		reg_clr:in std_logic;
	--	SEL	:in std_logic;
		CI_EN :in std_logic;
		CI		:in std_logic_vector(5 downto 0);
		ChallengeA	:in std_logic_vector(5 downto 0);
		ChallengeB  :in std_logic_vector(5 downto 0);
		en		:in std_logic;
		mux_sel   :in std_logic;
		XOR_OUT : OUT std_logic;
		Difference:out std_logic;
		PUF:out std_logic;
		PUF_OUT64 : OUT std_logic_vector(63 downto 0)
		);
end PUF1;

architecture Behavioral of PUF1 is

	COMPONENT SCRO_HARDMACRO
	PORT(
		
		CI    : IN std_logic_vector(5 downto 0); 
		SEL   : IN std_logic;
		RO_EN : IN std_logic;
		RO_F  : OUT std_logic
		);
	END COMPONENT;	
-------------------------------------------------
	COMPONENT Decoder_D
	PORT(
		en : IN std_logic;
		inA : IN std_logic_vector(5 downto 0);
		inB : IN std_logic_vector(5 downto 0);          
		output : OUT std_logic_vector(63 downto 0)
		);
	END COMPONENT;

---------------------------------------------------
	COMPONENT Multiplexer_D
	PORT(
		Sel : IN std_logic_vector(5 downto 0);
		dati : IN std_logic_vector(63 downto 0);          
		dato : OUT std_logic
		);
	END COMPONENT;
-------------------------------------------------
	COMPONENT my_counter
	PORT(
		clk : in std_logic;
		PULSE_IN : IN std_logic;
		CE : IN std_logic;
		CLR : IN std_logic; 		
		Q : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
-------------------------------------------------
	COMPONENT my_COMPARE
	PORT(
		A : IN std_logic_vector(31 downto 0);
		B : IN std_logic_vector(31 downto 0);          
		diff : OUT std_logic;
		GTh : OUT std_logic
		);
	END COMPONENT;
-------------------------------------------------	
	COMPONENT D_latch
	PORT(
		CLK : IN std_logic;
		en : in  STD_LOGIC;
		D : IN std_logic;          
		Q : OUT std_logic
		);
	END COMPONENT;
-------------------------------------------------
	
	COMPONENT Multiplexer_2to1
	PORT(
		A : IN std_logic;
		B : IN std_logic;
		sel : IN std_logic;          
		dato : OUT std_logic
		);
	END COMPONENT;
-------------------------------------------------
	COMPONENT PUF_OUT_REGISTER
	PORT(
		reg_clr : in   STD_LOGIC;
		PUF_i : IN std_logic;
		EN : IN std_logic;
		CLK : IN std_logic;          
		PUF_o : OUT std_logic_vector(63 downto 0)
		);
	END COMPONENT;
	
-------------------------------------------------
signal RO_EN ,RO_F  :std_logic_vector(63 downto 0);
signal muxA,muxB    :std_logic;
signal cntA ,cntB   :std_logic_vector(31 downto 0);
signal L1, L2, S_COMP, S_Difference ,s_mux :std_logic;
SIGNAL PUF_OUT:std_logic;
 
  attribute LOC : string;
begin

	Inst_Decoder_D: Decoder_D PORT MAP(
		en =>en ,
		inA =>ChallengeA ,
		inB =>ChallengeB ,
		output =>RO_EN 
	);
-----------------------------------------------------------------------------------
	Generate_RO1:
	for I in 0 to 50 generate
		---Sets the location of RO on the  FPGA
		attribute LOC of inst_RO_HardMACRO1 : label is "SLICE_X"&INTEGER'image(2 )&"Y"& INTEGER'image(I+2);--ro_row*4 last time!(with error)
	begin
		inst_RO_HardMACRO1 : SCRO_HARDMACRO
			port map( CI, PUF_OUT, RO_En(I), RO_F(I));
	end generate Generate_RO1;
------	
	Generate_RO2:
	for I in 51 to 63 generate
		---Sets the location of RO on the  FPGA
		attribute LOC of inst_RO_HardMACRO2 : label is "SLICE_X"&INTEGER'image(4 )&"Y"& INTEGER'image(I-49);--ro_row*4 last time!(with error)
	begin
		inst_RO_HardMACRO2 : SCRO_HARDMACRO
			port map(CI, PUF_OUT, RO_En(I), RO_F(I));
	end generate Generate_RO2;

-------------------------------------------------------
	Inst_Multiplexer_D_1: Multiplexer_D PORT MAP(
		Sel =>ChallengeA ,
		dati =>RO_F ,
		dato => muxA
	);
	Inst_Multiplexer_D_2: Multiplexer_D PORT MAP(
		Sel =>ChallengeB ,
		dati =>RO_F ,
		dato => muxB
	);
-------------------------------------------------------
Inst_my_counter1: my_counter PORT MAP(
	clk => CLK,
	PULSE_IN =>muxA ,
	CE =>cnt_en ,
	CLR =>aclr ,
	Q => cntA
	);
Inst_my_counter2: my_counter PORT MAP(
	clk => CLK,
	PULSE_IN =>muxB ,
	CE =>cnt_en ,
	CLR =>aclr ,
	Q => cntB
	);
-------------------------------------------------------	

	Inst_my_COMPARE: my_COMPARE PORT MAP(
		A =>cntA ,
		B =>cntB ,
		diff =>S_Difference ,
		GTh => S_COMP
	);
		Inst_D_latch1: D_latch PORT MAP(
		clk => CLK,
		en=> latch_en,
		D =>S_COMP ,
		Q => L1
	);

	Inst_D_latch2: D_latch PORT MAP(
		clk => CLK,
		en=> latch_en,
		D => L1,
		Q => L2
	);
---------------------------
XOR_OUT<=L1 XOR L2;
Difference<=S_Difference;
---------------------------
	Inst_Multiplexer_2to1_1: Multiplexer_2to1 PORT MAP(
		A => L1,
		B => '0',
		sel =>mux_sel ,
		dato =>s_mux 
	);
		Inst_Multiplexer_2to1_2: Multiplexer_2to1 PORT MAP(
		A => s_mux,
		B =>s_COMP  ,
		sel =>S_Difference ,
		dato => PUF_OUT
	);
PUF<= PUF_OUT;
-----------------------
	Inst_PUF_OUT_REGISTER: PUF_OUT_REGISTER PORT MAP(
	   reg_clr =>reg_clr ,
		PUF_i => PUF_OUT,
		EN => CI_en,
		CLK => CLK,
		PUF_o => PUF_OUT64
	);


end Behavioral;

