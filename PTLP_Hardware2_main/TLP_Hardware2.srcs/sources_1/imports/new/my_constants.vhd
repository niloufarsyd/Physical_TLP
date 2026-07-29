----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/26/2024 03:16:45 PM
-- Design Name: 
-- Module Name: my_constants - Behavioral
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

package my_constants is
    -- Define constants
    constant DEFAULT_L : integer := 1;
    constant MAX_N : integer := 300;
    constant LAMBDA : integer := 256;

    -- Define a type for BRAM storage
    type bram_type is array (0 to MAX_N-1) of std_logic_vector(LAMBDA-1 downto 0);
end package my_constants;


