library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity demux1to64 is
    Port (
        data_in  : in  STD_LOGIC;                    -- Single input
        sel      : in  STD_LOGIC_VECTOR(5 downto 0);  -- 6-bit selection line
        data_out : out STD_LOGIC_VECTOR(63 downto 0)  -- 64 outputs
    );
end demux1to64;

architecture Behavioral of demux1to64 is
begin
    process(data_in, sel)
    begin
        -- Default: all outputs are '0'
        data_out <= (others => '0');

        -- Only one output based on sel becomes data_in
        case sel is
            when "000000" => data_out(0) <= data_in;
            when "000001" => data_out(1) <= data_in;
            when "000010" => data_out(2) <= data_in;
            when "000011" => data_out(3) <= data_in;
            when "000100" => data_out(4) <= data_in;
            when "000101" => data_out(5) <= data_in;
            when "000110" => data_out(6) <= data_in;
            when "000111" => data_out(7) <= data_in;
            when "001000" => data_out(8) <= data_in;
            when "001001" => data_out(9) <= data_in;
            when "001010" => data_out(10) <= data_in;
            when "001011" => data_out(11) <= data_in;
            when "001100" => data_out(12) <= data_in;
            when "001101" => data_out(13) <= data_in;
            when "001110" => data_out(14) <= data_in;
            when "001111" => data_out(15) <= data_in;
            when "010000" => data_out(16) <= data_in;
            when "010001" => data_out(17) <= data_in;
            when "010010" => data_out(18) <= data_in;
            when "010011" => data_out(19) <= data_in;
            when "010100" => data_out(20) <= data_in;
            when "010101" => data_out(21) <= data_in;
            when "010110" => data_out(22) <= data_in;
            when "010111" => data_out(23) <= data_in;
            when "011000" => data_out(24) <= data_in;
            when "011001" => data_out(25) <= data_in;
            when "011010" => data_out(26) <= data_in;
            when "011011" => data_out(27) <= data_in;
            when "011100" => data_out(28) <= data_in;
            when "011101" => data_out(29) <= data_in;
            when "011110" => data_out(30) <= data_in;
            when "011111" => data_out(31) <= data_in;
            when "100000" => data_out(32) <= data_in;
            when "100001" => data_out(33) <= data_in;
            when "100010" => data_out(34) <= data_in;
            when "100011" => data_out(35) <= data_in;
            when "100100" => data_out(36) <= data_in;
            when "100101" => data_out(37) <= data_in;
            when "100110" => data_out(38) <= data_in;
            when "100111" => data_out(39) <= data_in;
            when "101000" => data_out(40) <= data_in;
            when "101001" => data_out(41) <= data_in;
            when "101010" => data_out(42) <= data_in;
            when "101011" => data_out(43) <= data_in;
            when "101100" => data_out(44) <= data_in;
            when "101101" => data_out(45) <= data_in;
            when "101110" => data_out(46) <= data_in;
            when "101111" => data_out(47) <= data_in;
            when "110000" => data_out(48) <= data_in;
            when "110001" => data_out(49) <= data_in;
            when "110010" => data_out(50) <= data_in;
            when "110011" => data_out(51) <= data_in;
            when "110100" => data_out(52) <= data_in;
            when "110101" => data_out(53) <= data_in;
            when "110110" => data_out(54) <= data_in;
            when "110111" => data_out(55) <= data_in;
            when "111000" => data_out(56) <= data_in;
            when "111001" => data_out(57) <= data_in;
            when "111010" => data_out(58) <= data_in;
            when "111011" => data_out(59) <= data_in;
            when "111100" => data_out(60) <= data_in;
            when "111101" => data_out(61) <= data_in;
            when "111110" => data_out(62) <= data_in;
            when "111111" => data_out(63) <= data_in;
            when others => data_out <= (others => '0');
        end case;
    end process;
end Behavioral;
