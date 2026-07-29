----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:16:20 01/26/2020 
-- Design Name: 
-- Module Name:    puf_bit - Behavioral 
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

------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
----Main Code for Puf Bit-----------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------

---Sel_size_p:The width of the selector for mux and decoder
---row:used by upper level entity to assign this PUF a row number
-------to allow for easier attribution of location to each RO on FPGA
---en: Enables the RO
---selA: Select an RO
---selB: Select another RO for comparison to the first
---aclr: Clears counter that counts oscillations
---cnt_en: enables the counter.
---res: The result of the comparisons between 2 counters. 1 if RO A> RO B

entity puf_bit is
	GENERIC (Sel_Size_p : INTEGER :=8; 
				row : INTEGER :=1);
	Port ( 
	clk: in std_logic;
	en : in STD_LOGIC;
	selA : in STD_LOGIC_VECTOR (7 downto 0);
	selB : in STD_LOGIC_VECTOR (7 downto 0);
	aclr : in STD_LOGIC;
	cnt_en : in STD_LOGIC;
	res : out STD_LOGIC);
end puf_bit;
-----------------------------------------------------------
-----------------------------------------------------------

architecture Behavioral of puf_bit is


COMPONENT my_counter
PORT(
	clk : in std_logic;
	PULSE_IN : IN std_logic;
	CE : IN std_logic;
	CLR : IN std_logic; 		
	Q : OUT std_logic_vector(31 downto 0)
	);
END COMPONENT;	
----------------------------------------------------------
component mux_gen IS
	GENERIC (Sel_Size : INTEGER :=8);
	PORT (Sel : IN STD_LOGIC_Vector(Sel_Size-1 downto 0);
			dati : IN STD_LOGIC_Vector(2**Sel_Size-1 downto 0);
			dato : OUT STD_LOGIC
	);
END component;
-----------------------------------------------------------
component Decoder is
	generic (Sel_Width : integer := 8);
	port( en: in std_logic;
			inA, inB: in std_logic_vector(Sel_Width-1 downto 0);
			output: out std_logic_vector(2**Sel_Width-1 downto 0));
end component;
-----------------------------------------------------------
component RO_Array is
	port( En: in std_logic_vector(256-1 downto 0);
			Os: inout std_logic_vector(256-1 downto 0));
end component;
-----------------------------------------------------------
component my_COMPARE is
	port(
	A, B : in std_logic_vector(31 downto 0);
	GTh : out std_logic
	);
end component;
---------------
	signal s_CLK_5M,s_CLK_50M,s_CLK_8M : std_logic := '0';
	signal s_LEDs   :std_logic_vector(15 downto 0);
	signal s_DIP    :std_logic_vector(15 downto 0);
	signal s_puls1,s_puls2 :std_logic;
	signal cntA,cntB    :std_logic_vector(31 downto 0);
	signal decout : std_logic_vector(255 downto 0);
	signal RO_out : std_logic_vector(255 downto 0);	
---------------
--because of error :pack1195 in mapping new my counter with edge detection
attribute s : string;
attribute s of RO_out : signal is "yes";
-----------------------------------------------------------

begin
----decoder for enabling two of ROs that are selecting by multiplexers:
dec :decoder GENERIC MAP(Sel_Width => 8)
	PORT MAP(en=>en,
				inA=>selA,
				inB=>selB,
				output=>decout);
--------------------------------------------	
----array 256 of ROs:			
ro_Ar :RO_Array 
	PORT MAP(en=>decout,
				os=>RO_out);
--------------------------------------------	
----multiplexer A for selecting 1 RO between all 256 ones: 			
mux_a :mux_gen GENERIC MAP(sel_size => 8)
	PORT MAP(Sel=>selA,
				dati=>RO_out,
				dato=>s_puls1);
--------------------------------------------
---counter1 for computing the frequence of ring osillator that had selected by mux_a:
Inst_my_counter1: my_counter PORT MAP(
	clk => CLK,
	PULSE_IN =>s_puls1 ,
	CE =>cnt_en ,
	CLR =>aclr ,
	Q => cntA
	);
--------------------------------------------
----multiplexer B for selecting one another RO between all 256 ones: 	
mux_b :mux_gen GENERIC MAP(sel_size => 8)
	PORT MAP(Sel=>selB,
				dati=>RO_out,
				dato=>s_puls2);
--------------------------------------------
---counter2 for computing the frequence of ring osillator that had selected by mux_b:
Inst_my_counter2: my_counter PORT MAP(
	clk => CLK,
	PULSE_IN =>s_puls2 ,
	CE => cnt_en,
	CLR =>aclr,
	Q => cntB
	);
--------------------------------------------
----comparing the results of counter1 and counter2:
Inst_my_COMPARE :my_COMPARE PORT MAP(A=>cntA,
												 B=>cntB,
												 Gth=>res);
								
end Behavioral;
