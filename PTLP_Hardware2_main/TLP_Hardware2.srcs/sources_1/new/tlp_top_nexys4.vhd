library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_nexys4 is
generic (
    INPUT_WIDTH    : integer :=64;
    RING_OSC_DEPTH : integer :=10000;
    OUTPUT_WIDTH   : integer :=64);
  port (
    clk : in  std_logic;  -- 100 MHz onboard clock
    rst    : in  std_logic;
    uart_rx: in  std_logic;   -- FT2232 USB-UART RX
    uart_tx: out std_logic;    -- FT2232 USB-UART TX
    puf_done1: out std_logic;
    puf_busy : out std_logic;
    led0 : out std_logic;
    led1 : out std_logic;
    led2 : out std_logic;
    led3 : out std_logic;
    led4 : out std_logic;
    led5 : out std_logic;
    led6 : out std_logic;
    led7 : out std_logic;
    led8 : out std_logic;
    led9 : out std_logic;
    led10 : out std_logic;
    led11 : out std_logic;
    led12 : out std_logic;
    puf_start1: out std_logic
  );
end entity;

architecture rtl of top_nexys4 is

  ----------------------------------------------------------------------------
  -- SIGNALS
  ----------------------------------------------------------------------------
  -- GLIP logic-side FIFOs (byte-wide, valid/ready)
  signal fifo_in_data    : std_logic_vector(7 downto 0);  -- host->FPGA
  signal fifo_in_valid   : std_logic;
  signal fifo_in_ready   : std_logic;

  signal fifo_out_data   : std_logic_vector(7 downto 0);  -- FPGA->host
  signal fifo_out_valid  : std_logic;
  signal fifo_out_ready  : std_logic;

  signal com_rst         : std_logic;
  signal ctrl_logic_rst  : std_logic;

  -- If CTS is not wired on Nexys USB-UART, tie low (active-low = ready)
  signal uart_cts_n      : std_logic := '0';
  signal uart_rts_n      : std_logic;  -- unused

  -- Bridge side (expects empty/full style)
  signal rx_data         : std_logic_vector(7 downto 0);
  signal rx_empty        : std_logic;
  signal rx_rd           : std_logic;

  signal tx_data         : std_logic_vector(7 downto 0);
  signal tx_full         : std_logic;
  signal tx_wr           : std_logic;

  -- PUF handshake + data
  signal challenge       : std_logic_vector(INPUT_WIDTH-1 downto 0);
  signal response        : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
  signal puf_start       : std_logic:='0';
  signal puf_reset       : std_logic:='0';
  signal puf_done        : std_logic:='0';

  -- local logic reset (merge external + GLIP logic reset)
  signal rst_logic       : std_logic:='0';
  signal nrst            : std_logic:='0';
  
  signal rx_fifo_flush : std_logic;
  
--  -- signals for GLIP <-> bridge
--  signal rx_data  : std_logic_vector(7 downto 0);
--  signal rx_empty : std_logic;
--  signal rx_rd    : std_logic;
--  signal tx_data  : std_logic_vector(7 downto 0);
--  signal tx_full  : std_logic;
--  signal tx_wr    : std_logic;

--  -- signals for bridge <-> PUF
--  signal challenge : std_logic_vector(127 downto 0);
--  signal response  : std_logic_vector(127 downto 0);
--  signal start, done, puf_reset : std_logic;
begin
puf_done1<=puf_done;
puf_start1<= puf_start;
-- Merge resets so the logic and FIFOs init coherently
nrst <= not rst;
--led0 <= nrst;  
rst_logic <= (nrst) or ctrl_logic_rst;
--led1 <= rst_logic; 
--led2<=puf_reset;
--led3<=fifo_in_valid;
--led4<=fifo_out_ready;
--led5<=uart_rx;
--led6<=fifo_in_data(7);
--led7 <= rx_rd;
--led8 <= fifo_in_ready;
--led9 <= fifo_out_valid;
  u_uart : entity work.glip_uart_toplevel
      generic map (
      FREQ_CLK_IO      => 100_000_000,
      BAUD             => 1_000_000,
      WIDTH            => 8,
      BUFFER_OUT_DEPTH => 4096,
      BYPASS_CTRL => 1
    )
    port map (
      clk              => clk,
      clk_io           => clk,
      rst              => nrst,
      rx_fifo_flush => rx_fifo_flush,  ---///<<modified

      com_rst          => com_rst,

      fifo_out_data    => fifo_out_data,   -- FPGA->host
      fifo_out_valid   => fifo_out_valid,
      fifo_out_ready   => fifo_out_ready,

      fifo_in_data     => fifo_in_data,    -- host->FPGA
      fifo_in_valid    => fifo_in_valid,
      fifo_in_ready    => fifo_in_ready,

      ctrl_logic_rst   => ctrl_logic_rst,

      uart_rx          => uart_rx,
      uart_tx          => uart_tx,
      uart_cts_n       => uart_cts_n,
      uart_rts_n       => uart_rts_n,

      error            => open
    );

  ----------------------------------------------------------------------------
  -- VALID/READY  <->  EMPTY/FULL ADAPTERS (tiny glue)
  ----------------------------------------------------------------------------
  -- host->FPGA path
  rx_data       <= fifo_in_data;
  rx_empty      <= not fifo_in_valid;
  fifo_in_ready <= rx_rd;

  -- FPGA->host path
  fifo_out_data  <= tx_data;
  fifo_out_valid <= tx_wr;
  tx_full        <= not fifo_out_ready;
  ----------------------------------------------------------------------------
  -- BRIDGE (bytes ↔ PUF handshake + 128b path)
  ----------------------------------------------------------------------------

  u_bridge : entity work.puf_bridge
  generic map (
      INPUT_WIDTH => INPUT_WIDTH,
      OUTPUT_WIDTH => OUTPUT_WIDTH)
    port map (
      clk           => clk,
      rst           => rst_logic,

      rx_data       => rx_data,
      rx_empty      => rx_empty,
      rx_rd         => rx_rd,
      rx_fifo_flush => rx_fifo_flush,
      
      tx_data       => tx_data,
      tx_full       => tx_full,
      tx_wr         => tx_wr,

--      puf_clk       => clk,
      puf_reset     => puf_reset,
      challenge_o   => challenge,
      puf_start     => puf_start,
      led5  => led5,
      led6  => led6,
      led7  => led7,
      led8  => led8,
      led9  => led9,
      led10  => led10,
      led11  => open,
      led12  => led12,
      puf_done      => puf_done,
      response_i    => response
    );
  ----------------------------------------------------------------------------
  -- PUF CORE (with start/done + 128-bit response)
  ----------------------------------------------------------------------------
  u_puf : entity work.SCRO_XOR_PUF
    generic map (
      INPUT_WIDTH => INPUT_WIDTH,
      OUTPUT_WIDTH => OUTPUT_WIDTH,
      SEL_WIDTH => 5,
      K_XOR => 5,
      RING_OSC_DEPTH => RING_OSC_DEPTH
    )
    port map (
      clk          => clk,
      reset_clk    => rst_logic,
      reset        => puf_reset,
      challenge    => challenge,

      puf_start    => puf_start,
      puf_done     => puf_done,
      puf_busy     => puf_busy,
          led0    => led0,
    led1    => led1,
    led2    => led2,
    led3    => led3,
      puf_response => response
    );
 led11<= puf_reset;
 
end architecture;
