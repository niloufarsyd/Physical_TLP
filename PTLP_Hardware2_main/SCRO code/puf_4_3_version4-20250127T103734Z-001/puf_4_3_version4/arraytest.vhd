----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:40:31 04/03/2020 
-- Design Name: 
-- Module Name:    arraytest - Behavioral 
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

entity arraytest is
	GENERIC (Sel_Size_p : INTEGER :=8; 
				--Sel_Size_p : INTEGER :=5;
				row : INTEGER :=1);
	port(
			en : in std_logic;
			--RO_out :inout std_logic_vector( (2**Sel_size_p)-1 downto 0);
			selA : in STD_LOGIC_VECTOR (Sel_Size_p-1 downto 0);
			selB : in STD_LOGIC_VECTOR (Sel_Size_p-1 downto 0);

			res : out STD_LOGIC	
		  );
end arraytest;

architecture Behavioral of arraytest is

component mux_gen IS
	GENERIC (Sel_Size : INTEGER :=8);
				--Sel_Size : INTEGER :=5);
	PORT (Sel : IN STD_LOGIC_Vector(Sel_Size-1 downto 0);
	dati : IN STD_LOGIC_Vector(2**Sel_Size-1 downto 0);
	dato : OUT STD_LOGIC
	);
END component;

component Decoder is
	generic (Sel_Width : integer := 8);
	port( en: in std_logic;
	inA, inB: in std_logic_vector(Sel_Width-1 downto 0);
	output: out std_logic_vector(2**Sel_Width-1 downto 0));
end component;

component RO_Array is
--	generic (RO_Width : integer := 64;
				--RO_Width : integer := 32;
				--ro_row: integer :=1 );
	port( En: in std_logic_vector(256-1 downto 0);
	Os: inout std_logic_vector(256-1 downto 0));
end component;

signal RO_out: std_logic_vector(2**Sel_size_p-1 downto 0);
signal decout : std_logic_vector(2**Sel_size_p-1 downto 0);
begin

ro_Ar :RO_Array 
--GENERIC MAP(RO_Width => 64, ro_row=>row)
	PORT MAP(en=>decout,
				os=>RO_out);
				
mux_a :mux_gen GENERIC MAP(sel_size => Sel_size_p)
	PORT MAP(Sel=>selA,
				dati=>RO_out,
				dato=>res);
				
dec :decoder GENERIC MAP(Sel_Width => Sel_size_p)
	PORT MAP(en=>en,
				inA=>selA,
				inB=>selB,
				output=>decout);

end Behavioral;

