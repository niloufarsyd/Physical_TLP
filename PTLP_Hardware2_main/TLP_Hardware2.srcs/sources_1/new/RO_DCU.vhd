library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity RO_DCU is
    Port ( CI    : in  STD_LOGIC_VECTOR (63 downto 0);
           RO_EN : in  STD_LOGIC;
		   X_i   : in  integer;
           RO_F  : out STD_LOGIC);
           
           attribute DONT_TOUCH : string;
           attribute KEEP_HIERARCHY : string;
           attribute DONT_TOUCH of RO_DCU : entity is "TRUE";
           attribute KEEP_HIERARCHY of RO_DCU : entity is "TRUE";
           
end RO_DCU;

architecture Behavioral of RO_DCU is

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
signal S:std_logic_vector(64 downto 0);
signal F:std_logic;
-------------------------------------------
attribute KEEP: string ;
attribute KEEP of S: signal  is  " true " ; 
-------------------------------------------
signal D:std_logic_vector(63 downto 0);

attribute KEEP of D: signal  is  " true " ; 
-------------------------------------------	
attribute BEL  : string;
attribute Rloc : string;
attribute Rloc of inst_nand  : label is "SLICE_X"&INTEGER'image(0)&"Y"& INTEGER'image(82);

attribute DONT_TOUCH of inst_nand  : label is "TRUE";
attribute KEEP of inst_nand  : label is "TRUE";

begin

---------------------------------------------------------------------
inst_nand:  my_nand port map (A=>RO_EN, B=>S(64), REZ=>S(0));	
---------------------------------------------------------------------

-------------------------------------------------------------------
Generate_RO1:
	for I in 0 to 15 generate
		
		attribute DONT_TOUCH of inst_or_DCU3  : label is "TRUE";
        attribute KEEP of inst_or_DCU3  : label is "TRUE";
        attribute BEL  of inst_or_DCU3  : label is "A6LUT";
        
        attribute DONT_TOUCH of inst_nand_DCU3 : label is "TRUE";
        attribute KEEP of inst_nand_DCU3 : label is "TRUE";
        attribute BEL  of inst_nand_DCU3 : label is "B6LUT";
        
        attribute DONT_TOUCH of inst_and_DCU2 : label is "TRUE";
        attribute KEEP of inst_and_DCU2 : label is "TRUE";
        attribute BEL  of inst_and_DCU2 : label is "A6LUT";

        attribute DONT_TOUCH of inst_or_DCU2 : label is "TRUE";
        attribute KEEP of inst_or_DCU2 : label is "TRUE";
        attribute BEL  of inst_or_DCU2 : label is "B6LUT";

        attribute DONT_TOUCH of inst_and_DCU1 : label is "TRUE";
        attribute KEEP of inst_and_DCU1 : label is "TRUE";
        attribute BEL  of inst_and_DCU1 : label is "A6lUT";

        attribute DONT_TOUCH of inst_nor_DCU1 : label is "TRUE";
        attribute KEEP of inst_nor_DCU1 : label is "TRUE";
        attribute BEL  of inst_nor_DCU1 : label is "B6LUT";

        attribute DONT_TOUCH of inst_or_DCU4 : label is "TRUE";
        attribute KEEP of inst_or_DCU4 : label is "TRUE";
        attribute BEL  of inst_or_DCU4 : label is "A6lUT";

        attribute DONT_TOUCH of inst_and_DCU4 : label is "TRUE";
        attribute KEEP of inst_and_DCU4 : label is "TRUE";
        attribute BEL  of inst_and_DCU4 : label is "B6LUT";
        
        
        attribute RLOC of inst_or_DCU3  : label is "SLICE_X"&INTEGER'image(0 )&"Y"& INTEGER'image(2*I+50);--ro_row*4 last time!(with error)
		attribute RLOC of inst_nand_DCU3: label is "SLICE_X"&INTEGER'image(0 )&"Y"& INTEGER'image(2*I+50);
		
		attribute RLOC of inst_and_DCU2: label is "SLICE_X"&INTEGER'image(0 )&"Y"& INTEGER'image(2*I+50);
		attribute RLOC of inst_or_DCU2: label is "SLICE_X"&INTEGER'image(0 )&"Y"& INTEGER'image(2*I+50);
		
		attribute RLOC of inst_and_DCU1: label is "SLICE_X"&INTEGER'image(0 )&"Y"& INTEGER'image(2*I+51);
		attribute RLOC of inst_nor_DCU1: label is "SLICE_X"&INTEGER'image(0 )&"Y"& INTEGER'image(2*I+51);
		
		attribute RLOC of inst_or_DCU4: label is "SLICE_X"&INTEGER'image(0 )&"Y"& INTEGER'image(2*I+51);
		attribute RLOC of inst_and_DCU4: label is "SLICE_X"&INTEGER'image(0 )&"Y"& INTEGER'image(2*I+51);
        
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

RO_F<=S(64);
end Behavioral;