--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:55:54 11/14/2012
-- Design Name:   
-- Module Name:   D:/ElectronicEngin/project2010/RandD/FPGA Board/Spartan6 Board/AVA6STest2/TB_SIPO.vhd
-- Project Name:  AVA6STest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SIPO
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_SIPO IS
END TB_SIPO;
 
ARCHITECTURE behavior OF TB_SIPO IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SIPO
    PORT(
         i_CLK : IN  std_logic;
         o_Data : OUT  std_logic_vector(15 downto 0);
         i_Data : IN  std_logic;
         o_CLK : OUT  std_logic;
         o_Latch : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_CLK : std_logic := '0';
   signal i_Data : std_logic := '0';

 	--Outputs
   signal o_Data : std_logic_vector(15 downto 0);
   signal o_CLK : std_logic;
   signal o_Latch : std_logic;

   -- Clock period definitions
   constant i_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SIPO PORT MAP (
          i_CLK => i_CLK,
          o_Data => o_Data,
          i_Data => i_Data,
          o_CLK => o_CLK,
          o_Latch => o_Latch
        );

   -- Clock process definitions
   i_CLK_process :process
   begin
		i_CLK <= '0';
		wait for i_CLK_period/2;
		i_CLK <= '1';
		wait for i_CLK_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      --wait for 100 ns;	
		i_Data <= '0';
      wait for i_CLK_period*6;
		i_Data <= '1';
      wait for i_CLK_period*10;

      -- insert stimulus here 

      --wait;
   end process;

END;
