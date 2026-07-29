library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comparator is
  generic (
    WIDTH : integer := 64);
  port (
    val_a    : in  unsigned(WIDTH-1 downto 0);
    val_b    : in  unsigned(WIDTH-1 downto 0);
    result : out std_logic);
end entity comparator;

architecture rtl of comparator is
begin
  result <= '1' when ((val_a) > (val_b)) else '0';
end architecture rtl;