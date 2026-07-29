----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:08:39 01/26/2020 
-- Design Name: 
-- Module Name:    RO_PUF_Main - Behavioral 
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
----------------------------------------------------------------------------------
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
---delay_clk: The amount of clock cycles to allow enable to be on.
---ro_PUF_width:The amount of PUFs to have in parallel
---RO_sel: The width of the selector for PUF mux and decoder
---clock:Clock for the state machine
---w:Allows the state machine to leave the start state on high.
---reset: resets the state machine back to start state
---selA: Select an RO
---selB: Select another RO for comparison to the first
---res_ar: The result of each PUF.
entity RO_PUF_Main is
generic ( delay_clk : integer := 125000;
			ro_PUF_width : integer := 8;
			--RO_sel : integer := 2 or 8!
			RO_sel : integer := 8);
Port ( clk_machine, clk_array, w, reset : in STD_LOGIC;
		selA, selB : in STD_LOGIC_VECTOR (RO_sel-1 downto 0);
		res_ar : out STD_LOGIC);
end RO_PUF_Main;
----------------
architecture Behavioral of RO_PUF_Main is



component PUF_Machine IS
generic (delay : integer := 125000);
	PORT ( clock,w,Reset : in std_logic;
			en,a_clr,cnt_en_ar : out std_logic);
END component;
--------------
component PUF_Array is
generic (puf_Width : integer := 8;
--sel_width_ar : integer := 8
sel_width_ar : integer := 5);
	port( clk, en_ar, aclr_ar, cnt_en_ar: in std_logic;
			selA : IN STD_LOGIC_VECTOR(sel_width_ar - 1 DOWNTO 0);
			selB : IN STD_LOGIC_VECTOR(sel_width_ar - 1 DOWNTO 0);
			res_ar: out std_logic);
end component;
--------------
signal m_en, m_clr, m_cnt_en : std_logic;
begin

------------
state_mac :PUF_Machine GENERIC MAP(delay => delay_clk)
PORT MAP(clock => clk_machine,
			w => w,
			Reset => reset,
			en=>m_en,
			a_clr=>m_clr,
			cnt_en_ar=>m_cnt_en
			);
------------
puf_ar :PUF_Array GENERIC MAP(puf_width => ro_PUF_width, sel_width_ar=>RO_sel)
PORT MAP(clk=> clk_array,
			en_ar=>m_en,
			aclr_ar=>m_clr,
			cnt_en_ar=>m_cnt_en,
			selA=>selA,
			selB=>selB,
			res_ar=>res_ar
			);
end Behavioral;