library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity SCRO_128 is
    Port ( CI    : in  STD_LOGIC_VECTOR (127 downto 0);
           RO_EN : in  STD_LOGIC;
			SEL   : in  STD_LOGIC;
           RO_F  : out STD_LOGIC);
           
           attribute DONT_TOUCH : string;
           attribute KEEP_HIERARCHY : string;
           attribute DONT_TOUCH of SCRO_128 : entity is "TRUE";
           attribute KEEP_HIERARCHY of SCRO_128 : entity is "TRUE";
           
end SCRO_128;

architecture Behavioral of SCRO_128 is

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
signal S:std_logic_vector(128 downto 0);
signal F:std_logic;
-------------------------------------------
attribute KEEP: string ;
attribute KEEP of S: signal  is  " true " ; 
-------------------------------------------
signal D:std_logic_vector(127 downto 0);

attribute KEEP of D: signal  is  " true " ; 
-------------------------------------------	

attribute LOC : string;
--attribute LOC of inst_nand  : label is "X31Y2";
-----------------------------------------------------
--attribute DONT_TOUCH of Generate_RO1 : label is "TRUE";
--attribute KEEP of Generate_RO1 : label is "TRUE";

--attribute DONT_TOUCH of inst_nand : label is "TRUE";
--attribute KEEP of inst_nand : label is "TRUE";



  
begin

---------------------------------------------------------------------
inst_nand:  my_nand port map (A=>RO_EN, B=>F, REZ=>S(0));	
---------------------------------------------------------------------

-------------------------------------------------------------------
Generate_RO1:
	for I in 0 to 31 generate
		---Sets the location of RO on the  FPGA
--		attribute LOC of inst_or_DCU3  : label is "SLICE_X"&INTEGER'image(31 )&"Y"& INTEGER'image(2*I+3);--ro_row*4 last time!(with error)
--		attribute LOC of inst_nand_DCU3: label is "SLICE_X"&INTEGER'image(31 )&"Y"& INTEGER'image(2*I+3);
		
--		attribute LOC of inst_and_DCU2: label is "SLICE_X"&INTEGER'image(31 )&"Y"& INTEGER'image(2*I+3);
--		attribute LOC of inst_or_DCU2: label is "SLICE_X"&INTEGER'image(31 )&"Y"& INTEGER'image(2*I+3);
		
--		attribute LOC of inst_and_DCU1: label is "SLICE_X"&INTEGER'image(31 )&"Y"& INTEGER'image(2*I+4);
--		attribute LOC of inst_nor_DCU1: label is "SLICE_X"&INTEGER'image(31 )&"Y"& INTEGER'image(2*I+4);
		
--		attribute LOC of inst_or_DCU4: label is "SLICE_X"&INTEGER'image(31 )&"Y"& INTEGER'image(2*I+4);
--		attribute LOC of inst_and_DCU4: label is "SLICE_X"&INTEGER'image(31 )&"Y"& INTEGER'image(2*I+4);
		
		
		attribute DONT_TOUCH of inst_or_DCU3  : label is "TRUE";
        attribute KEEP of inst_or_DCU3  : label is "TRUE";
        
        attribute DONT_TOUCH of inst_nand_DCU3 : label is "TRUE";
        attribute KEEP of inst_nand_DCU3 : label is "TRUE";
        
        attribute DONT_TOUCH of inst_and_DCU2 : label is "TRUE";
        attribute KEEP of inst_and_DCU2 : label is "TRUE";

        attribute DONT_TOUCH of inst_or_DCU2 : label is "TRUE";
        attribute KEEP of inst_or_DCU2 : label is "TRUE";

        attribute DONT_TOUCH of inst_and_DCU1 : label is "TRUE";
        attribute KEEP of inst_and_DCU1 : label is "TRUE";

        attribute DONT_TOUCH of inst_nor_DCU1 : label is "TRUE";
        attribute KEEP of inst_nor_DCU1 : label is "TRUE";

        attribute DONT_TOUCH of inst_or_DCU4 : label is "TRUE";
        attribute KEEP of inst_or_DCU4 : label is "TRUE";

        attribute DONT_TOUCH of inst_and_DCU4 : label is "TRUE";
        attribute KEEP of inst_and_DCU4 : label is "TRUE";
	begin
	    --DCU3:
		inst_or_DCU3  : my_or   port map (A=>CI(4*I), B=>S(4*I), REZ=>D(4*I));
        inst_nand_DCU3: my_nand port map (A=>D(4*I) , B=>S(4*I), REZ=>S(4*I+1));
        --DCU2:
        inst_and_DCU2:  my_and  port map (A=>CI(4*I+1), B=>S(4*I+1), REZ=>D(4*I+1));
        inst_or_DCU2 :  my_or   port map (A=>D(4*I+1) , B=>S(4*I+1), REZ=>S(4*I+2));
        --DCU1:		
        inst_and_DCU1:  my_and  port map (A=>CI(4*I+2), B=>S(4*I+2), REZ=>D(4*I+2));
        inst_nor_DCU1:  my_nor  port map (A=>D(4*I+2) , B=>S(4*I+2), REZ=>S(4*I+3));
        --DCU4:
        inst_or_DCU4:   my_or   port map (A=>CI(4*I+3), B=>S(4*I+3), REZ=>D(4*I+3));
        inst_and_DCU4:  my_and  port map (A=>D(4*I+3) , B=>S(4*I+3), REZ=>S(4*I+4));
        ------
	end generate Generate_RO1;
-------------------------------------------------------------------
Inst_MUX: Multiplexer_2to1 PORT MAP(
	A => S(64),
	B => S(128),
	sel =>sel ,
	dato =>F 
	);
RO_F<=S(128);
end Behavioral;