--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:22:57 05/28/2020
-- Design Name:   
-- Module Name:   F:/iot/puf/PUF/code/mine/ex26/ex24_baTaghyir/tb_counterasli.vhd
-- Project Name:  AVA6STest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: my_counter
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
 
ENTITY tb_counterasli IS
END tb_counterasli;
 
ARCHITECTURE behavior OF tb_counterasli IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_counter
    PORT(
         PULSE_IN : IN  std_logic;
         CE : IN  std_logic;
         CLR : IN  std_logic;
         Q : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal PULSE_IN : std_logic := '0';
   signal CE : std_logic := '0';
   signal CLR : std_logic := '0';

 	--Outputs
   signal Q : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
  -- constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_counter PORT MAP (
          PULSE_IN => PULSE_IN,
          CE => CE,
          CLR => CLR,
          Q => Q
        );

pulse_process :process
   begin
		PULSE_IN <= '0';
		wait for 10 ns;
		PULSE_IN <= '1';
		wait for 20 ns;
		
		PULSE_IN <= '0';
		wait for 15 ns;
		PULSE_IN <= '1';
		wait for 10 ns;
		
		PULSE_IN <= '0';
		wait for 10 ns;
		PULSE_IN <= '1';
		wait for 20 ns;
		
		PULSE_IN <= '0';
		wait for 20 ns;
		PULSE_IN <= '1';
		wait for 30 ns;
		
		PULSE_IN <= '0';
		wait for 15 ns;
		PULSE_IN <= '1';
		wait for 40 ns;
		
		PULSE_IN <= '0';
		wait for 5 ns;
		PULSE_IN <= '1';
		wait for 20 ns;
		
		wait for 10 ns;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		wait for 10 ns;
		CE <='1';
		CLR<='0';
		
      wait for 100 ns;	

      wait for 40 ns;

      -- insert stimulus here 
		CE <='0';
		CLR<='1';
		wait for 20 ns;
		CE <='1';
		CLR<='0';
      wait for 200 ns;
      wait;
   end process;


END;
