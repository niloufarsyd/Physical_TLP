----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:19:21 12/05/2020 
-- Design Name: 
-- Module Name:    TOP_D - Behavioral 
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
--USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
library UNISIM;
use UNISIM.VComponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PUF_and_CONTROL is
	PORT(
		CLK_PUF   : IN std_logic;
		CLK_CONTROLLER   : IN std_logic;
		w     : IN std_logic;
		Reset : IN std_logic;
		ChallengeA  : IN std_logic_vector(5 downto 0);
		ChallengeB  : IN std_logic_vector(5 downto 0);
		PUF		:out std_logic;
		PUF_OUT64: OUT std_logic_vector(63 downto 0)
		);
end PUF_and_CONTROL;

architecture Behavioral of PUF_and_CONTROL is
---------------------------------------
signal S_XOR_OUT, S_Difference, S_mux_sel, S_aclr, S_en, S_cnt_en, s_reg_clr ,latch_en :std_logic;
SIGNAL CI    :std_logic_vector(7 downto 0);
SIGNAL CI_en :std_logic;
---------------------------------------
	COMPONENT CONTROLLER
	PORT(
		clock : IN std_logic;
		w : IN std_logic;
		Reset : IN std_logic;
		Difference : IN std_logic;
		XOR_OUT : IN std_logic;
		CI_out:inout std_logic_vector(7 downto 0);
		en : OUT std_logic;
		a_clr : OUT std_logic;
		reg_clr:out std_logic;
		latch_en:out std_logic;
		cnt_en_ar : OUT std_logic;
		mux_sel : OUT std_logic;
		CI_en : OUT std_logic
		);
	END COMPONENT;
	

----------------------------------------------
	COMPONENT PUF1
	PORT(
		CLK : IN std_logic;
		cnt_EN : IN std_logic;
		latch_en:in std_logic;
		aCLR : IN std_logic;
		reg_clr:in std_logic;
	--	SEL : IN std_logic;
		CI_EN:IN std_logic;
		CI : IN std_logic_vector(5 downto 0);
		ChallengeA : IN std_logic_vector(5 downto 0);
		ChallengeB : IN std_logic_vector(5 downto 0);
		en : IN std_logic;
		mux_sel : IN std_logic;          
		XOR_OUT : OUT std_logic;
		Difference : OUT std_logic;
		PUF:out std_logic;
		PUF_OUT64 : OUT std_logic_vector(63 downto 0)
		);
	END COMPONENT;
	

begin

	Inst_CONTROLLER: CONTROLLER PORT MAP(
		clock =>CLK_CONTROLLER ,
		w => W,
		Reset =>RESET ,
		Difference => S_Difference,
		XOR_OUT => S_XOR_OUT,
		CI_out=>CI,
		latch_en=>latch_en,
		en => S_en,
		a_clr => S_aclr,
		reg_clr=> s_reg_clr,
		cnt_en_ar => S_cnt_en,
		mux_sel => S_mux_sel,
		CI_en=>CI_EN
	);
	
Inst_PUF: PUF1 PORT MAP(
		CLK => CLK_PUF,
		cnt_EN => S_cnt_en,
		latch_en=>latch_en,
		aCLR => S_aclr,
		reg_clr=> s_reg_clr,
	--	SEL=>SEL,
	   CI_EN=> CI_EN,
		CI => CI(5 downto 0),
		ChallengeA => ChallengeA,
		ChallengeB => ChallengeB,
		en => '1',
		mux_sel => S_mux_sel,
		XOR_OUT => S_XOR_OUT,
		Difference => S_Difference,
		PUF=>PUF,
		PUF_OUT64 =>PUF_OUT64 
	);

end Behavioral;

