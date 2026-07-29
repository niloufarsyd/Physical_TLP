
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity PUF_TopModule is
GENERIC (ro_PUF_width : INTEGER :=8; 
				RO_sel : INTEGER :=8);
    Port ( 
			i_CLK : in  STD_LOGIC;
			
			o_PSCLK : out  STD_LOGIC;
			
			o_LEDData : out  STD_LOGIC;
			o_LEDLatch : out  STD_LOGIC;
			
			o_DIPLatch : out  STD_LOGIC;
			i_DIPData : in  STD_LOGIC;
						
			i_SYS_RESET : in  STD_LOGIC
			  );
end PUF_TopModule;

architecture Behavioral of PUF_TopModule is

-------------------------------------------------------
----Digital Clock Manager:
component DCM2
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;--5MHz
  CLK_OUT2          : out    std_logic;--7MHz
  CLK_OUT3          : out    std_logic;--8MHz
  CLK_OUT4          : out    std_logic---10MHz
 );
end component;	
-------------------------------------------------------
----PUF circuit:
component PUF is
generic (puf_Width : integer := 8; sel_width_ar : integer := 5);
	port( clk, en_ar, aclr_ar, cnt_en_ar: in std_logic;
			selA : IN STD_LOGIC_VECTOR(sel_width_ar - 1 DOWNTO 0);
			selB : IN STD_LOGIC_VECTOR(sel_width_ar - 1 DOWNTO 0);
			res_ar: out std_logic);
end component;
-------------------------------------------------------	
----state machine as a controller:
component Machine IS
generic (delay : integer := 125000);
	PORT ( clock,w,Reset : in std_logic;
			en,a_clr,cnt_en_ar : out std_logic);--controller bits for puf
END component;
-------------------------------------------------------
----paralle Input,Serial Output used for LEDs:
COMPONENT PISO
generic (g_DataWidth : integer);
PORT(
	i_CLK : IN std_logic;
	i_Data : IN std_logic_vector(15 downto 0);          
	o_CLK : OUT std_logic;
	o_Data : OUT std_logic;
	o_Latch : OUT std_logic
	);
END COMPONENT;
-------------------------------------------------------
----Serial Input,Parallel Output used for Dip Switches:
COMPONENT SIPO
generic (g_DataWidth : integer);
PORT(
	i_CLK : IN std_logic;
	i_Data : IN std_logic;          
	o_Data : OUT std_logic_vector(23 downto 0);
	o_CLK : OUT std_logic;
	o_Latch : OUT std_logic
	);
END COMPONENT;	
--------------------------------------------------------
	signal m_en, m_clr, m_cnt_en, w , reset,res_ar : std_logic;
	signal s_CLK_5M,s_CLK_8M : std_logic := '0';
	signal s_LEDs   :std_logic_vector(15 downto 0);
	signal s_DIP    :std_logic_vector(15 downto 0);
	signal selA,selB    :std_logic_vector(7 downto 0);
---------------------------------------------------------
---------------------------------------------------------		
begin

o_PSCLK <= 	not s_CLK_5M;

second_DCM : DCM2
  port map
   (-- Clock in ports
    CLK_IN1 => i_CLK,
    -- Clock out ports
    CLK_OUT1 => s_clk_5M,
    CLK_OUT2 => open,
    CLK_OUT3 => s_CLK_8M,
    CLK_OUT4 => open);
------------------------------------
Inst_SIPO_DIP: 
		SIPO generic map (g_DataWidth => 24)
	   PORT MAP(
		i_CLK => s_CLK_5M,
		o_Data(23 downto 8) => s_DIP,
		o_Data(7 downto 3) => open,
		o_Data(2) => open,		
		o_Data(1) => open,
		o_Data(0) => open,
		i_Data => i_DIPData,
		o_CLK => open,
		o_Latch => o_DIPLatch
	);

------------------------------------
state_mac :Machine GENERIC MAP(delay => 12500000)
PORT MAP(clock => s_CLK_5M,
			w => w,--------------used for enable sampling and counting in a specific period of time
			Reset => reset,------reset state machine
			en=>m_en,------------enable Ring Oscillators
			a_clr=>m_clr,--------CLeaR counters
			cnt_en_ar=>m_cnt_en--enable Counting
			);
			
w       <= s_DIP(7);
reset   <= s_DIP(6);
------------------------------------
puf_ar :PUF GENERIC MAP(puf_width => ro_PUF_width, sel_width_ar=>RO_sel)
PORT MAP(clk=> s_CLK_8M,
			en_ar=>m_en,----------enable Ring Oscillators
			aclr_ar=>m_clr,-------CLeaR counters
			cnt_en_ar=>m_cnt_en,--enable Counting
			selA=>selA,-----------selects of multiplexerA and decoder
			selB=>selB,-----------bit selects of multiplexerB and decoder
			res_ar=>res_ar--------puf output
			);
			
selA   <= s_DIP(7   downto 0);--SelA used for bit selects of multiplexerA and decoder
selB   <= s_DIP(15  downto 8);--SelB used for bit selects of multiplexerB and decoder			
s_LEDs(7)<=res_ar;--show puf result in seventh LED			
------------------------------------
---assign zero value to unused leds:
s_LEDs(6  downto 0) <= "0000000";
s_LEDs(15 downto 8) <= "00000000";
------------------------------------	
Inst_PISO_LED:
		PISO generic map (g_DataWidth => 16)
		PORT MAP(
		i_CLK  => s_CLK_5M,
		i_Data => s_LEDs,
		o_CLK  => open,
		o_Data => o_LEDData,
		o_Latch => o_LEDLatch
	);
end Behavioral;

