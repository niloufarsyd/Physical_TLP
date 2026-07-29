----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/24/2024 11:06:37 PM
-- Design Name: 
-- Module Name: Puz_Gen_Sol - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Puz_Gen_Sol is
--generic (
--        L : integer := DEFAULT_L;  -- Number of vectors --- WAS 16
--        MAX_N :integer := MAX_N;
--        --m : integer := 256;   -- Number of bits in each vector
--        lambda : integer := LAMBDA  -- Default value or specify as needed
--    );
generic (
        L : integer := 1;  -- Number of vectors --- WAS 16
        MAX_N :integer := 300;
        --m : integer := 256;   -- Number of bits in each vector
        lambda : integer := 256  -- Default value or specify as needed
    );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           --s: in std_logic_vector((L*lambda)-1 downto 0):= (others => '0');
           t  : in STD_LOGIC_VECTOR (31 downto 0);
           tc : in STD_LOGIC_VECTOR (31 downto 0);
           e  : in STD_LOGIC_VECTOR (31 downto 0);
           h  : in STD_LOGIC_VECTOR (7 downto 0);
           comparison_done : out STD_LOGIC;
           solve_correctness :out STD_LOGIC;
           sol_done : out STD_LOGIC);
end Puz_Gen_Sol;

architecture Behavioral of Puz_Gen_Sol is    
    --type bram_type is array (0 to MAX_N-1) of std_logic_vector(lambda-1 downto 0);
    --signal lib_bram : bram_type := (others => (others => '0'));
    signal lib_b :bram_type;
    attribute ram_style : string;
    attribute ram_style of lib_b : signal is "block";
        
    signal Z , s_solved          : std_logic_vector((L*lambda)-1 downto 0):= (others => '0');
    signal s        : std_logic_vector((L*lambda)-1 downto 0):= (others => '1');
    signal c0             :  STD_LOGIC_VECTOR (lambda-1 downto 0);
    signal N,B              :  STD_LOGIC_VECTOR (7 downto 0);
--    signal t  :  STD_LOGIC_VECTOR (31 downto 0);
--    signal tc :  STD_LOGIC_VECTOR (31 downto 0);
--    signal e  :  STD_LOGIC_VECTOR (31 downto 0);
    signal ready_gen    :STD_LOGIC:='0';
    signal sol_done_temp    :STD_LOGIC:='0';
    signal Helper_index:  integer:=0;
    signal lib :  STD_LOGIC_VECTOR ((MAX_N*lambda)-1 downto 0);
    
    signal clk_out : STD_LOGIC;
    signal clk_locked :STD_LOGIC;
    -- Instantiate the Clocking Wizard here
component clk_wiz_0 is
    port (
        clk_in1 : in STD_LOGIC;
        clk_out1 : out STD_LOGIC;
        reset : in STD_LOGIC
        );
end component;
           
component puz_gen is
    generic (
        L : integer := 1;  -- Number of vectors --- WAS 16
        MAX_N :integer := 300;
        --m : integer := 256;   -- Number of bits in each vector
        lambda : integer := 256  -- Default value or specify as needed
    );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           t : in STD_LOGIC_VECTOR (31 downto 0);
           s : in STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0);
           start    : in  std_logic;
           e  : in  std_logic_vector(31 downto 0);  -- Example bit width
           tc  : in  std_logic_vector(31 downto 0);
           h : in STD_LOGIC_VECTOR (7 downto 0);
           c0_seed : out STD_LOGIC_VECTOR (lambda-1 downto 0);
           N : out STD_LOGIC_VECTOR (7 downto 0);
           B : out STD_LOGIC_VECTOR (7 downto 0);
           Helper_index: out integer;
           Z : out STD_LOGIC_VECTOR (L*lambda-1 downto 0);
           lib : out bram_type;
           ready_output    : out std_logic
           );
end component;


component puz_sol is
generic (
        L : integer := 1;  -- Number of vectors --- WAS 16
        MAX_N :integer := 300;
        lambda : integer := 256  -- Default value or specify as needed
    );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;         
           c0_seed : in STD_LOGIC_VECTOR (lambda-1 downto 0);
           Z : in STD_LOGIC_VECTOR (L*lambda-1 downto 0);
           lib : in bram_type;
           Helper_index : in integer;
           N : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           ready_gen : in STD_LOGIC;
           ready_output :out STD_LOGIC;
           S  : out STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0)                
           );
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
            --clk_out2 => open,
            reset => reset,  -- Reset signal for the Clocking Wizard
            clk_in1 => clk
        );

inst_puz: puz_gen 
    generic map(
        L => 1,  -- Number of vectors --- WAS 16
        MAX_N=> 300,
        lambda =>256  -- Default value or specify as needed
    )
    Port map ( clk => clk_out,
           reset => reset,
           t => t,
           s => s,
           start   => start,
           e  =>e,
           tc  => tc,
           h =>h,
           c0_seed => c0,
           N => N,
           B => B,
           Helper_index=>Helper_index,
           Z =>Z,
           lib =>lib_b,
           ready_output    =>ready_gen
           );

int_sol:  puz_sol
generic map(
        L => 1,  -- Number of vectors --- WAS 16
        MAX_N => 300,
        lambda => 256  -- Default value or specify as needed
    )
    Port map ( clk => clk_out ,
           reset => reset,
           start => start,
           c0_seed => c0,
           Z => Z,
           lib => lib_b,
           Helper_index => Helper_index,
           N => N,
           B => B,
           ready_gen =>ready_gen ,
           ready_output => sol_done_temp,
           S  =>   s_solved                 
           );
sol_done<=sol_done_temp;
inst_comp: compare_solutions
generic map(
        L => 1,  -- Number of vectors --- WAS 16
        lambda => 256  -- Default value or specify as needed
    )
    Port map( clk =>clk_out ,
           reset =>reset,
           ready =>sol_done_temp,
           s1 =>s,
           s2 =>s_solved,
           ready_flag =>comparison_done,
           equal_flag =>solve_correctness
           );
end Behavioral;
