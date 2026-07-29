----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:54:36 01/17/2010 
-- Design Name: 
-- Module Name:    AVA6STest_TopModule - Behavioral 
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
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity AVA6STest_TopModule is
    Port ( 
			i_CLK : in  STD_LOGIC;
			
			o_PSCLK : out  STD_LOGIC;
			
			o_LEDData : out  STD_LOGIC;
			o_LEDLatch : out  STD_LOGIC;
			
			o_DIPLatch : out  STD_LOGIC;
			i_DIPData : in  STD_LOGIC;
			
			o_SEGData : out  STD_LOGIC;
			o_SEGLatch : out  STD_LOGIC;
			
			o_LCDData : out  STD_LOGIC;
			o_LCDLatch : out  STD_LOGIC;
			
			o_Eth_RST : out  STD_LOGIC;
			i_Eth_INT : in  STD_LOGIC;
			o_Eth_CS : out  STD_LOGIC;
			o_Eth_RD : out  STD_LOGIC;
			o_Eth_WR : out  STD_LOGIC;
			
			o_USB_SLOE : out  STD_LOGIC;
			io_USB_IFCLK : inout  STD_LOGIC;
			o_USB_SLRD : out  STD_LOGIC;
			o_USB_SLWR : out  STD_LOGIC;
			
			io_Data : inout  STD_LOGIC_VECTOR (7 downto 0);
			io_MuxEthUSB : inout  STD_LOGIC_VECTOR (9 downto 0);

			o_VGA_blue0	 : out STD_LOGIC;
			o_VGA_blue1	 : out STD_LOGIC;
			o_VGA_green0 : out STD_LOGIC;
			o_VGA_green1 : out STD_LOGIC;
			o_VGA_red0   : out STD_LOGIC;
			o_VGA_red1   : out STD_LOGIC;
			o_VGA_vsync  : out STD_LOGIC;
			o_VGA_hsync  : out STD_LOGIC;
			
			i_SW1	:	in STD_LOGIC;
			i_SW2	:	in STD_LOGIC;
			i_SW3	:	in STD_LOGIC;
			i_SW4	:	in STD_LOGIC;

			o_TXD1	:	out STD_LOGIC;
			i_RXD1	:	in STD_LOGIC;
			
			o_TXD2	:	out STD_LOGIC;
			i_RXD2	:	in STD_LOGIC;
			
			o_MMC_SCK	: out STD_LOGIC;
			i_MMC_DO	: in STD_LOGIC;
			o_MMC_DI	: out STD_LOGIC;
			o_MMC_CS	: out STD_LOGIC;
			
			i_SYS_RESET : in  STD_LOGIC
			  );
end AVA6STest_TopModule;

architecture Behavioral of AVA6STest_TopModule is

	COMPONENT counterNew
	PORT(
		Clk : IN std_logic;          
		Q : OUT std_logic
		);
	END COMPONENT;


-----------------------------------------------------------

	COMPONENT countTest
	PORT(
		clk : IN std_logic;          
		pul : OUT std_logic
		);
	END COMPONENT;

	component DCM1
	port
	 (-- Clock in ports
	  CLK_IN1           : in     std_logic;
	  -- Clock out ports
	  CLK_5M          : out    std_logic;
	  CLK_20M          : out    std_logic;
	  CLK_50M          : out    std_logic;
	  CLK_100M          : out    std_logic
	 );
	end component;


	COMPONENT PISO
	generic (
			g_DataWidth : integer
			);
	PORT(
		i_CLK : IN std_logic;
		i_Data : IN std_logic_vector(15 downto 0);          
		o_CLK : OUT std_logic;
		o_Data : OUT std_logic;
		o_Latch : OUT std_logic
		);
	END COMPONENT;

	COMPONENT SIPO
	generic (
			g_DataWidth : integer
			);
	PORT(
		i_CLK : IN std_logic;
		i_Data : IN std_logic;          
		o_Data : OUT std_logic_vector(23 downto 0);
		o_CLK : OUT std_logic;
		o_Latch : OUT std_logic
		);
	END COMPONENT;	
--	
--	COMPONENT ROPUFMain
--	GENERIC(delay_clk : integer ; RO_sel : integer;
--			  sel_width_ar : integer; Sel_Size_p  : integer);
--	PORT(
--		clock : IN std_logic;
--		w : IN std_logic;
--		reset : IN std_logic;
--		selA : IN std_logic_vector(7 downto 0);
--		selB : IN std_logic_vector(7 downto 0);          
--		res_ar : OUT std_logic
--		);
--	END COMPONENT;
	
--ATTRIBUTE LOC:STRING;
--attribute loc of Inst_RO: label is "X10Y2";
	signal s_CLK_5M : std_logic := '0';
	signal s_LEDs   :std_logic_vector(15 downto 0);
	signal s_DIP    :std_logic_vector(15 downto 0);
	signal s_q,s_q2 ,s_pul     :std_logic;
signal decout : std_logic_vector(255 downto 0);
signal RO_out : std_logic_vector(255 downto 0);	
----------------------------------------------------------------------	
begin
-----------------------------
o_MMC_SCK	<= 'Z';
--i_MMC_DO
o_MMC_DI	<= 'Z';
o_MMC_CS	<= 'Z';

o_VGA_blue0	 <= 'Z';
o_VGA_blue1	 <= 'Z';
o_VGA_green0 <= 'Z';
o_VGA_green1 <= 'Z';
o_VGA_red0   <= 'Z';
o_VGA_red1   <= 'Z';
o_VGA_vsync  <= 'Z';
o_VGA_hsync  <= 'Z';

o_Eth_RST		<= 'Z';
-- i_Eth_INT
o_Eth_CS		<= 'Z';
o_Eth_RD	    <= 'Z';
o_Eth_WR	    <= 'Z';
o_USB_SLOE	    <= 'Z';
io_USB_IFCLK	<= 'Z';
o_USB_SLRD	    <= 'Z';
o_USB_SLWR	    <= 'Z';
io_Data	        <= (others => 'Z');
io_MuxEthUSB	<= (others => 'Z');

o_TXD1 <= 'Z';
o_TXD2 <= 'Z';
--i_RXD1
--i_RXD2

o_SEGData  <= 'Z';
o_SEGLatch <= 'Z';

o_LCDData  <= 'Z';
o_LCDLatch <= 'Z';




	Inst_countTest: countTest PORT MAP(
		clk =>s_CLK_5M ,
		pul =>s_pul 
	);

-------------------------------------
myDCM : DCM1
  port map
   (-- Clock in ports
    CLK_IN1 => i_CLK,
    -- Clock out ports
    CLK_5M => s_CLK_5M,
    CLK_20M => open,
    CLK_50M => open,
    CLK_100M => open
	);
------------------------------------
o_PSCLK <= 	not s_CLK_5M;
	
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
Inst_PISO_LED:
		PISO generic map (g_DataWidth => 16)
		PORT MAP(
		i_CLK  => s_CLK_5M,
		i_Data => s_LEDs,
		o_CLK  => open,
		o_Data => o_LEDData,
		o_Latch => o_LEDLatch
	);
	
			
Inst_counterNew: counterNew 
	PORT MAP(
		Clk =>s_pul ,
		Q =>s_q2 
	);
			
		
-------------------------------------
s_LEDs(0)<=s_q2;
s_LEDs(1)<=s_DIP(9);
s_LEDs(15 downto 2) <= "00000000000000";
-----------------------------------------------------------------------------------

end Behavioral;

