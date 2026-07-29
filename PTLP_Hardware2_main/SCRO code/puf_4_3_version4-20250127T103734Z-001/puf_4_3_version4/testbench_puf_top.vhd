--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:42:51 02/08/2021
-- Design Name:   
-- Module Name:   E:/new codes/SCRO_DCU_(4_3)/puf_4_3_version2/testbench_puf_top.vhd
-- Project Name:  AVA6STest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PUF_TOP
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
 
ENTITY testbench_puf_top IS
END testbench_puf_top;
 
ARCHITECTURE behavior OF testbench_puf_top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PUF_TOP
    PORT(
         i_CLK : IN  std_logic;
         i_RESET : IN  std_logic;
         i_DIPData : IN  std_logic;
         o_DIPLatch : OUT  std_logic;
         o_PSCLK : OUT  std_logic;
         DS_REG : OUT  std_logic_vector(6 downto 0);
         DS_EN : OUT  std_logic_vector(3 downto 0);
         DS_DP : OUT  std_logic;
         PUF_OUT1 : OUT  std_logic;
         PUF_OUT2 : OUT  std_logic;
         PUF_OUT3 : OUT  std_logic;
         PUF_OUT4 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_CLK : std_logic := '0';
   signal i_RESET : std_logic := '0';
   signal i_DIPData : std_logic := '0';

 	--Outputs
   signal o_DIPLatch : std_logic;
   signal o_PSCLK : std_logic;
   signal DS_REG : std_logic_vector(6 downto 0);
   signal DS_EN : std_logic_vector(3 downto 0);
   signal DS_DP : std_logic;
   signal PUF_OUT1 : std_logic;
   signal PUF_OUT2 : std_logic;
   signal PUF_OUT3 : std_logic;
   signal PUF_OUT4 : std_logic;

   -- Clock period definitions
   constant i_CLK_period : time := 20 ns;
   constant o_PSCLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PUF_TOP PORT MAP (
          i_CLK => i_CLK,
          i_RESET => i_RESET,
          i_DIPData => i_DIPData,
          o_DIPLatch => o_DIPLatch,
          o_PSCLK => o_PSCLK,
          DS_REG => DS_REG,
          DS_EN => DS_EN,
          DS_DP => DS_DP,
          PUF_OUT1 => PUF_OUT1,
          PUF_OUT2 => PUF_OUT2,
          PUF_OUT3 => PUF_OUT3,
          PUF_OUT4 => PUF_OUT4
        );

   -- Clock process definitions
   i_CLK_process :process
   begin
		i_CLK <= '0';
		wait for i_CLK_period/2;
		i_CLK <= '1';
		wait for i_CLK_period/2;
   end process;
-- 
--   o_PSCLK_process :process
--   begin
--		o_PSCLK <= '0';
--		wait for o_PSCLK_period/2;
--		o_PSCLK <= '1';
--		wait for o_PSCLK_period/2;
--   end process;
 

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
