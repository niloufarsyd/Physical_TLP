library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity puf_bridge is
  generic (
    INPUT_WIDTH  : integer := 64;
    OUTPUT_WIDTH : integer := 64
  );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;

    -- UART RX/TX interface (empty/full handshake)
    rx_data   : in  std_logic_vector(7 downto 0);
    rx_empty  : in  std_logic;
    rx_rd     : out std_logic;
    rx_fifo_flush  : out std_logic; ---//<<modified
    tx_data   : out std_logic_vector(7 downto 0);
    tx_full   : in  std_logic;
    tx_wr     : out std_logic;

    -- Interface to PUF core
--    puf_clk   : out std_logic;
    puf_reset : out std_logic;
    puf_start : out std_logic;
    led4, led5, led6, led7, led8, led9, led10, led11, led12, led13, led14  : out std_logic;
    puf_done  : in  std_logic;
    challenge_o : out std_logic_vector(INPUT_WIDTH-1 downto 0);
    response_i  : in  std_logic_vector(OUTPUT_WIDTH-1 downto 0)
  );
end entity;

--architecture rtl of puf_bridge is

--  type state_type is (IDLE, RX_FLAG, RX_FLAG2, RX_CHAL, RESET_PUF, START_PUF, WAIT_PUF, TX_RESP);
--  signal state     : state_type := IDLE;

--  signal chal_reg  : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
--  signal resp_reg  : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');

--  signal byte_cnt  : integer range 0 to (INPUT_WIDTH/8 - 1) := 0;
--  signal byte_latch      : std_logic_vector(7 downto 0) := (others => '0');

--  -- handshake regs
--  signal tx_data_reg  : std_logic_vector(7 downto 0) := (others => '0');
--  signal tx_wr_reg    : std_logic := '0';

--  signal puf_reset_reg : std_logic := '0';
--  signal puf_start_reg : std_logic := '0';
--  signal rx_rd_i       : std_logic := '0';
  
  

--begin
--  -- map outputs
--  tx_data     <= tx_data_reg;
--  tx_wr       <= tx_wr_reg;
--  challenge_o <= chal_reg;
--  puf_reset   <= puf_reset_reg;
--  puf_start   <= puf_start_reg;
----  puf_clk     <= clk;
-- rx_rd        <= rx_rd_i;
 
 
 
--  process(clk, rst)
--  begin
--    if rst = '1' then
--      state         <= IDLE;
--      chal_reg      <= (others => '0');
--      resp_reg      <= (others => '0');
--      byte_cnt      <= 0;
--      tx_data_reg   <= (others => '0');
--      tx_wr_reg     <= '0';
--      puf_reset_reg <= '0';
--      puf_start_reg <= '0';
--      rx_rd_i         <= '0';
--      byte_latch     <= (others => '0');

--    elsif rising_edge(clk) then
--      -- defaults
--      tx_wr_reg     <= '0';
--      puf_reset_reg <= '0';
--      puf_start_reg <= '0';
--      rx_rd_i         <= '0';

--      case state is
--        when IDLE =>
----          if rx_empty = '0' and rx_data = x"AA" then
--          if rx_empty = '0' and rx_data = x"AA" then
--            rx_rd_i    <= '1';     -- consume sync byte
--            byte_cnt <= 0;
--            state    <= RX_FLAG;
--          end if;

--        when RX_FLAG =>
--          if rx_empty = '0' then
----            byte_latch <= rx_data;  -- capture the current payload byte
--            rx_rd_i  <= '1';
--            state <= RX_Flag2;   -- a fresh byte is ready
--          end if;
        
--        when RX_FLAG2 =>
--            byte_latch <= rx_data;  -- capture the current payload byte
--            state <= RX_CHAL;
            
--        when RX_CHAL =>
--          chal_reg <= chal_reg(INPUT_WIDTH-9 downto 0) & byte_latch;
--                -- consume this byte
        
--          if byte_cnt = (INPUT_WIDTH/8-1 ) then
--            state <= RESET_PUF; -- got all 8 bytes
--          else
--            byte_cnt <= byte_cnt + 1;
--            state    <= RX_FLAG;
--          end if;
      
--        when RESET_PUF =>
--          -- assert reset for one cycle
--          puf_reset_reg <= '1';
--          state <= START_PUF;

--        when START_PUF =>
--          -- deassert reset, pulse start
--          puf_start_reg <= '1';
--          state <= WAIT_PUF;

--        when WAIT_PUF =>
--          if puf_done = '1' then
--            resp_reg <= response_i;
--            byte_cnt <= (OUTPUT_WIDTH/8 - 1);
--            state    <= TX_RESP;
--          end if;

--        when TX_RESP =>
--          if tx_full = '0' then
--            tx_data_reg <= resp_reg(OUTPUT_WIDTH-1 downto OUTPUT_WIDTH-8);
--            resp_reg    <= resp_reg(OUTPUT_WIDTH-9 downto 0) & x"00";
--            tx_wr_reg   <= '1';
--            if byte_cnt = 0 then
--              state <= IDLE;
--            else
--              byte_cnt <= byte_cnt - 1;
--            end if;
--          end if;

--        when others =>
--          state <= IDLE;
--      end case;
--    end if;
--  end process;

--end architecture;


--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

--entity puf_bridge is
--generic (
--    INPUT_WIDTH    : integer :=64;
--    OUTPUT_WIDTH   : integer :=64);
--  port(
--    clk           : in  std_logic;
--    rst           : in  std_logic;
--    -- UART RX FIFO
--    rx_data       : in  std_logic_vector(7 downto 0);
--    rx_empty      : in  std_logic;
--    rx_rd         : out std_logic;
--    -- UART TX FIFO
--    tx_data       : out std_logic_vector(7 downto 0);
--    tx_full       : in  std_logic;
--    tx_wr         : out std_logic;
--    -- PUF core
--    puf_clk       : in  std_logic;  -- can be same as clk; if different, sync start/done
--    puf_reset     : out std_logic;
--    challenge_o   : out std_logic_vector(INPUT_WIDTH-1 downto 0);
--    puf_start     : out std_logic;
--    puf_done      : in  std_logic;
--    response_i    : in  std_logic_vector(OUTPUT_WIDTH-1 downto 0)
--  );
--end entity;

--architecture rtl of puf_bridge is
--  type state_t is (IDLE, WAIT_HDR, RX_CHAL, START_PUF, WAIT_PUF, TX_RESP);
--  signal s              : state_t := IDLE;

--  signal chal_reg       : std_logic_vector(INPUT_WIDTH-1 downto 0);
--  signal resp_reg       : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
--  signal byte_cnt       : unsigned(5 downto 0); -- up to 32 if needed
--  signal rx_rd_i        : std_logic := '0';
--  signal tx_wr_i        : std_logic := '0';
--  signal puf_start_i    : std_logic := '0';
--  signal puf_reset_i    : std_logic := '0';

--begin
--  rx_rd   <= rx_rd_i;
--  tx_wr   <= tx_wr_i;
--  puf_start <= puf_start_i;
--  puf_reset <= puf_reset_i;

--  process(clk)
--  begin
--    if rising_edge(clk) then
--      if rst = '1' then
--        s <= IDLE;
--        rx_rd_i <= '0';
--        tx_wr_i <= '0';
--        puf_start_i <= '0';
--        puf_reset_i <= '1';
--        byte_cnt <= (others => '0');
--      else
--        rx_rd_i <= '0';
--        tx_wr_i <= '0';
--        puf_start_i <= '0';

--        case s is
--          when IDLE =>
--            if rx_empty = '0' then
--              rx_rd_i <= '1';
--              s <= WAIT_HDR;
--            end if;

--          when WAIT_HDR =>
--            -- previous cycle's rx_rd_i makes rx_data valid now
--            if rx_data = x"AA" then
--              byte_cnt <= (others => '0');
--              s <= RX_CHAL;
--            else
--              -- ignore junk; look for next header
--              s <= IDLE;
--            end if;

--          when RX_CHAL =>
--            if rx_empty = '0' then
--              rx_rd_i <= '1';
--              -- pack MSB-first: first byte becomes [127:120]
----              chal_reg(127 - to_integer(byte_cnt)*8 downto 120 - to_integer(byte_cnt)*8) <= rx_data;
--              chal_reg <= chal_reg(55 downto 0) & rx_data;
--              byte_cnt <= byte_cnt + 1;
--              if byte_cnt = to_unsigned(8, byte_cnt'length) then
--                s <= START_PUF;
--              end if;
--            end if;

--          when START_PUF =>
--            challenge_o <= chal_reg;
--            puf_start_i <= '1';               -- one-cycle start
--            s <= WAIT_PUF;

--          when WAIT_PUF =>
--            if puf_done = '1' then
--              resp_reg <= response_i;         -- latch stable PUF response
--              byte_cnt <= (others => '0');
--              s <= TX_RESP;
--            end if;

--          when TX_RESP =>
--            if tx_full = '0' then
--              tx_data <= resp_reg(63 - to_integer(byte_cnt)*8 downto 8 - to_integer(byte_cnt)*8);
--              tx_wr_i <= '1';
--              byte_cnt <= byte_cnt + 1;
--              if byte_cnt = to_unsigned(8, byte_cnt'length) then
--                s <= IDLE;
--              end if;
--            end if;

--        end case;
--      end if;
--    end if;
--  end process;

--end architecture;


--architecture rtl of puf_bridge is
--  type state_type is (IDLE, WAIT_ADV, LATCH, SHIFT, RESET_PUF,RESET_WAIT, START_PUF, WAIT_PUF, TX_RESP);
----  type state_type is (IDLE, WAIT_ADV, LATCH, SHIFT, RESET_PUF, START_PUF, WAIT_PUF, TX_RESP);
--  signal state         : state_type := IDLE;

--  constant CHAL_BYTES  : integer := INPUT_WIDTH/8;
--  constant RESP_BYTES  : integer := OUTPUT_WIDTH/8;
  
--  constant RESET_HOLD_CYC   : integer := 0;  -- 4 >=2 recommended
--  constant START_PULSE_CYC  : integer := 0;  --2- 1..2 safe

--  signal chal_reg      : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
--  signal resp_reg      : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
--  signal byte_latch    : std_logic_vector(7 downto 0) := (others => '0');

--  signal byte_cnt      : integer range 0 to CHAL_BYTES-1 := 0;
--  signal rx_byte_cnt   : integer range 0 to CHAL_BYTES-1 := 0;
--  signal tx_byte_cnt   : integer range 0 to RESP_BYTES-1 := 0;
--  signal wait_ctr      : integer range 0 to 1 := 0;  -- one-cycle guard after each POP
  
--  signal rx_wait_ctr   : integer range 0 to 1 := 0;  -- RX data-advance guard
--  signal rst_ctr       : integer range 0 to RESET_HOLD_CYC := 0;
--  signal start_ctr     : integer range 0 to START_PULSE_CYC := 0;

--  signal tx_data_reg   : std_logic_vector(7 downto 0) := (others => '0');
--  signal tx_wr_reg     : std_logic := '0';
--  signal puf_reset_reg : std_logic := '0';
--  signal puf_start_reg : std_logic := '0';
--  signal rx_rd_i       : std_logic := '0';
--begin
--  tx_data     <= tx_data_reg;
--  tx_wr       <= tx_wr_reg;
--  challenge_o <= chal_reg;
--  puf_reset   <= puf_reset_reg;
--  puf_start   <= puf_start_reg;
--  rx_rd       <= rx_rd_i;

--  process(clk, rst)
--  begin
--    if rst = '1' then
--      state         <= IDLE;
--      chal_reg      <= (others => '0');
--      resp_reg      <= (others => '0');
--      byte_latch    <= (others => '0');
--      rx_byte_cnt   <= 0;
--      tx_byte_cnt   <= 0;
--      rx_wait_ctr   <= 0;
--      rst_ctr       <= 0;
--      start_ctr     <= 0;
--      tx_data_reg   <= (others => '0');
--      tx_wr_reg     <= '0';
--      puf_reset_reg <= '0';
--      puf_start_reg <= '0';
--      rx_rd_i       <= '0';

--    elsif rising_edge(clk) then
--      -- defaults each cycle
--      tx_wr_reg     <= '0';
--      puf_reset_reg <= '0';
--      puf_start_reg <= '0';
--      rx_rd_i       <= '0';

--      case state is
--        -- Detect sync header and POP it (do not shift it).
--        when IDLE =>
--          if rx_empty = '0' and rx_data = x"AA" then
--            rx_rd_i  <= '1';        -- consume header only
--            chal_reg <= (others => '0');
--            rx_byte_cnt <= 0;
--            rx_wait_ctr <= 1;          -- enforce a 1-cycle gap for rx_data to advance
--            state    <= WAIT_ADV;
--          end if;

--        -- One-cycle guard after any POP so rx_data is advanced/stable
--        when WAIT_ADV =>
--          if rx_wait_ctr > 0 then
--            rx_wait_ctr <= rx_wait_ctr - 1;
--          else
--            -- Optionally also require rx_empty='0' here; usually it is
--            state <= LATCH;
--          end if;

--        -- Capture the (now advanced) payload byte. No POP here.
--        when LATCH =>
--          if rx_empty = '0' then
--            byte_latch <= rx_data;
--            state      <= SHIFT;
--          end if;

--        -- Shift latched byte into chal_reg. Count bytes here.
--        -- After shifting (if not last), POP the next byte and wait again.
--        when SHIFT =>
--          chal_reg <= chal_reg(INPUT_WIDTH-9 downto 0) & byte_latch;  -- MSB-first packing

--          if rx_byte_cnt = CHAL_BYTES - 1 then
--            rst_ctr <= RESET_HOLD_CYC;           
--            state   <= RESET_PUF;   -- exactly N bytes loaded
--          else
--            rx_byte_cnt <= rx_byte_cnt + 1;
--            rx_rd_i  <= '1';      -- POP next payload byte *after* shifting
--            rx_wait_ctr <= 1;        -- wait one cycle before latching next
--            state    <= WAIT_ADV;
--          end if;

--        -- Assert reset one cycle
----        when RESET_PUF =>
----          puf_reset_reg <= '1';
----          state         <= START_PUF;

--        -- Pulse start
----        when START_PUF =>
----          puf_start_reg <= '1';
----          state         <= WAIT_PUF;

--        when RESET_PUF =>
--          puf_reset_reg <= '1';
--          if rst_ctr = 0 then
--            state <= RESET_WAIT;
--          else
--            rst_ctr <= rst_ctr - 1;
--          end if;
        
--        -- Wait for the core to be idle (puf_done low) before starting
--        when RESET_WAIT =>
--          -- If you can wire puf_busy, require puf_busy='0' here as well.
----          if puf_done = '0' then
--            start_ctr <= START_PULSE_CYC;
--            state     <= START_PUF;
----          end if;
        
--        when START_PUF =>
--          puf_start_reg <= '1';
--          if start_ctr = 0 then
--            state         <= WAIT_PUF;
--          else
--            start_ctr <= start_ctr - 1;
--          end if;

--        when WAIT_PUF =>
--          if puf_done = '1' then
--            resp_reg <= response_i;
--            tx_byte_cnt <= 0;
--            state    <= TX_RESP;
--          end if;

--          when TX_RESP =>
--            if tx_full = '0' then
--              tx_data_reg <= resp_reg(OUTPUT_WIDTH-1 - byte_cnt*8 downto OUTPUT_WIDTH-8 - byte_cnt*8);
--              tx_wr_reg <= '1';
--              if tx_byte_cnt = RESP_BYTES-1 then
--                tx_byte_cnt <= 0;
--                rx_byte_cnt <= 0;
--                state    <= IDLE;      -- done sending all bytes, ready for next challenge
--              else
--                tx_byte_cnt <= tx_byte_cnt + 1;
--              end if;
--            end if;

--        when others =>
--          state <= IDLE;
--      end case;
--    end if;
--  end process;
--end architecture;

architecture rtl of puf_bridge is
  type state_type is (IDLE, WAIT_ADV, LATCH, SHIFT, RESET_PUF, START_PUF, WAIT_PUF, TX_RESP);
  signal state         : state_type := IDLE;

  constant CHAL_BYTES  : integer := INPUT_WIDTH/8;
  constant RESP_BYTES  : integer := OUTPUT_WIDTH/8;

  signal chal_reg      : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
  signal resp_reg      : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
  signal byte_latch    : std_logic_vector(7 downto 0) := (others => '0');

  signal byte_cnt      : integer range 0 to CHAL_BYTES-1 := 0;
  signal wait_ctr      : integer range 0 to 1 := 0;  -- one-cycle guard after each POP

  signal tx_data_reg   : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_wr_reg     : std_logic := '0';
  signal puf_reset_reg : std_logic := '0';
  signal puf_start_reg : std_logic := '0';
  signal rx_rd_i       : std_logic := '0';
begin
  tx_data     <= tx_data_reg;
  tx_wr       <= tx_wr_reg;
  challenge_o <= chal_reg;
  puf_reset   <= puf_reset_reg;
  puf_start   <= puf_start_reg;
  rx_rd       <= rx_rd_i;

  process(clk, rst)
  begin
    if rst = '1' then
      state         <= IDLE;
      chal_reg      <= (others => '0');
      resp_reg      <= (others => '0');
      byte_latch    <= (others => '0');
      byte_cnt      <= 0;
      wait_ctr      <= 0;
      tx_data_reg   <= (others => '0');
      tx_wr_reg     <= '0';
      puf_reset_reg <= '0';
      puf_start_reg <= '0';
      rx_rd_i       <= '0';
      led4 <='0';
      led5 <='0';
      led6 <='0';
      led7 <='0';
      led8 <='0';
      led9 <='0';
      led10 <='0';
      led11 <='0';
      led12 <='0';
      rx_fifo_flush <= '0';   -- << NEW: flush FIFO after sending response
    elsif rising_edge(clk) then
      -- defaults each cycle
      tx_wr_reg     <= '0';
      puf_reset_reg <= '0';
      puf_start_reg <= '0';
      rx_rd_i       <= '0';
      led4 <='0';
      led5 <='0';
      led6 <='0';
      led7 <='0';
      led8 <='0';
      led9 <='0';
      led10 <='0';
      led11 <='0';
      led12 <='0';
      rx_fifo_flush <= '0';   -- << NEW: flush FIFO after sending response
      case state is
        -- Detect sync header and POP it (do not shift it).
        when IDLE =>
          if rx_empty = '0' and rx_data = x"AA" then
            rx_rd_i  <= '1';        -- consume header only
            chal_reg <= (others => '0');
            byte_cnt <= 0;
            wait_ctr <= 1;          -- enforce a 1-cycle gap for rx_data to advance
            led4 <='1';
            state    <= WAIT_ADV;
          end if;
          led5 <='1';

        -- One-cycle guard after any POP so rx_data is advanced/stable
        when WAIT_ADV =>
          if wait_ctr > 0 then
            wait_ctr <= wait_ctr - 1;
          else
            -- Optionally also require rx_empty='0' here; usually it is
            state <= LATCH;
          end if;
          led6 <='1';

        -- Capture the (now advanced) payload byte. No POP here.
        when LATCH =>
          if rx_empty = '0' then
            byte_latch <= rx_data;
            state      <= SHIFT;
          end if;
          led7 <='1';

        -- Shift latched byte into chal_reg. Count bytes here.
        -- After shifting (if not last), POP the next byte and wait again.
        when SHIFT =>
          chal_reg <= chal_reg(INPUT_WIDTH-9 downto 0) & byte_latch;  -- MSB-first packing
          led8 <='1';

          if byte_cnt = CHAL_BYTES - 1 then            
            state <= RESET_PUF;   -- exactly N bytes loaded
          else
            byte_cnt <= byte_cnt + 1;            
            rx_rd_i  <= '1';      -- POP next payload byte *after* shifting
            wait_ctr <= 1;        -- wait one cycle before latching next
            state    <= WAIT_ADV;
          end if;

        when RESET_PUF =>
          puf_reset_reg <= '1';
          state         <= START_PUF;

        when START_PUF =>
          puf_start_reg <= '1';
          state         <= WAIT_PUF;

        when WAIT_PUF =>
          led9 <='1';
          if puf_done = '1' then
            led10 <='1';
            resp_reg <= response_i;
            byte_cnt <= 0;
            state    <= TX_RESP;
          end if;
 
        when TX_RESP =>
          if tx_full = '0' then
            -- Send MSB-first, one byte per cycle
            led11 <='1';
            tx_data_reg <= resp_reg(OUTPUT_WIDTH-1 - byte_cnt*8 downto OUTPUT_WIDTH-8 - byte_cnt*8);
            tx_wr_reg   <= '1';
        
            if byte_cnt = RESP_BYTES-1 then
              byte_cnt <= 0;
              rx_fifo_flush <= '1';   -- << NEW: flush FIFO after sending response
              state    <= IDLE;      -- done sending all bytes
            else
              byte_cnt <= byte_cnt + 1;
            end if;
          end if;
          led12 <='1';

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;
end architecture;