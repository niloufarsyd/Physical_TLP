------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date:    08:28:19 03/11/2020 
---- Design Name: 
---- Module Name:    RO - Behavioral 
---- Project Name: 
---- Target Devices: 
---- Tool versions: 
---- Description: 
----
---- Dependencies: 
----
---- Revision: 
---- Revision 0.01 - File Created
---- Additional Comments: 
----
------------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--
---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;
--
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
----library UNISIM;
----use UNISIM.VComponents.all;
--
--
--
--entity RO is
--    Port ( en : in  STD_LOGIC; 
--           os  : out STD_LOGIC);
--end RO;
--
--architecture Behavioral of RO is
----  signal ring    : std_logic_vector(2 downto 0); -- ungerade Bitanzahl
--  signal ring    : std_logic_vector(5 downto 0); -- ungerade Bitanzahl
--  attribute KEEP : string; 
--  attribute KEEP of ring : signal is "true"; 
--begin
--  --assert ring'length mod 2 = 1 report "Length of ring must be an odd number!" severity failure;
--
--  process (ring,en) begin
--     for i in ring'range loop
--       if i = ring'left then
--		 ring(i)<=not(en and ring(1));
----         if reset='1' then
----           ring(i) <= '1';
----         else
----           ring(i) <= not ring(0) after 1ns;
----         end if;
--       else
--         ring(i)   <= not ring(i+1) after 1ns;
--       end if;
--     end loop;
--  end process;
--
--  os <= ring(0);
--
--end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity RO is
port(En : in std_logic;
	  Os : out std_logic);
end RO;

architecture Behavioral of RO is

	attribute rloc: string;
--	attribute rloc of inst_nand: label is "X10Y2";
--	attribute rloc of inst_Inv1: label is "X10Y2";
--	attribute rloc of inst_Inv2: label is "X10Y2";
--	attribute rloc of inst_Inv3: label is "X10Y2";
--	attribute rloc of inst_Inv4: label is "X11Y2";
	attribute rloc of inst_nand: label is "X7Y8";
	attribute rloc of inst_Inv1: label is "X7Y8";
	attribute rloc of inst_Inv2: label is "X7Y8";
	attribute rloc of inst_Inv3: label is "X7Y8";
	attribute rloc of inst_Inv4: label is "X5Y8";
	
signal c:std_logic_vector(3 downto 0);
signal s_Os:std_logic;

attribute KEEP: string ;
  attribute KEEP of c: signal  is  " true " ; 
begin

	inst_nand : LUT2
		generic map (
		INIT => X"7") -- initialized as a NAND
		port map (
		O => C(3) , -- LUT general output
		I0 => en, -- LUT input
		I1 => s_os -- LUT input
		);


	inst_Inv1 : LUT1
		generic map (
		INIT => "01") -- initialized as a NOT
		port map (
		O => C(2) , -- LUT general output
		I0 => C(3)  -- LUT input
		);
		
	inst_Inv2 : LUT1
		generic map (
		INIT => "01") -- initialized as a NOT
		port map (
		O => C(1), -- LUT general output
		I0 => C(2) -- LUT input
		);
		
	inst_Inv3 : LUT1
		generic map (
		INIT => "01") -- initialized as a NOT
		port map (
		O => C(0), -- LUT general output
		I0 => C(1) -- LUT input
		);
		
	inst_Inv4 : LUT1
		generic map (
		INIT => "01") -- initialized as a NOT
		port map (
		O => s_os, -- LUT general output
		I0 => C(0) -- LUT input
		);
		os<=s_os;
end Behavioral;