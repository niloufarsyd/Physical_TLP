library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity RO_DCU64 is
generic (
    X_COL  : integer := 0   -- column X (constant)
--    G_Y_BASE : integer := 50   -- base row Y (constant)
  );
    Port ( CI    : in  STD_LOGIC_VECTOR (63 downto 0);
           RO_EN : in  STD_LOGIC;
           X_i   : in integer;
           RO_F  : out STD_LOGIC);
           
           attribute DONT_TOUCH : string;
           attribute KEEP_HIERARCHY : string;
           attribute DONT_TOUCH of RO_DCU64 : entity is "TRUE";
           attribute KEEP_HIERARCHY of RO_DCU64 : entity is "TRUE";
           
end RO_DCU64;

architecture Behavioral of RO_DCU64 is

function nospace(s : string) return string is
begin
  if s'length>0 and s(s'low)=' ' then return s(s'low+1 to s'high); end if;
  return s;
end;

function img(i : integer) return string is
begin
  return nospace(integer'image(i));
end;

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
attribute loc : string;
--attribute loc of inst_nand  : label is "SLICE_X"& img(X_COL) &"Y"& INTEGER'image(82);
attribute loc of inst_nand  : label is "SLICE_X"& img(X_COL) &"Y"& INTEGER'image(48);
attribute DONT_TOUCH of inst_nand  : label is "TRUE";
attribute KEEP of inst_nand  : label is "TRUE";
attribute BEL  of inst_nand  : label is "A6LUT";

attribute keep_hierarchy of Generate_RO1 : label is "TRUE";--<<RECENTLY ADDED
attribute dont_touch     of Generate_RO1 : label is "TRUE";--<<RECENTLY ADDED

begin

---------------------------------------------------------------------
inst_nand:  LUT2 generic map (INIT => X"7")
            port map (O => S(0), I0 => RO_EN,   I1 => S(64));	
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
        attribute BEL  of inst_and_DCU2 : label is "C6LUT";

        attribute DONT_TOUCH of inst_or_DCU2 : label is "TRUE";
        attribute KEEP of inst_or_DCU2 : label is "TRUE";
        attribute BEL  of inst_or_DCU2 : label is "D6LUT";

        attribute DONT_TOUCH of inst_and_DCU1 : label is "TRUE";
        attribute KEEP of inst_and_DCU1 : label is "TRUE";
        attribute BEL  of inst_and_DCU1 : label is "A6lUT";

        attribute DONT_TOUCH of inst_nor_DCU1 : label is "TRUE";
        attribute KEEP of inst_nor_DCU1 : label is "TRUE";
        attribute BEL  of inst_nor_DCU1 : label is "B6LUT";

        attribute DONT_TOUCH of inst_or_DCU4 : label is "TRUE";
        attribute KEEP of inst_or_DCU4 : label is "TRUE";
        attribute BEL  of inst_or_DCU4 : label is "C6lUT";

        attribute DONT_TOUCH of inst_and_DCU4 : label is "TRUE";
        attribute KEEP of inst_and_DCU4 : label is "TRUE";
        attribute BEL  of inst_and_DCU4 : label is "D6LUT";
        
        
--        attribute LOC of inst_or_DCU3  : label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+50);--ro_row*4 last time!(with error)
--		attribute LOC of inst_nand_DCU3: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+50);
		
--		attribute LOC of inst_and_DCU2: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+50);
--		attribute LOC of inst_or_DCU2:  label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+50);
		
--		attribute LOC of inst_and_DCU1: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+51);
--		attribute LOC of inst_nor_DCU1: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+51);
		
--		attribute LOC of inst_or_DCU4:  label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+51);
--		attribute LOC of inst_and_DCU4: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+51);
        attribute LOC of inst_or_DCU3  : label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+16);--ro_row*4 last time!(with error)
		attribute LOC of inst_nand_DCU3: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+16);
		
		attribute LOC of inst_and_DCU2: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+16);
		attribute LOC of inst_or_DCU2:  label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+16);
		
		attribute LOC of inst_and_DCU1: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+17);
		attribute LOC of inst_nor_DCU1: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+17);
		
		attribute LOC of inst_or_DCU4:  label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+17);
		attribute LOC of inst_and_DCU4: label is "SLICE_X"& img(X_COL) & "Y"& INTEGER'image(2*I+17);        
	begin
	    --DCU3:
		inst_or_DCU3  : LUT2 generic map (INIT => X"E")
                        port map (O => D(4*I),   I0 => CI(4*I), I1 =>  S(4*I));
        inst_nand_DCU3: LUT2 generic map (INIT => X"7")
                        port map (O => S(4*I+1), I0 => D(4*I),   I1 => S(4*I));
        --DCU2:
        inst_and_DCU2:  LUT2 generic map (INIT => X"8")
                        port map (O => D(4*I+1), I0 => CI(4*I+1),I1 => S(4*I+1));
        inst_or_DCU2 :  LUT2 generic map (INIT => X"E")
                        port map (O => S(4*I+2), I0 => D(4*I+1), I1 => S(4*I+1));
        --DCU1:		
        inst_and_DCU1:  LUT2 generic map (INIT => X"8")
                        port map (O => D(4*I+2), I0 => CI(4*I+2),I1 => S(4*I+2));
        inst_nor_DCU1:  LUT2 generic map (INIT => X"1")
                        port map (O => S(4*I+3), I0 => D(4*I+2), I1 => S(4*I+2));
        --DCU4:
        inst_or_DCU4:   LUT2 generic map (INIT => X"E")
                        port map (O => D(4*I+3), I0 => CI(4*I+3),I1 => S(4*I+3));
        inst_and_DCU4:  LUT2 generic map (INIT => X"8")
                        port map (O => S(4*I+4), I0 => D(4*I+3), I1 => S(4*I+3));
        ------
	end generate Generate_RO1;
-------------------------------------------------------------------

RO_F<=S(64);
end Behavioral;