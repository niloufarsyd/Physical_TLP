----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:24:54 11/22/2020 
-- Design Name: 
-- Module Name:    DCU4 - Behavioral 
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
------------------------------------------------------
-------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DCU4 is
  Port ( DCU_IN  : in  STD_LOGIC;
         C  	  : in  STD_LOGIC;
         DCU_OUT : out  STD_LOGIC);
end DCU4;

architecture Behavioral of DCU4 is


component my_or
	port ( A, B : in std_logic;
			 REZ  : out std_logic);
end component;
--------------
component my_and
port ( A, B : in std_logic;
REZ : out std_logic);
end component;
--------------
signal S:std_logic;
attribute KEEP: string ;
attribute KEEP of S: signal  is  " true " ; 

	attribute rloc: string;
	attribute rloc of inst_or: label is "X7Y8";
	attribute rloc of inst_and: label is "X7Y8";
begin

inst_or	:  my_or  port map (A=>DCU_IN, B=>C, REZ=>S);
inst_and :  my_and port map (A=>DCU_IN, B=>S, REZ=>DCU_OUT);
end Behavioral;



