----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:50:07 01/07/2021 
-- Design Name: 
-- Module Name:    TEST_PUF1 - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity TEST_PUF1 is
PORT(
			i_CLK   : in  STD_LOGIC;
		--	i_RESET : in  STD_LOGIC;
			---------------------
			i_DIPData : in  STD_LOGIC;
			o_DIPLatch:OUT STD_LOGIC;
			o_PSCLK:OUT STD_LOGIC;
			i_CI:in STD_LOGIC_vector(4 downto 0);
			---------------------
			--LED1 : out  STD_LOGIC;
			--LED2 : out  STD_LOGIC;
			--LED3 : out  STD_LOGIC;
			PUF_OUT1 : out  STD_LOGIC
);
end TEST_PUF1;

architecture Behavioral of TEST_PUF1 is
------------------------------------------------------
----Digital Clock Manager:
component DCM2
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;--5MHz
  CLK_OUT2          : out    std_logic;--7MHz
  CLK_OUT3          : out    std_logic;--8MHz
  CLK_OUT4          : out    std_logic---10MHz
 );
end component;	
----------------------------------------------------
----Serial Input,Parallel Output used for Dip Switches:
COMPONENT SIPO

PORT(
	i_CLK : IN std_logic;
	i_Data : IN std_logic;          
	o_Data : OUT std_logic_vector(15 downto 0);
	o_CLK : OUT std_logic;
	o_Latch : OUT std_logic
	);
END COMPONENT;	
---
	
	COMPONENT RO_DCU_HardMacro2
	PORT(
		
		CI : IN std_logic_vector(4 downto 0);
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
		clk : IN std_logic;
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
signal RO_EN ,RO_F  :std_logic_vector(63 downto 0);
signal muxA,muxB    :std_logic;
signal cntA ,cntB   :std_logic_vector(31 downto 0);
signal L1, L2, S_COMP, S_Difference ,s_mux,S_XOR_OUT :std_logic;

 
  attribute LOC : string;
	------
		signal s_CLK_5M,s_CLK_10M : std_logic := '0';
		signal res_ar : std_logic;
		signal s_DIP    :std_logic_vector(15 downto 0);
	--	signal ci    :std_logic_vector(4 downto 0);
	------
begin
o_PSCLK <= 	not s_CLK_5M;
--CI<="01010";
second_DCM : DCM2
  port map
   (-- Clock in ports
    CLK_IN1 => i_CLK,
    -- Clock out ports
    CLK_OUT1 => s_clk_5M,
    CLK_OUT2 => open,
    CLK_OUT3 => OPEN,
    CLK_OUT4 => s_CLK_10M);
------------------------------------
Inst_SIPO_DIP: SIPO

	   PORT MAP(
		i_CLK => s_CLK_5M,
		o_Data => s_DIP,
		i_Data => i_DIPData,
		o_CLK => open,
		o_Latch => o_DIPLatch
	);

------------------------------------
	Inst_Decoder_D: Decoder_D PORT MAP(
		en =>'1' ,
		inA =>s_DIP(5 downto 0) ,
		inB =>s_DIP(13 downto 8) ,
		output =>RO_EN 
	);
-----------------------------------------------------------------------------------
	Generate_RO1:
	for I in 0 to 50 generate
		---Sets the location of RO on the  FPGA
		attribute LOC of inst_RO_HardMACRO1 : label is "SLICE_X"&INTEGER'image(2 )&"Y"& INTEGER'image(I+2);--ro_row*4 last time!(with error)
	begin
		inst_RO_HardMACRO1 : RO_DCU_HardMacro2
			port map( I_CI, RO_En(I), RO_F(I));
	end generate Generate_RO1;
------	
	Generate_RO2:
	for I in 51 to 63 generate
		---Sets the location of RO on the  FPGA
		attribute LOC of inst_RO_HardMACRO2 : label is "SLICE_X"&INTEGER'image(4 )&"Y"& INTEGER'image(I-49);--ro_row*4 last time!(with error)
	begin
		inst_RO_HardMACRO2 : RO_DCU_HardMacro2
			port map(I_CI, RO_En(I), RO_F(I));
	end generate Generate_RO2;

-------------------------------------------------------
	Inst_Multiplexer_D_1: Multiplexer_D PORT MAP(
		Sel =>s_DIP(5 downto 0) ,
		dati =>RO_F ,
		dato => muxA
	);
	Inst_Multiplexer_D_2: Multiplexer_D PORT MAP(
		Sel =>s_DIP(13 downto 8) ,
		dati =>RO_F ,
		dato => muxB
	);
-------------------------------------------------------
-------------------------------------------------------
Inst_my_counter1: my_counter PORT MAP(
	clk => s_CLK_10M,
	PULSE_IN =>muxA ,
	CE =>'1' ,
	CLR =>'0' ,
	Q => cntA
	);
Inst_my_counter2: my_counter PORT MAP(
	clk => s_CLK_10M,
	PULSE_IN => muxB ,
	CE =>'1' ,
	CLR =>'0' ,
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
		clk => s_CLK_10M ,
		D =>S_COMP ,
		Q => L1
	);

	Inst_D_latch2: D_latch PORT MAP(
		clk => s_CLK_10M,
		D => L1,
		Q => L2
	);
---------------------------
s_XOR_OUT<=L1 XOR L2;

---------------------------
	Inst_Multiplexer_2to1_1: Multiplexer_2to1 PORT MAP(
		A => L1,
		B => '0',
		sel =>s_XOR_OUT ,
		dato =>s_mux 
	);
		Inst_Multiplexer_2to1_2: Multiplexer_2to1 PORT MAP(
		A => s_mux,
		B =>s_COMP  ,
		sel =>S_Difference ,
		dato => RES_AR
	);

----------------------------------
--if (S_Difference='1') then
-- PUF_OUT<=S_COMP;
--
--elsif (Difference='0') then
--
--
--end if;

----------------------------------
PUF_OUT1<=not RES_AR;

end Behavioral;

