--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:56:16 03/12/2020
-- Design Name:   
-- Module Name:   D:/darsi/iot/puf/PUF/code/mine/ex15_new_board/AVA6SV2_DIPLED/tb_RO.vhd
-- Project Name:  AVA6STest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RO
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
 
ENTITY tb_RO IS
END tb_RO;
 
ARCHITECTURE behavior OF tb_RO IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RO
    PORT(
         En : IN  std_logic;
         Os : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal En : std_logic := '0';

 	--Outputs
   signal Os : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
  -- constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RO PORT MAP (
          En => En,
          Os => Os
        );

   -- Clock process definitions
--   <clock>_process :process
--   begin
--		<clock> <= '0';
--		wait for <clock>_period/2;
--		<clock> <= '1';
--		wait for <clock>_period/2;
--   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 10 ns;	
en<='0';
     -- wait for <clock>_period*10;
      wait for 10 ns;	
en<='1';
      wait for 100 ns;
      -- insert stimulus here 

      wait;
   end process;

END;
