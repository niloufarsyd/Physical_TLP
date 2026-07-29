--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:23:05 01/17/2010
-- Design Name:   
-- Module Name:   E:/3s400/AZ_Project/AVA6STest/TB_PISO.vhd
-- Project Name:  AVA6STest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PISO
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
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_PISO IS
END TB_PISO;
 
ARCHITECTURE behavior OF TB_PISO IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PISO
    PORT(
         i_CLK : IN  std_logic;
         i_Data : IN  std_logic_vector(15 downto 0);
         o_CLK : OUT  std_logic;
         o_Data : OUT  std_logic;
         o_Latch : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_CLK : std_logic := '0';
   signal i_Data : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal o_CLK : std_logic;
   signal o_Data : std_logic;
   signal o_Latch : std_logic;

   -- Clock period definitions
   constant i_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PISO PORT MAP (
          i_CLK => i_CLK,
          i_Data => i_Data,
          o_CLK => o_CLK,
          o_Data => o_Data,
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
 
   process
   begin
		
		i_Data <= x"5555";
		loop
		i_Data <= x"5555";
		wait for 500 ns;
		--i_Data <= i_Data + 10;
		i_Data <= x"AAAA";
		wait for 500 ns;
		end loop;
		
   end process;
 
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for i_CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
