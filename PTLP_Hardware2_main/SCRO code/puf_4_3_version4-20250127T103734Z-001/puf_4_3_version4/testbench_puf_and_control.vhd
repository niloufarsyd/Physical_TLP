--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:48:46 02/08/2021
-- Design Name:   
-- Module Name:   E:/new codes/SCRO_DCU_(4_3)/puf_4_3_version2/testbench_puf_and_control.vhd
-- Project Name:  AVA6STest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PUF_and_CONTROL
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
 
ENTITY testbench_puf_and_control IS
END testbench_puf_and_control;
 
ARCHITECTURE behavior OF testbench_puf_and_control IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PUF_and_CONTROL
    PORT(
         CLK_PUF : IN  std_logic;
         CLK_CONTROLLER : IN  std_logic;
         w : IN  std_logic;
         Reset : IN  std_logic;
         selA : IN  std_logic_vector(5 downto 0);
         selb : IN  std_logic_vector(5 downto 0);
         en_of_controller : OUT  std_logic;
         ENABLE_SIGN : OUT  std_logic;
         DISABLE_SIGN : OUT  std_logic;
         PUF : OUT  std_logic;
         PUF_OUT64 : OUT  std_logic_vector(63 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_PUF : std_logic := '0';
   signal CLK_CONTROLLER : std_logic := '0';
   signal w : std_logic := '0';
   signal Reset : std_logic := '0';
   signal selA : std_logic_vector(5 downto 0) := (others => '0');
   signal selb : std_logic_vector(5 downto 0) := (others => '0');

 	--Outputs
   signal en_of_controller : std_logic;
   signal ENABLE_SIGN : std_logic;
   signal DISABLE_SIGN : std_logic;
   signal PUF : std_logic;
   signal PUF_OUT64 : std_logic_vector(63 downto 0);

   -- Clock period definitions
   constant CLK_PUF_period : time := 100 ns;
   constant CLK_CONTROLLER_period : time := 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PUF_and_CONTROL PORT MAP (
          CLK_PUF => CLK_PUF,
          CLK_CONTROLLER => CLK_CONTROLLER,
          w => w,
          Reset => Reset,
          selA => selA,
          selb => selb,
          en_of_controller => en_of_controller,
          ENABLE_SIGN => ENABLE_SIGN,
          DISABLE_SIGN => DISABLE_SIGN,
          PUF => PUF,
          PUF_OUT64 => PUF_OUT64
        );

   -- Clock process definitions
   CLK_PUF_process :process
   begin
		CLK_PUF <= '0';
		wait for CLK_PUF_period/2;
		CLK_PUF <= '1';
		wait for CLK_PUF_period/2;
   end process;
 
   CLK_CONTROLLER_process :process
   begin
		CLK_CONTROLLER <= '0';
		wait for CLK_CONTROLLER_period/2;
		CLK_CONTROLLER <= '1';
		wait for CLK_CONTROLLER_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
         w     <= '0';
         Reset <= '1';
         selA  <= "000100";
         selb  <= "011101";
      wait for 100 ns;	
         w     <= '1';
         Reset <= '0';
         selA  <= "000100";
         selb  <= "011101";
      wait for CLK_PUF_period*10000000;
         w     <= '0';
         Reset <= '1';
         selA  <= "000100";
         selb  <= "011101";
      wait for CLK_PUF_period*10;
      -- insert stimulus here 
         w     <= '1';
         Reset <= '0';
         selA  <= "000111";
         selb  <= "111100";
      wait for CLK_PUF_period*10000000;
		   w     <= '0';
         Reset <= '1';
         selA  <= "000111";
         selb  <= "111100";
      wait for CLK_PUF_period*10;
		   w     <= '1';
         Reset <= '0';
         selA  <= "000000";
         selb  <= "111111";
      wait for CLK_PUF_period*10000000;
				   w     <= '0';
         Reset <= '1';
         selA  <= "000111";
         selb  <= "111100";
      wait;
   end process;

END;
