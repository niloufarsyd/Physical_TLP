----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2024 03:24:08 PM
-- Design Name: 
-- Module Name: Top_Gen_Sol - Behavioral
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
use work.my_constants.all;  -- Import the package
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

--The top entity including the 'Gen_Sol' and the 'clk_wiz_o' and the comparison entity:

entity Top_Gen_Sol_new is
generic (
        L : integer := 1;  -- Number of vectors --- WAS 16
        MAX_N :integer := 300;
        lambda : integer := 256  -- Default value or specify as needed
    );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           reset_clk :in STD_LOGIC;
           start_gen : in STD_LOGIC;
           start_sol : in STD_LOGIC;
           N : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
--           t  : in STD_LOGIC_VECTOR (31 downto 0);
--           tc : in STD_LOGIC_VECTOR (31 downto 0);
--           e  : in STD_LOGIC_VECTOR (31 downto 0);
--           h  : in STD_LOGIC_VECTOR (7 downto 0);
           sol_time_counter : out STD_LOGIC_VECTOR(31 downto 0);
           gen_done : out STD_LOGIC;
           sol_done : out STD_LOGIC;
           comparison_done : out STD_LOGIC;
           comparison_result : out STD_LOGIC);
end Top_Gen_Sol_new;

architecture Behavioral of Top_Gen_Sol_new is

    signal lib_b :bram_type;
    attribute ram_style : string;
    attribute ram_style of lib_b : signal is "block";
    signal sol_time_counter_temp: std_logic_vector( 31 downto 0);   
    signal s_solution_temp , s_solved_temp: std_logic_vector((L*lambda)-1 downto 0):= (others => '0');
    signal s        : std_logic_vector((L*lambda)-1 downto 0):= (others => '1');
    signal c0             :  STD_LOGIC_VECTOR (lambda-1 downto 0);
    --signal N,B              :  STD_LOGIC_VECTOR (7 downto 0);
    signal ready_gen    :STD_LOGIC:='0';
    signal sol_done_temp    :STD_LOGIC:='0';
    signal Helper_index:  integer:=0;
    signal lib :  STD_LOGIC_VECTOR ((MAX_N*lambda)-1 downto 0);    
    signal clk_out : STD_LOGIC;
    signal clk_locked :STD_LOGIC;

component clk_wiz_0 is
    port (
        clk_in1 : in STD_LOGIC;
        clk_out1 : out STD_LOGIC;
        clk_out2 : out STD_LOGIC;
        reset : in STD_LOGIC
        );
end component;

component Gen_Sol_new is

    Port ( start_gen : in STD_LOGIC;
           start_sol : in STD_LOGIC;
           clk   : in STD_LOGIC;
           reset : in STD_LOGIC;
           N : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
--           t : in STD_LOGIC_VECTOR (31 downto 0);
--           --s : in STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0);
--           e : in STD_LOGIC_VECTOR(31 downto 0);  -- Example bit width
--           tc: in STD_LOGIC_VECTOR(31 downto 0);
--           h : in STD_LOGIC_VECTOR (7 downto 0);
           sol_time_counter : out STD_LOGIC_VECTOR(31 downto 0);
           s_solution : out STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0);
           s_solved : out STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0);
           gen_done : out STD_LOGIC;
           sol_done : out STD_LOGIC);
end component;

component compare_solutions is
generic (
        L : integer := 1;  -- Number of vectors --- WAS 16
        lambda : integer := 256  -- Default value or specify as needed
    );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           ready : in STD_LOGIC;
           s1 : in STD_LOGIC_VECTOR (L*lambda-1 downto 0);
           s2 : in STD_LOGIC_VECTOR (L*lambda-1 downto 0);
           ready_flag : out STD_LOGIC;
           equal_flag : out STD_LOGIC);
end component;


begin
-- Instantiate the Clocking Wizard
    clk_inst : clk_wiz_0
        port map (           
            clk_out1 => clk_out,  -- Output clock to be used by puz_gen
            clk_out2 => open,
            reset => reset_clk,  -- Reset signal for the Clocking Wizard
            clk_in1 => clk
        );

inst_gen_sol: Gen_Sol_new
        port map (
            start_gen => start_gen,
            start_sol => start_sol,
            clk => clk_out,
            reset => reset,
            N => N,
            B => B,
--            t => t,
--            tc => tc,
--            h =>h,
--            e => e,
            sol_time_counter=> sol_time_counter_temp ,
            s_solution => s_solution_temp,
            s_solved => s_solved_temp,
            gen_done => gen_done,
            sol_done => sol_done_temp
        );
sol_done<=sol_done_temp;
sol_time_counter <= sol_time_counter_temp;        
inst_comp: compare_solutions
generic map(
        L => 1,  -- Number of vectors --- WAS 16
        lambda => 256  -- Default value or specify as needed
    )
    Port map( clk =>clk_out ,
           reset =>reset,
           ready =>sol_done_temp,
           s1 =>s_solution_temp,
           s2 =>s_solved_temp,
           ready_flag =>comparison_done,
           equal_flag =>comparison_result
           );
end Behavioral;
