----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:05:56 12/06/2020 
-- Design Name: 
-- Module Name:    RO_DCU_MACRO_ARRAY - Behavioral 
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

entity RO_DCU_MACRO_ARRAY is
	PORT(
		CI : IN std_logic_vector(4 downto 0);
		RO_EN  : IN  std_logic_vector(63 downto 0);         
		RO_F  : OUT std_logic_vector(63 downto 0)
		);
end RO_DCU_MACRO_ARRAY;

architecture Behavioral of RO_DCU_MACRO_ARRAY is
	COMPONENT RO_DCU_MACRO
	PORT(
		CI : IN std_logic_vector(4 downto 0);
		RO_EN : IN std_logic;          
		RO_F  : OUT std_logic
		);
	END COMPONENT;
begin
	Inst_RO_DCU_MACRO_1: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(0),
		RO_F => RO_F(0)
	);

	Inst_RO_DCU_MACRO_2: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(1) ,
		RO_F => RO_F(1)
	);

	Inst_RO_DCU_MACRO_3: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(2),
		RO_F => RO_F(2)
	);

	Inst_RO_DCU_MACRO_4: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(3) ,
		RO_F => RO_F(3)
	);

	Inst_RO_DCU_MACRO_5: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(4),
		RO_F => RO_F(4)
	);

	Inst_RO_DCU_MACRO_6: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(5) ,
		RO_F => RO_F(5)
	);

	Inst_RO_DCU_MACRO_7: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(6),
		RO_F => RO_F(6)
	);

	Inst_RO_DCU_MACRO_8: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(7) ,
		RO_F => RO_F(7)
	);

	Inst_RO_DCU_MACRO_9: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(8),
		RO_F => RO_F(8)
	);

	Inst_RO_DCU_MACRO_10: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(9) ,
		RO_F => RO_F(9)
	);

	Inst_RO_DCU_MACRO_11: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(10),
		RO_F => RO_F(10)
	);

	Inst_RO_DCU_MACRO_12: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(11) ,
		RO_F => RO_F(11)
	);

	Inst_RO_DCU_MACRO_13: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(12),
		RO_F => RO_F(12)
	);

	Inst_RO_DCU_MACRO_14: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(13) ,
		RO_F => RO_F(13)
	);

	Inst_RO_DCU_MACRO_15: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(14),
		RO_F => RO_F(14)
	);

	Inst_RO_DCU_MACRO_16: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(15) ,
		RO_F => RO_F(15)
	);

	Inst_RO_DCU_MACRO_17: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(16),
		RO_F => RO_F(16)
	);

	Inst_RO_DCU_MACRO_18: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(17) ,
		RO_F => RO_F(17)
	);

	Inst_RO_DCU_MACRO_19: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(18),
		RO_F => RO_F(18)
	);

	Inst_RO_DCU_MACRO_20: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(19) ,
		RO_F => RO_F(19)
	);

	Inst_RO_DCU_MACRO_21: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(20),
		RO_F => RO_F(20)
	);

	Inst_RO_DCU_MACRO_22: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(21) ,
		RO_F => RO_F(21)
	);

	Inst_RO_DCU_MACRO_23: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(22) ,
		RO_F => RO_F(22)
	);

	Inst_RO_DCU_MACRO_24: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(23) ,
		RO_F => RO_F(23)
	);

	Inst_RO_DCU_MACRO_25: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(24) ,
		RO_F => RO_F(24)
	);

	Inst_RO_DCU_MACRO_26: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(25) ,
		RO_F => RO_F(25)
	);

	Inst_RO_DCU_MACRO_27: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(26) ,
		RO_F => RO_F(26)
	);

	Inst_RO_DCU_MACRO_28: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(27) ,
		RO_F => RO_F(27)
	);

	Inst_RO_DCU_MACRO_29: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(28) ,
		RO_F => RO_F(28)
	);

	Inst_RO_DCU_MACRO_30: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(29) ,
		RO_F => RO_F(29)
	);
	Inst_RO_DCU_MACRO_31: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(30) ,
		RO_F => RO_F(30)
	);
	Inst_RO_DCU_MACRO_32: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(31) ,
		RO_F => RO_F(31)
	);
	Inst_RO_DCU_MACRO_33: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(32) ,
		RO_F => RO_F(32)
	);
	Inst_RO_DCU_MACRO_34: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(33) ,
		RO_F => RO_F(33)
	);
	Inst_RO_DCU_MACRO_35: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(34) ,
		RO_F => RO_F(34)
	);
	Inst_RO_DCU_MACRO_36: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(35) ,
		RO_F => RO_F(35)
	);
	Inst_RO_DCU_MACRO_37: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(36) ,
		RO_F => RO_F(36)
	);
	Inst_RO_DCU_MACRO_38: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(37) ,
		RO_F => RO_F(37)
	);
	Inst_RO_DCU_MACRO_39: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(38) ,
		RO_F => RO_F(38)
	);
	Inst_RO_DCU_MACRO_40: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(39) ,
		RO_F => RO_F(39)
	);
	Inst_RO_DCU_MACRO_41: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(40) ,
		RO_F => RO_F(40)
	);
	Inst_RO_DCU_MACRO_42: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(41) ,
		RO_F => RO_F(41)
	);
	Inst_RO_DCU_MACRO_43: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(42) ,
		RO_F => RO_F(42)
	);
	Inst_RO_DCU_MACRO_44: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(43) ,
		RO_F => RO_F(43)
	);
	Inst_RO_DCU_MACRO_45: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(44) ,
		RO_F => RO_F(44)
	);
	Inst_RO_DCU_MACRO_46: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(45) ,
		RO_F => RO_F(45)
	);
	Inst_RO_DCU_MACRO_47: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(46) ,
		RO_F => RO_F(46)
	);
	Inst_RO_DCU_MACRO_48: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(47) ,
		RO_F => RO_F(47)
	);
	Inst_RO_DCU_MACRO_49: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(48) ,
		RO_F => RO_F(48)
	);
	Inst_RO_DCU_MACRO_50: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(49) ,
		RO_F => RO_F(49)
	);
	Inst_RO_DCU_MACRO_51: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(50) ,
		RO_F => RO_F(50)
	);
		Inst_RO_DCU_MACRO_52: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(51) ,
		RO_F => RO_F(51)
	);
		Inst_RO_DCU_MACRO_53: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(52) ,
		RO_F => RO_F(52)
	);

		Inst_RO_DCU_MACRO_54: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(53) ,
		RO_F => RO_F(53)
	);

		Inst_RO_DCU_MACRO_55: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(54) ,
		RO_F => RO_F(54)
	);

		Inst_RO_DCU_MACRO_56: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(55) ,
		RO_F => RO_F(55)
	);

		Inst_RO_DCU_MACRO_57: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(56) ,
		RO_F => RO_F(56)
	);

		Inst_RO_DCU_MACRO_58: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(57) ,
		RO_F => RO_F(57)
	);

		Inst_RO_DCU_MACRO_59: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(58) ,
		RO_F => RO_F(58)
	);

		Inst_RO_DCU_MACRO_60: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(59) ,
		RO_F => RO_F(59)
	);

		Inst_RO_DCU_MACRO_61: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(60) ,
		RO_F => RO_F(60)
	);

		Inst_RO_DCU_MACRO_62: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(61) ,
		RO_F => RO_F(61)
	);

		Inst_RO_DCU_MACRO_63: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(62) ,
		RO_F => RO_F(62)
	);
	

		Inst_RO_DCU_MACRO_64: RO_DCU_MACRO PORT MAP(
		CI => CI,
		RO_EN =>RO_EN(63) ,
		RO_F => RO_F(63)
	);

end Behavioral;

