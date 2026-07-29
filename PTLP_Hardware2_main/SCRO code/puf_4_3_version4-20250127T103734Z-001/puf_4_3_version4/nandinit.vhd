----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:36:00 11/24/2020 
-- Design Name: 
-- Module Name:    nandinit - Behavioral 
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

entity nandinit is
    Port ( CI    : in  STD_LOGIC_VECTOR (4 downto 0);
           RO_EN : in  STD_LOGIC;
           RO_F  : out STD_LOGIC);
end nandinit;

architecture Behavioral of nandinit is



-------------	
component my_or
	port ( A, B : in std_logic;
			 REZ  : out std_logic);
end component;
--------------
component my_nand
port ( A, B : in std_logic;
REZ : out std_logic);
end component;
--------------
component my_and
	port ( A, B : in std_logic;
			 REZ  : out std_logic);
end component;
--------------
component my_nor
port ( A, B : in std_logic;
REZ : out std_logic);
end component;
--------------
signal S:std_logic_vector(5 downto 0);
attribute KEEP: string ;
attribute KEEP of S: signal  is  " true " ; 
-------------------------------------------
signal D:std_logic_vector(4 downto 0);

attribute KEEP of D: signal  is  " true " ; 
-------------------------------------------
attribute rloc: string;


--attribute rloc of inst_or_DCU3  :   label is "X11Y2";
--attribute rloc of inst_nand_DCU3:  label is "X11Y2";
--
--attribute rloc of inst_and_DCU2_1: label is "X11Y2";
--attribute rloc of inst_or_DCU2_1 : label is "X11Y2";
--	
--attribute rloc of inst_and_DCU1	: label is "X11Y2";
--attribute rloc of inst_nor_DCU1  : label is "X11Y2";
--
--attribute rloc of inst_or_DCU4    : label is "X11Y2";
--attribute rloc of inst_and_DCU4   : label is "X11Y2";
--
--attribute rloc of inst_and_DCU2_2   : label is "X10Y2";
--attribute rloc of inst_or_DCU2_2    : label is "X10Y2";
--attribute rloc of Inst_nand   : label is "X10Y2";

	
attribute rloc of inst_or_DCU3  :   label is "X11Y2";
attribute rloc of inst_nand_DCU3:  label is "X11Y2";

attribute rloc of inst_and_DCU2_1: label is "X11Y2";
attribute rloc of inst_or_DCU2_1 : label is "X11Y2";
	
attribute rloc of inst_and_DCU1	: label is "X11Y2";
attribute rloc of inst_nor_DCU1  : label is "X11Y2";

attribute rloc of inst_or_DCU4    : label is "X11Y2";
attribute rloc of inst_and_DCU4   : label is "X11Y2";

attribute rloc of inst_and_DCU2_2   : label is "X10Y2";
attribute rloc of inst_or_DCU2_2    : label is "X10Y2";
attribute rloc of Inst_nand   : label is "X10Y2";	

-----------------------------------------------------
begin
--		inst_nand1 : LUT2
--		generic map (
--		INIT => X"7") -- initialized as a NAND
--		port map (
--		O => S , -- LUT general output
--		I0 => A, -- LUT input
--		I1 => B -- LUT input
--		);
--		inst_nand2 : LUT2
--		generic map (
--		INIT => X"7") -- initialized as a NAND
--		port map (
--		O => S2 , -- LUT general output
--		I0 => A, -- LUT input
--		I1 => S -- LUT input
--		);	

--inst_nand:  my_nand port map (A=>A, B=>B, REZ=>S);		
--inst_nand3:  my_nand port map (A=>A, B=>S, REZ=>S2);		
--
------------------------------
--	Inst_DCU3: DCU3 PORT MAP(
--		DCU_IN =>S2 ,
--		C =>B ,
--		DCU_OUT =>REZ 
--	);
-----------------------------
inst_nand:  my_nand port map (A=>RO_EN, B=>S(5), REZ=>S(0));	
-------------------------------------------------------------------
--DCU3:
inst_or_DCU3	: my_or   port map (A=>CI(0), B=>S(0), REZ=>D(0));
inst_nand_DCU3 : my_nand port map (A=>D(0) , B=>S(0), REZ=>S(1));
-------------------------------------------------------------------
--DCU2:
inst_and_DCU2_1:  my_and port map (A=>CI(1), B=>S(1), REZ=>D(1));
inst_or_DCU2_1 :  my_or  port map (A=>D(1) , B=>S(1), REZ=>S(2));
-------------------------------------------------------------------
--DCU1:		
inst_and_DCU1:    my_and port map (A=>CI(2), B=>S(2), REZ=>D(2));
inst_nor_DCU1:    my_nor port map (A=>D(2) , B=>S(2), REZ=>S(3));
-------------------------------------------------------------------
--DCU4:
inst_or_DCU4	:  my_or  port map (A=>CI(3), B=>S(3), REZ=>D(3));
inst_and_DCU4  :  my_and port map (A=>D(3) , B=>S(3), REZ=>S(4));
-------------------------------------------------------------------
--DCU2:
inst_and_DCU2_2:  my_and port map (A=>CI(4), B=>S(4), REZ=>D(4));
inst_or_DCU2_2 :  my_or  port map (A=>D(4) , B=>S(4), REZ=>S(5));

RO_F<=S(5);

end Behavioral;

