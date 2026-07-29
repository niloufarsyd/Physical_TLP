----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:02:30 02/07/2021 
-- Design Name: 
-- Module Name:    PUF_TOP - Behavioral 
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

entity PUF_TOP is
PORT(
			i_CLK   : in  STD_LOGIC;
			i_RESET : in  STD_LOGIC;
			---------------------
			i_DIPData : in  STD_LOGIC;
			o_DIPLatch:OUT STD_LOGIC;
			o_PSCLK:OUT STD_LOGIC;
			DS_REG:OUT std_logic_vector(6 downto 0);
			DS_EN :OUT std_logic_vector(3 downto 0);
			DS_DP :OUT std_logic;
			PUF_OUT1 : out  STD_LOGIC

			);
			---------------------
end PUF_TOP;

architecture Behavioral of PUF_TOP is
----Digital Clock Manager:
component DCM2
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT_5M          : out    std_logic;
  CLK_OUT_7M          : out    std_logic;
  CLK_OUT_8M          : out    std_logic;
  CLK_OUT_10M          : out    std_logic;
  CLK_OUT_20M          : out    std_logic
 );
end component;
-------------------------------------------------------

-------------------------------------------------------
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
--------------------------------------------------------
	COMPONENT PUF_and_CONTROL
	PORT(
		CLK_PUF : IN std_logic;
		CLK_CONTROLLER : IN std_logic;
		w : IN std_logic;
		Reset : IN std_logic;
		ChallengeA : IN std_logic_vector(5 downto 0);
		ChallengeB : IN std_logic_vector(5 downto 0);        
		PUF : OUT std_logic;
		PUF_OUT64 : OUT std_logic_vector(63 downto 0)
		);
	END COMPONENT;
---------------------------------------------------------
	COMPONENT SEVEN_SEGMENT_4
	PORT(
		clk : IN std_logic;
		num1 : IN std_logic_vector(3 downto 0);
		num2 : IN std_logic_vector(3 downto 0);
		num3 : IN std_logic_vector(3 downto 0);
		num4 : IN std_logic_vector(3 downto 0);          
		ds_en : OUT std_logic_vector(3 downto 0);
		ds_reg : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;	
---------------------------------------------------------
	signal s_CLK_5M,s_CLK_8M,s_CLK_10M ,s_CLK_20M: std_logic := '0';
	signal s_LEDs   :std_logic_vector(15 downto 0);
	signal s_DIP    :std_logic_vector(15 downto 0);	
	signal m_en, m_clr, m_cnt_en, w , reset,res_ar: std_logic;
	signal s_PUF64   :std_logic_vector(63 downto 0);
	signal s_PUF     :std_logic;

---------------------------------------------------------
begin
o_PSCLK<= not s_clk_5M;

second_DCM_unit : DCM2
  port map
   (-- Clock in ports
    CLK_IN1 => i_CLK,
    -- Clock out ports
    CLK_OUT_5M => s_clk_5M,
    CLK_OUT_7M => open,
    CLK_OUT_8M => s_clk_8M,
    CLK_OUT_10M => S_CLK_10M,
    CLK_OUT_20M => S_CLK_20M);
------------------------------------
Inst_SIPO_DIP: SIPO  PORT MAP(
		i_CLK => S_CLK_5M,
		o_Data => s_DIP,
		i_Data => i_DIPData,
		o_CLK => open,
		o_Latch => o_DIPLatch
	);
------

	Inst_PUF_and_CONTROL: PUF_and_CONTROL PORT MAP(
		CLK_PUF          => S_CLK_10M,
		CLK_CONTROLLER   => S_CLK_10M,
		w =>     s_DIP(7),
		Reset => i_RESET,
		ChallengeA =>  s_DIP(5 DOWNTO 0),
		ChallengeB =>  s_DIP(13 DOWNTO 8),		 
		PUF              => S_PUF,
		PUF_OUT64        => S_PUF64
	);
-----
	Inst_SEVEN_SEGMENT_4: SEVEN_SEGMENT_4 PORT MAP(
		clk =>S_CLK_10M ,
		num1 => S_PUF64(3 DOWNTO 0),
		num2 => S_PUF64(7 DOWNTO 4),
		num3 => S_PUF64(11 DOWNTO 8),
		num4 => S_PUF64(15 DOWNTO 12),
		ds_en => DS_EN,
		ds_reg =>DS_REG 
	);
	
DS_DP   <='0';	
PUF_OUT1<= NOT S_PUF;


end Behavioral;

