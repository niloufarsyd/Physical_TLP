----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/25/2024 11:30:39 AM
-- Design Name: 
-- Module Name: compare_solutions - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity compare_solutions is
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
end compare_solutions;

architecture Behavioral of compare_solutions is
signal counter3        : integer := 0;
signal equal_flag_temp : STD_LOGIC:= '0';
signal vec1,vec2 : std_logic_vector(lambda-1 downto 0):= (others => '0');
signal vec1_flag,vec2_flag : std_logic_vector(L-1 downto 0):= (others => '0');
type state_type3 is (reset3, idle, computeVec,checkV,done3);
signal current_state3, next_state3 : state_type3 := idle;
    
begin

P5: process(clk, reset)
    begin
        if(reset='1') then
            current_state3 <= reset3;          
        elsif(clk'event and clk='1') then
            current_state3 <= next_state3;
        end if;
    end process;
    
P7:process(clk, reset)
    begin
        if reset = '1' then
            counter3 <=0;
            ready_flag<='0';
            equal_flag_temp<='0';
        elsif rising_edge(clk) then
            case current_state3 is
                when reset3 =>
                    counter3<=0;
                    ready_flag<='0';
                    equal_flag_temp<='0';
                when idle =>
                    vec1<= s1(lambda*(counter3+1)-1 downto lambda*counter3);
                    vec2<= s2(lambda*(counter3+1)-1 downto lambda*counter3);
                when computeVec =>
                    if vec1 = vec2 then
                        vec1_flag(counter3) <= '1';  -- Set flag high if equal
                        vec2_flag(counter3) <= '1';
                    else
                        vec1_flag(counter3) <= '0';  -- Set flag low if not equal
                        vec2_flag(counter3) <= '1';
                    end if;
                    
                when checkV =>
                    if counter3<L-1 then
                        counter3<= counter3+1;
                    elsif vec1_flag=vec2_flag then
                        equal_flag_temp<='1';
                    else
                        equal_flag_temp<='0';
                    end if;
                when done3 =>
                    ready_flag<='1';
            end case;
        
        end if;
end process;

P8: process(current_state3, reset, counter3, ready)
    begin
            case current_state3 is
                when reset3 =>
                    if reset='1' then
                        next_state3<=reset3;
                    elsif ready='1' then
                        next_state3<=idle;
                    else
                        next_state3<=reset3;
                    end if;
                when idle =>
                    next_state3<=computeVec;
                when computeVec =>
                    next_state3<=checkV;
                when checkV =>
                    if counter3<L-1 then
                        next_state3<=idle;
                    else
                        next_state3<=done3;
                    end if;
                when done3 =>
                    next_state3<=done3;
            end case;
            
    end process;
equal_flag<=equal_flag_temp;
end Behavioral;
