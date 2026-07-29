library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ro_counter is
  generic (
    COUNTER_WIDTH  : integer := 64;  -- width of oscillation counter
    RING_OSC_DEPTH : integer := 32   -- number of sys_clk cycles for measurement window
  );
  port (
    clk        : in  std_logic;  -- system clock
    rst        : in  std_logic;
    start      : in  std_logic;  -- begin counting
    ro_in      : in  std_logic;  -- raw ring oscillator signal
    count_out  : out unsigned(COUNTER_WIDTH-1 downto 0);
    done       : out std_logic   -- high when measurement is complete
  );
end entity;

architecture rtl of ro_counter is
  signal ro_sync1, ro_sync2 : std_logic := '0';
  signal ro_prev            : std_logic := '0';
  signal count_r            : unsigned(COUNTER_WIDTH-1 downto 0) := (others=>'0');
  signal window_cnt         : unsigned(31 downto 0) := (others=>'0');
  signal active             : std_logic := '0';
  signal done_r             : std_logic := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ro_sync1   <= '0';
        ro_sync2   <= '0';
        ro_prev    <= '0';
        count_r    <= (others => '0');
        window_cnt <= (others => '0');
        active     <= '0';
        done_r     <= '0';
      else
        -- Synchronizer
        ro_sync1 <= ro_in;
        ro_sync2 <= ro_sync1;

        if start = '1' and active = '0' then
          -- Start measurement
          count_r    <= (others => '0');
          window_cnt <= (others => '0');
          active     <= '1';
          done_r     <= '0';
        elsif active = '1' then
          -- Increment window counter
          window_cnt <= window_cnt + 1;

          -- Count oscillation edges
          if (ro_sync2 = '1' and ro_prev = '0') then
            count_r <= count_r + 1;
          end if;

          -- Check window complete
          if window_cnt = to_unsigned(RING_OSC_DEPTH-1, window_cnt'length) then
            active <= '0';
            done_r <= '1';
          end if;
        end if;

        ro_prev <= ro_sync2;
      end if;
    end if;
  end process;

  count_out <= count_r;
  done      <= done_r;
end architecture;
