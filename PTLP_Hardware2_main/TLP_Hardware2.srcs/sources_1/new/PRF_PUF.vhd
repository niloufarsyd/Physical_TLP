library ieee;
use ieee.std_logic_1164.all;

entity PRF_PUF is
  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;

    -- PRF control & key
    prf_start    : in  std_logic;
    key128       : in  std_logic_vector(127 downto 0);
    puzzle_id    : in  std_logic_vector(63 downto 0);  -- 64-bit id

    -- PUF resets
    reset_clk    : in  std_logic;
    reset        : in  std_logic;

    -- Outputs
    puf_response : out std_logic_vector(127 downto 0);
    prf_done     : out std_logic
  );
end entity;

architecture rtl of PRF_PUF is
  signal challenge : std_logic_vector(127 downto 0);
begin
  u_prf : entity work.PRF_AES128
    port map (
      clk           => clk,
      rst_n         => rst_n,
      start         => prf_start,
      k_i           => key128,
      puzzle_id_i   => puzzle_id,         -- already 64-bit SLV
      challenge_out => challenge,
      done          => prf_done
    );

  u_puf : entity work.SCRO_XOR_PUF
    port map (
      clk          => clk,
      reset_clk    => reset_clk,
      reset        => reset,
      challenge    => challenge,
      puf_response => puf_response
    );
end architecture;
