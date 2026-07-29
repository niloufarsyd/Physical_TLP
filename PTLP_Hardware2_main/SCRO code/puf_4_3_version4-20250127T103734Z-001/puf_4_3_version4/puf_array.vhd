----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:58:32 01/26/2020 
-- Design Name: 
-- Module Name:    PUF_Array - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;

--------------------------------------------------------
---puf_width: The amount of PUFs to have in parallel
---sel_width_ar:The select width for the mux and decoders in PUF
---en_ar: Enables the RO
---aclr_ar: Clears counters that counts oscillations
---cnt_en_ar: enables the counters.
---selA: Select an RO
---selB: Select another RO for comparison to the first
---res_ar: The result of the comparisons between 2 counters. 1 if RO A> RO B
entity PUF is
	generic (puf_Width	 : integer := 8;   --8 8ta blocke puf-bit parallel mishavand
				sel_width_ar : integer := 8);
	port( clk, en_ar, aclr_ar, cnt_en_ar: in std_logic;
			selA : IN STD_LOGIC_VECTOR(sel_width_ar - 1 DOWNTO 0);
			selB : IN STD_LOGIC_VECTOR(sel_width_ar - 1 DOWNTO 0);
			res_ar: out std_logic);
end PUF;
-----------------------------------------------------------------------------------
architecture block_diagram of PUF is
	
	
	COMPONENT puf_bit
		GENERIC (Sel_Size_p : INTEGER :=8; 
				row : INTEGER :=1);
	PORT(
		clk  : IN std_logic;
		en   : IN std_logic;
		selA : IN std_logic_vector(7 downto 0);
		selB : IN std_logic_vector(7 downto 0);
		aclr : IN std_logic;
		cnt_en : IN std_logic;          
		res : OUT std_logic
		);
	END COMPONENT;
	
attribute rLOC : string;
attribute rloc of pufX1: label is "X2Y3";
	
begin
----unfortunately we had to instantiate just one module of puf_bit because or hardware overhead
----we couldn't instantiate more "puf_bit"s
pufX1 :puf_bit
	GENERIC MAP(Sel_Size_p => sel_width_ar,
	row =>1)
	PORT MAP(clk=>clk,
				en => en_ar,
				selA => selA,
				selB => selB,
				aclr => aclr_ar,
				cnt_en => cnt_en_ar,
				Res => res_ar);	
				
end block_diagram;