----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2024 03:18:00 PM
-- Design Name: 
-- Module Name: tb_GenSol4 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;
use work.my_constants.all;


entity tb_GenSol5 is
--  Port ( );
end tb_GenSol5;

architecture Behavioral of tb_GenSol5 is

component Top_Gen_Sol is

    Port ( start_gen : in STD_LOGIC;
           start_sol : in STD_LOGIC;
           clk   : in STD_LOGIC;
           reset : in STD_LOGIC;
           t : in STD_LOGIC_VECTOR (31 downto 0);
           e : in STD_LOGIC_VECTOR(31 downto 0);  -- Example bit width
           tc: in STD_LOGIC_VECTOR(31 downto 0);
           h : in STD_LOGIC_VECTOR (7 downto 0);
           gen_done : out STD_LOGIC;
           sol_done : out STD_LOGIC;
           comparison_done : out STD_LOGIC;
           comparison_result : out STD_LOGIC);
end component;


    constant CLK_PERIOD : time := 20 ns;
    signal clk_tb : STD_LOGIC := '0';
    signal reset_tb : STD_LOGIC := '1';
    signal start_gen_tb : STD_LOGIC := '0';
    signal start_sol_tb : STD_LOGIC := '0';
    signal t_tb  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tc_tb : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal e_tb  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal h_tb  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal comparison_done_tb : std_logic:='0';
    signal comparison_result_tb : std_logic:='0';
    signal gen_done_tb : std_logic:='0';
    signal sol_done_tb : std_logic:='0';

begin
    uut: Top_Gen_Sol
        port map (
            start_gen => start_gen_tb,
            start_sol => start_sol_tb,
            clk => clk_tb,
            reset => reset_tb,
            t => t_tb,
            tc => tc_tb,
            h =>h_tb,
            e => e_tb,
            comparison_done => comparison_done_tb,
            comparison_result => comparison_result_tb,
            gen_done => gen_done_tb,
            sol_done => sol_done_tb
        );

    -- Clock process
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Test stimulus process
    stimulus_process : process
    begin
        -- Initialize Inputs
        reset_tb <= '1';
        start_gen_tb <= '0';
        start_sol_tb <= '0';
        t_tb <= x"00000005";  -- Example values
        tc_tb <= x"00000002";  -- Example values
        e_tb <= x"00000002";  -- Example values
        h_tb  <= x"02"; 
        wait for 100 ns;

        -- Release reset and start the process
        reset_tb <= '0';
        wait for 1000 ns;

        -- Start the puzzle generation and solution
        start_gen_tb <= '1';
        wait for 200 ns;
        start_gen_tb <= '0';
        wait for 2200 ns;
        start_sol_tb <= '1';
        wait for 200 ns;
        start_sol_tb <= '0';
        
        
        wait for 300000 ns;
        start_sol_tb <= '1';
        wait for 20 ns;
        start_sol_tb <= '0';
        wait for 100000 ns;
        start_sol_tb <= '1';
        wait for 20 ns;
        start_sol_tb <= '0';
        -- Wait for the solution to complete
        wait until sol_done_tb = '1';
        
        -- Wait for comparison to complete
        wait until comparison_done_tb = '1';

        -- Finish the simulation
        wait for 100 ns;
        assert false report "Simulation finished" severity note;
        wait;
    end process;

end Behavioral;
