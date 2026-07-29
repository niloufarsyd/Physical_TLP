library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PRF_AES128 is
  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;

    start         : in  std_logic;                       -- pulse to generate one challenge
    k_i           : in  std_logic_vector(127 downto 0);  -- AES-128 key for this round
    puzzle_id_i   : in  std_logic_vector(63 downto 0);   -- i (round / puzzle id)

    challenge_out : out std_logic_vector(127 downto 0);  -- PRF(k, i)
    done          : out std_logic                        -- 1-cycle pulse when challenge valid
  );
end entity;

architecture rtl of PRF_AES128 is
  -- ========= aes_core interface (secworks internal core) =========
--  component aes_core is
--    port (
--      clk     : in  std_logic;
--      reset_n : in  std_logic;

--      init    : in  std_logic;                           -- assert 1 cycle to (re)load/expand key
--      next0    : in  std_logic;                           -- assert 1 cycle to process block
--      encdec  : in  std_logic;                           -- '1' = encrypt
--      keylen  : in  std_logic;                           -- '0' = 128-bit, '1' = 256-bit

--      key     : in  std_logic_vector(255 downto 0);      -- only lower 128 bits used when keylen='0'
--      block0   : in  std_logic_vector(127 downto 0);

--      ready   : out std_logic;                           -- high when core is idle/ready
--      result  : out std_logic_vector(127 downto 0)       -- valid when ready rises after a 'next'
--    );
--  end component;

  type state_t is (IDLE, DO_INIT, WAIT_INIT, DO_NEXT, WAIT_NEXT);
  signal state       : state_t := IDLE;

  signal aes_init    : std_logic := '0';
  signal aes_next    : std_logic := '0';
  signal aes_ready   : std_logic;
  signal aes_result  : std_logic_vector(127 downto 0);

  signal key_256     : std_logic_vector(255 downto 0);
  signal key_cached  : std_logic_vector(127 downto 0);
  signal key_dirty   : std_logic := '1';

  -- domain-separated counter block: "PRF1" (0x50 0x52 0x46 0x31) || i || 32'b0
  function make_block(i64 : std_logic_vector(63 downto 0)) return std_logic_vector is
    variable b : std_logic_vector(127 downto 0);
  begin
    b(127 downto 96) := x"50524631";      -- ASCII "PRF1"
    b(95  downto 32) := i64;
    b(31  downto 0)  := (others => '0');
    return b;
  end;

  signal block_in    : std_logic_vector(127 downto 0);
  signal start_d     : std_logic := '0';
  signal start_pulse : std_logic := '0';
begin
  -- pack 128-bit key into 256-bit vector (low half used for 128-bit mode)
  key_256(127 downto 0)   <= k_i;
  key_256(255 downto 128) <= (others => '0');

  block_in <= make_block(puzzle_id_i);

  -- edge detect on start
  process(clk) begin
    if rising_edge(clk) then
      start_d     <= start;
      start_pulse <= start and not start_d;
    end if;
  end process;

  -- simple FSM
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      state         <= IDLE;
      aes_init      <= '0';
      aes_next      <= '0';
      challenge_out <= (others => '0');
      done          <= '0';
      key_cached    <= (others => '0');
      key_dirty     <= '1';
    elsif rising_edge(clk) then
      -- defaults
      aes_init <= '0';
      aes_next <= '0';
      done     <= '0';

      -- detect key change (reload/expand on next request)
      if k_i /= key_cached then
        key_cached <= k_i;
        key_dirty  <= '1';
      end if;

      case state is
        when IDLE =>
          if start_pulse = '1' then
            if key_dirty = '1' then
              state    <= DO_INIT;
            else
              state    <= DO_NEXT;
            end if;
          end if;

        when DO_INIT =>
          if aes_ready = '1' then
            aes_init  <= '1';      -- one-cycle pulse
            state     <= WAIT_INIT;
          end if;

        when WAIT_INIT =>
          -- wait for core to drop ready and come back up
          if aes_ready = '1' then
            -- ready is high both before and after init; detect the low->high round trip:
            -- simplest is to wait one cycle after asserting init, then proceed when still ready.
            -- (For strictness you can add a 2-state sub-FSM to watch ready fall then rise.)
            key_dirty <= '0';
            state     <= DO_NEXT;
          end if;

        when DO_NEXT =>
          if aes_ready = '1' then
            aes_next <= '1';       -- one-cycle pulse to encrypt block_in
            state    <= WAIT_NEXT;
          end if;

        when WAIT_NEXT =>
          if aes_ready = '1' then
            challenge_out <= aes_result;  -- result becomes valid when ready returns high
            done          <= '1';
            state         <= IDLE;
          end if;
      end case;
    end if;
  end process;

  -- Instantiate the AES core (secworks aes_core)
  u_aes: entity work.aes_core
    port map (
      clk     => clk,
      reset_n => rst_n,
      init    => aes_init,
      next0    => aes_next,
      encdec  => '1',          -- encrypt
      keylen  => '0',          -- 128-bit key
      key     => key_256,
      block0   => block_in,
      ready   => aes_ready,
      result  => aes_result
    );
end architecture;
