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

entity SCRO is
    Port ( CI : in STD_LOGIC_VECTOR (63 downto 0);
           RO_EN : in STD_LOGIC;
           RO_F : out STD_LOGIC);
    
    attribute DONT_TOUCH : string;
    attribute KEEP_HIERARCHY : string;
    attribute DONT_TOUCH of SCRO : entity is "TRUE";
    attribute KEEP_HIERARCHY of SCRO : entity is "TRUE";
end SCRO;

architecture Behavioral of SCRO is
component RO_0
    Port ( CI    : in  STD_LOGIC_VECTOR (63 downto 0);
           RO_EN : in  STD_LOGIC;
           RO_F  : out STD_LOGIC);
end component;

attribute DONT_TOUCH of RO_2 : label is "TRUE";
attribute KEEP_HIERARCHY of RO_2 : label is "TRUE";

begin

    --SCRO_0: SCRO_L port map (CI=> CI, RO_EN => RO_EN, SEL => SEL, RO_F => RO_F);
    --SCRO_1: SCRO_128 port map (CI=> CI, RO_EN => RO_EN, SEL => SEL, RO_F => RO_F);
    RO_2: RO_0 port map (CI=> CI, RO_EN => RO_EN, RO_F => RO_F);

end Behavioral;
