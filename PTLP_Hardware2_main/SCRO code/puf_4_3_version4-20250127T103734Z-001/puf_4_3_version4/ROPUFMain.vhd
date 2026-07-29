----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:19:00 03/30/2020 
-- Design Name: 
-- Module Name:    ROPUFMain - Behavioral 
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
---delay_clk: The amount of clock cycles to allow enable to be on.
---ro_PUF_width:The amount of PUFs to have in parallel
---RO_sel: The width of the selector for PUF mux and decoder
---clock:Clock for the state machine
---w:Allows the state machine to leave the start state on high.
---reset: resets the state machine back to start state
---selA: Select an RO
---selB: Select another RO for comparison to the first
---res_ar: The result of each PUF.
entity ROPUFMain is
generic ( delay_clk : integer := 125000;
			RO_sel : integer := 8;
			sel_width_ar : integer := 8;
			Sel_Size_p   : integer := 8);
	
Port ( clock, w, reset : in STD_LOGIC;
		selA, selB : in STD_LOGIC_VECTOR (RO_sel-1 downto 0);
		res_ar : out STD_LOGIC);
end ROPUFMain;


architecture Behavioral of ROPUFMain is

component PUF_Machine IS
generic (delay : integer := 125000);
	PORT ( clock,w,Reset : in std_logic;
			en,a_clr,cnt_en_ar : out std_logic);
END component;
--------------
	COMPONENT puf_bit
	GENERIC (Sel_Size_p : INTEGER;
	row : INTEGER);
	PORT( en : in STD_LOGIC;
			selA : in STD_LOGIC_VECTOR (Sel_Size_p-1 downto 0);
			selB : in STD_LOGIC_VECTOR (Sel_Size_p-1 downto 0);
			aclr : in STD_LOGIC;
			cnt_en : in STD_LOGIC;
			res : out STD_LOGIC);
	END COMPONENT;
	
	signal m_en, m_clr, m_cnt_en : std_logic;
begin

state_mac :PUF_Machine GENERIC MAP(delay => delay_clk)
PORT MAP(clock => clock,
			w => w,
			Reset => reset,
			en=>m_en,
			a_clr=>m_clr,
			cnt_en_ar=>m_cnt_en
			);

pufX :puf_bit
GENERIC MAP(Sel_Size_p => sel_width_ar,
	row =>1)
PORT MAP(
			en => m_en,
			selA => selA,
			selB => selB,
			aclr => m_clr,
			cnt_en => m_cnt_en,
			Res => res_ar);			

end Behavioral;

