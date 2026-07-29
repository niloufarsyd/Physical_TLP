
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
----Decoder is used to activate specific RO for PUF
entity Decoder_D is
	port( en      : in std_logic;
			inA, inB: in  std_logic_vector(5 downto 0);
			output  : out std_logic_vector(63 downto 0));
end Decoder_D;

architecture block_diagram of Decoder_D is
begin
	process(inA, inB, en)
	begin
		---Set output bits to 0 to deavtivate all RO
		output <= (others => '0'); -- default
		---activate RO corrspoending to inA
		output(to_integer(unsigned(inA))) <= en;
		---activate RO corresponding to inB
		output(to_integer(unsigned(inB))) <= en;
	end process;
end block_diagram;