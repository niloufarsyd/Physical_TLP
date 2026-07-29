----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:59:12 03/30/2020 
-- Design Name: 
-- Module Name:    my_compare - Behavioral 
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-------------------------------------------
entity my_COMPARE is
port(
	A, B : in std_logic_vector(31 downto 0);
	diff: out std_logic;
	GTh : out std_logic
	);
end my_COMPARE;
-------------------------------------------
architecture arch_comp of my_COMPARE is

signal temp:unsigned(31 downto 0);

begin
	GTh <= '1' when ( A > B ) else '0';
	temp<=(unsigned(A(31 downto 0) ) - unsigned(B(31 downto 0) )  );
	diff <= '1' when ( temp > 1000 ) else '0';
end arch_comp;
