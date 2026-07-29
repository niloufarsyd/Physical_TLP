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

entity SCRO is
    Port ( CI    : in  STD_LOGIC_VECTOR (5 downto 0);
           RO_EN : in  STD_LOGIC;
			  SEL   : in  STD_LOGIC;
           RO_F  : out STD_LOGIC);
end SCRO;

architecture Behavioral of SCRO is

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
COMPONENT Multiplexer_2to1
PORT(
	A : IN std_logic;
	B : IN std_logic;
	sel : IN std_logic;          
	dato : OUT std_logic
	);
END COMPONENT;
----------------
signal S:std_logic_vector(7 downto 0);
-------------------------------------------
attribute KEEP: string ;
attribute KEEP of S: signal  is  " true " ; 
-------------------------------------------
signal D:std_logic_vector(5 downto 0);

attribute KEEP of D: signal  is  " true " ; 
-------------------------------------------
--attribute rloc: string;

--attribute rloc of inst_or_DCU3   : label is "X11Y2";
--attribute rloc of inst_nand_DCU3 : label is "X11Y2";
--
--attribute rloc of inst_and_DCU2_1: label is "X11Y2";
--attribute rloc of inst_or_DCU2_1 : label is "X11Y2";
--	
--attribute rloc of inst_and_DCU1	: label is "X11Y2";
--attribute rloc of inst_nor_DCU1  : label is "X11Y2";
--
--attribute rloc of inst_or_DCU4   : label is "X11Y2";
--attribute rloc of inst_and_DCU4  : label is "X11Y2";
--
--attribute rloc of inst_and_DCU2_2: label is "X10Y2";
--attribute rloc of inst_or_DCU2_2 : label is "X10Y2";
--attribute rloc of Inst_nand   	: label is "X10Y2";
--
-->--DOWN-
--attribute rloc of Inst_Multiplexer_2to1_1: label is "X11Y2";


--attribute rloc of inst_or_DCU3   : label is "X11Y2";
--attribute rloc of inst_nand_DCU3 : label is "X11Y2";
--
--attribute rloc of inst_and_DCU2_1: label is "X11Y2";
--attribute rloc of inst_or_DCU2_1 : label is "X11Y2";
--	
--attribute rloc of inst_and_DCU1	: label is "X11Y2";
--attribute rloc of inst_nor_DCU1  : label is "X11Y2";
--
--attribute rloc of inst_or_DCU4_1   : label is "X10Y2";
--attribute rloc of inst_and_DCU4_1  : label is "X10Y2";
--
--attribute rloc of inst_and_DCU2_2: label is "X10Y2";
--attribute rloc of inst_or_DCU2_2 : label is "X10Y2";
--
--attribute rloc of inst_or_DCU4_2   : label is "X10Y2";
--attribute rloc of inst_and_DCU4_2  : label is "X10Y2";
--
--attribute rloc of Inst_nand   		     : label is "X10Y2";
-->>-UP
--attribute rloc of Inst_nand   : label is "X3Y8";
--
--attribute rloc of inst_or_DCU3 :   label is "X4Y8";
--attribute rloc of inst_nand_DCU3:  label is "X4Y8";
--
--attribute rloc of inst_and_DCU2_1: label is "X5Y8";
--attribute rloc of inst_or_DCU2_1 : label is "X5Y8";
--	
--attribute rloc of inst_and_DCU1	: label is "X6Y8";
--attribute rloc of inst_nor_DCU1  : label is "X6Y8";
--
--attribute rloc of inst_or_DCU4 : label is "X7Y8";
--attribute rloc of inst_and_DCU4   : label is "X7Y8";
--
--attribute rloc of inst_and_DCU2_2   : label is "X7Y8";
--attribute rloc of inst_or_DCU2_2 : label is "X7Y8";	

-----------------------------------------------------
begin

-------------------------------------------------------------------
inst_nand:  my_nand port map (A=>RO_EN, B=>S(7), REZ=>S(0));	
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
inst_or_DCU4_1	:  my_or  port map (A=>CI(3), B=>S(3), REZ=>D(3));
inst_and_DCU4_1  :  my_and port map (A=>D(3) , B=>S(3), REZ=>S(4));
-------------------------------------------------------------------
--DCU2:
inst_and_DCU2_2:  my_and port map (A=>CI(4), B=>S(4), REZ=>D(4));
inst_or_DCU2_2 :  my_or  port map (A=>D(4) , B=>S(4), REZ=>S(5));
-------------------------------------------------------------------
--DCU4:
inst_or_DCU4_2	:  my_or  port map (A=>CI(5), B=>S(5), REZ=>D(5));
inst_and_DCU4_2  :  my_and port map (A=>D(5) , B=>S(5), REZ=>S(6));
-------------------------------------------------------------------
-------------------------------------------------------------------
--inst_buffer1 : LUT1
--	generic map (
--	INIT => "10") -- initialized as a buffer
--	port map (
--	O => S(6), -- LUT general output
--	I0 => S(5) -- LUT input
--	);
---------------------------------------------------------------------
--inst_buffer2 : LUT1
--	generic map (
--	INIT => "10") -- initialized as a buffer
--	port map (
--	O => S(7), -- LUT general output
--	I0 => S(6) -- LUT input
--	);
-------------------------------------------------------------------
Inst_MUX: Multiplexer_2to1 PORT MAP(
	A => S(4),
	B => S(6),
	sel =>sel ,
	dato =>S(7) 
	);
RO_F<=S(7);
end Behavioral;

