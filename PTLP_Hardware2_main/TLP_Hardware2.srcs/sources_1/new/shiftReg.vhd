library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shiftReg is
  generic (
    WIDTH : integer := 64
  );
  port (
    clk       : in  STD_LOGIC;
    clr_shift : in  STD_LOGIC;
    data_in   : in  STD_LOGIC;
    en        : in  STD_LOGIC;
    data_out  : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    done      : out STD_LOGIC
  );
end shiftReg;

architecture Behavioral of shiftReg is
  signal shift_reg : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := (others => '0');
  signal counter   : integer range 0 to WIDTH := 0;
  signal done_r    : std_logic := '0';
  attribute DONT_TOUCH : string;
  attribute DONT_TOUCH of done_r : signal is "TRUE";

begin
  process(clk)
  begin
    if rising_edge(clk) then
      if clr_shift = '1' then
        shift_reg <= (others => '0');
        counter   <= 0;
        done_r    <= '0';

      elsif en = '1' then
        shift_reg <= data_in & shift_reg(WIDTH-1 downto 1);

        if counter = WIDTH-1 then
          done_r  <= '1';    -- pulse
          counter <= 0;      -- re-arm for next bit-stream
        else
          done_r  <= '0';
          counter <= counter + 1;
        end if;

--      else
--        done_r <= '0';  -- keep done low when not shifting
      end if;
    end if;
  end process;

  data_out <= shift_reg;
  done     <= done_r;
end Behavioral;




--entity shiftReg is
-- generic (
--    WIDTH : integer := 64);
--    Port (
--        clk     : in  STD_LOGIC;
--        data_in : in  STD_LOGIC;
--        en      : in  STD_LOGIC;
--        data_out: out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
--    );
--end shiftReg;

--architecture Behavioral of shiftReg is
--    signal shift_reg : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := (others => '0');
--begin

--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if en = '1' then
--                shift_reg <= data_in & shift_reg(WIDTH-1 downto 1);
--            end if;
--        end if;
--    end process;

--    data_out <= shift_reg;

--end Behavioral;
