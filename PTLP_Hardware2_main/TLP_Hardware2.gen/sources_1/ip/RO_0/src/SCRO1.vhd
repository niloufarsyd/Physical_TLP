----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2025 03:39:53 PM
-- Design Name: 
-- Module Name: SCRO1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SCRO1 is
    Port ( CI : in STD_LOGIC_VECTOR (63 downto 0);
           --CI : in STD_LOGIC_VECTOR (127 downto 0);
           RO_EN : in STD_LOGIC;
           --SEL : in STD_LOGIC;
           RO_F : out STD_LOGIC);
    
    attribute DONT_TOUCH : string;
    attribute KEEP_HIERARCHY : string;
    attribute DONT_TOUCH of SCRO1 : entity is "TRUE";
    attribute KEEP_HIERARCHY of SCRO1 : entity is "TRUE";
end SCRO1;

architecture Behavioral of SCRO1 is
component SCRO
    Port ( CI    : in  STD_LOGIC_VECTOR (63 downto 0);
           RO_EN : in  STD_LOGIC;
			SEL   : in  STD_LOGIC;
           RO_F  : out STD_LOGIC);
end component;
component SCRO_L
    Port ( CI    : in  STD_LOGIC_VECTOR (63 downto 0);
           RO_EN : in  STD_LOGIC;
			SEL   : in  STD_LOGIC;
           RO_F  : out STD_LOGIC);
end component;
component SCRO_128
    Port ( CI    : in  STD_LOGIC_VECTOR (127 downto 0);
           RO_EN : in  STD_LOGIC;
			SEL   : in  STD_LOGIC;
           RO_F  : out STD_LOGIC);
end component;
component RO_DCU
    Port ( CI    : in  STD_LOGIC_VECTOR (63 downto 0);
           RO_EN : in  STD_LOGIC;
			
           RO_F  : out STD_LOGIC);
end component;
attribute DONT_TOUCH of SCRO_1 : label is "TRUE";
attribute KEEP_HIERARCHY of SCRO_1 : label is "TRUE";
--attribute DONT_TOUCH of SCRO_1 : label is "TRUE";
--attribute KEEP_HIERARCHY of SCRO_1 : label is "TRUE";

begin

    --SCRO_0: SCRO_L port map (CI=> CI, RO_EN => RO_EN, SEL => SEL, RO_F => RO_F);
    --SCRO_1: SCRO_128 port map (CI=> CI, RO_EN => RO_EN, SEL => SEL, RO_F => RO_F);
    SCRO_1: RO_DCU port map (CI=> CI, RO_EN => RO_EN, RO_F => RO_F);

end Behavioral;
