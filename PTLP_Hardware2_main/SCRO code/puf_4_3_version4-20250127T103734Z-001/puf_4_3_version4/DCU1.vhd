----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:26:04 11/17/2020 
-- Design Name: 
-- Module Name:    DCU1 - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DCU1 is
    Port ( DCU_IN  : in  STD_LOGIC;
           C 		 : in  STD_LOGIC;
           DCU_OUT : out  STD_LOGIC);
end DCU1;

architecture Behavioral of DCU1 is

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
signal S:std_logic;
attribute KEEP: string ;
attribute KEEP of S: signal  is  " true " ; 

	attribute rloc: string;
	attribute rloc of inst_and: label is "X7Y8";
	attribute rloc of inst_nor: label is "X7Y8";

begin

--	inst_nor : LUT2
--		generic map (
--		INIT => "0001") -- initialized as a NOR
--		port map (
--		O =>  DCU_OUT , -- LUT general output
--		I0 => DCU_IN, -- LUT input
--		I1 => S -- LUT input
--		);
--		
--	inst_and : LUT2
--		generic map (
--		INIT => "1000") -- initialized as a AND
--		port map (
--		O =>  S , -- LUT general output
--		I0 => DCU_IN, -- LUT input
--		I1 => C -- LUT input
--		);
--		
inst_and: my_and port map (A=>DCU_IN, B=>C, REZ=>S);
inst_nor:  my_nor port map (A=>DCU_IN, B=>S, REZ=>DCU_OUT);

end Behavioral;

