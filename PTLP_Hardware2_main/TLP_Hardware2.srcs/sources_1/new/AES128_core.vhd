library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AES128_core is
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic; -- active-low
    start    : in  std_logic; -- pulse high to start
    key      : in  std_logic_vector(127 downto 0);
    block_in : in  std_logic_vector(127 downto 0);
    block_out: out std_logic_vector(127 downto 0);
    ready    : out std_logic
  );
end entity;

architecture rtl of AES128_core is
  -- ================== Helper functions ==================
  function xtime(b: std_logic_vector(7 downto 0)) return std_logic_vector is
    variable x : std_logic_vector(7 downto 0) := b(6 downto 0) & '0';
  begin
    if b(7) = '1' then
      x := x xor x"1B";
    end if;
    return x;
  end function;

  function mul2(b: std_logic_vector(7 downto 0)) return std_logic_vector is
  begin
    return xtime(b);
  end function;

  function mul3(b: std_logic_vector(7 downto 0)) return std_logic_vector is
  begin
    return std_logic_vector(unsigned(xtime(b)) xor unsigned(b));
  end function;

  -- 256-byte AES S-Box
  type sbox_t is array(0 to 255) of std_logic_vector(7 downto 0);
  constant SBOX : sbox_t := (
    x"63",x"7C",x"77",x"7B",x"F2",x"6B",x"6F",x"C5",x"30",x"01",x"67",x"2B",x"FE",x"D7",x"AB",x"76",
    x"CA",x"82",x"C9",x"7D",x"FA",x"59",x"47",x"F0",x"AD",x"D4",x"A2",x"AF",x"9C",x"A4",x"72",x"C0",
    x"B7",x"FD",x"93",x"26",x"36",x"3F",x"F7",x"CC",x"34",x"A5",x"E5",x"F1",x"71",x"D8",x"31",x"15",
    x"04",x"C7",x"23",x"C3",x"18",x"96",x"05",x"9A",x"07",x"12",x"80",x"E2",x"EB",x"27",x"B2",x"75",
    x"09",x"83",x"2C",x"1A",x"1B",x"6E",x"5A",x"A0",x"52",x"3B",x"D6",x"B3",x"29",x"E3",x"2F",x"84",
    x"53",x"D1",x"00",x"ED",x"20",x"FC",x"B1",x"5B",x"6A",x"CB",x"BE",x"39",x"4A",x"4C",x"58",x"CF",
    x"D0",x"EF",x"AA",x"FB",x"43",x"4D",x"33",x"85",x"45",x"F9",x"02",x"7F",x"50",x"3C",x"9F",x"A8",
    x"51",x"A3",x"40",x"8F",x"92",x"9D",x"38",x"F5",x"BC",x"B6",x"DA",x"21",x"10",x"FF",x"F3",x"D2",
    x"CD",x"0C",x"13",x"EC",x"5F",x"97",x"44",x"17",x"C4",x"A7",x"7E",x"3D",x"64",x"5D",x"19",x"73",
    x"60",x"81",x"4F",x"DC",x"22",x"2A",x"90",x"88",x"46",x"EE",x"B8",x"14",x"DE",x"5E",x"0B",x"DB",
    x"E0",x"32",x"3A",x"0A",x"49",x"06",x"24",x"5C",x"C2",x"D3",x"AC",x"62",x"91",x"95",x"E4",x"79",
    x"E7",x"C8",x"37",x"6D",x"8D",x"D5",x"4E",x"A9",x"6C",x"56",x"F4",x"EA",x"65",x"7A",x"AE",x"08",
    x"BA",x"78",x"25",x"2E",x"1C",x"A6",x"B4",x"C6",x"E8",x"DD",x"74",x"1F",x"4B",x"BD",x"8B",x"8A",
    x"70",x"3E",x"B5",x"66",x"48",x"03",x"F6",x"0E",x"61",x"35",x"57",x"B9",x"86",x"C1",x"1D",x"9E",
    x"E1",x"F8",x"98",x"11",x"69",x"D9",x"8E",x"94",x"9B",x"1E",x"87",x"E9",x"CE",x"55",x"28",x"DF",
    x"8C",x"A1",x"89",x"0D",x"BF",x"E6",x"42",x"68",x"41",x"99",x"2D",x"0F",x"B0",x"54",x"BB",x"16"
  );

  function sub_byte(b: std_logic_vector(7 downto 0)) return std_logic_vector is
  begin
    return SBOX(to_integer(unsigned(b)));
  end function;

  function sub_bytes(s: std_logic_vector(127 downto 0)) return std_logic_vector is
    variable r : std_logic_vector(127 downto 0);
  begin
    for i in 0 to 15 loop
      r(8*i+7 downto 8*i) := sub_byte(s(8*i+7 downto 8*i));
    end loop;
    return r;
  end function;

  function shift_rows(s: std_logic_vector(127 downto 0)) return std_logic_vector is
    variable a : std_logic_vector(127 downto 0) := s;
    variable r : std_logic_vector(127 downto 0);
    -- state is 4x4 bytes in column-major:
    -- [  0  4  8 12 ]
    -- [  1  5  9 13 ]
    -- [  2  6 10 14 ]
    -- [  3  7 11 15 ]
  begin
    -- row 0 stays
    r(7 downto 0)      := a(7 downto 0);       -- 0
    r(39 downto 32)    := a(39 downto 32);     -- 4
    r(71 downto 64)    := a(71 downto 64);     -- 8
    r(103 downto 96)   := a(103 downto 96);    -- 12
    -- row 1 shifts by 1
    r(15 downto 8)     := a(47 downto 40);     -- 5
    r(47 downto 40)    := a(79 downto 72);     -- 9
    r(79 downto 72)    := a(111 downto 104);   -- 13
    r(111 downto 104)  := a(15 downto 8);      -- 1
    -- row 2 shifts by 2
    r(23 downto 16)    := a(87 downto 80);     -- 10
    r(55 downto 48)    := a(119 downto 112);   -- 14
    r(87 downto 80)    := a(23 downto 16);     -- 2
    r(119 downto 112)  := a(55 downto 48);     -- 6
    -- row 3 shifts by 3 (i.e., right by 1)
    r(31 downto 24)    := a(31 downto 24);     -- 3 -> 3
    r(63 downto 56)    := a(95 downto 88);     -- 11 -> 7
    r(95 downto 88)    := a(127 downto 120);   -- 15 -> 11
    r(127 downto 120)  := a(63 downto 56);     -- 7 -> 15
    return r;
  end function;

  function mix_one_col(b0,b1,b2,b3: std_logic_vector(7 downto 0))
           return std_logic_vector is
    variable r0,r1,r2,r3: std_logic_vector(7 downto 0);
  begin
    r0 := std_logic_vector(unsigned(mul2(b0)) xor unsigned(mul3(b1)) xor unsigned(b2)      xor unsigned(b3));
    r1 := std_logic_vector(unsigned(b0)      xor unsigned(mul2(b1)) xor unsigned(mul3(b2)) xor unsigned(b3));
    r2 := std_logic_vector(unsigned(b0)      xor unsigned(b1)       xor unsigned(mul2(b2)) xor unsigned(mul3(b3)));
    r3 := std_logic_vector(unsigned(mul3(b0)) xor unsigned(b1)      xor unsigned(b2)       xor unsigned(mul2(b3)));
    return r0 & r1 & r2 & r3;
  end function;

  function mix_columns(s: std_logic_vector(127 downto 0)) return std_logic_vector is
    variable r : std_logic_vector(127 downto 0);
    variable c : std_logic_vector(31 downto 0);
    function byte(v: std_logic_vector; i: integer) return std_logic_vector is
    begin
      return v(8*i+7 downto 8*i);
    end;
  begin
    for col in 0 to 3 loop
      c := s(32*col+31 downto 32*col);
      r(32*col+31 downto 32*col) :=
        mix_one_col(byte(c,0), byte(c,1), byte(c,2), byte(c,3));
    end loop;
    return r;
  end function;

  function rcon(n: integer) return std_logic_vector is
    -- round 1..10
    type rcon_t is array(1 to 10) of std_logic_vector(31 downto 0);
    constant R : rcon_t := (
      x"01000000", x"02000000", x"04000000", x"08000000", x"10000000",
      x"20000000", x"40000000", x"80000000", x"1B000000", x"36000000"
    );
  begin
    return R(n);
  end function;

  function sub_word(w: std_logic_vector(31 downto 0)) return std_logic_vector is
    variable r: std_logic_vector(31 downto 0);
  begin
    r(31 downto 24) := sub_byte(w(31 downto 24));
    r(23 downto 16) := sub_byte(w(23 downto 16));
    r(15 downto 8)  := sub_byte(w(15 downto 8));
    r(7 downto 0)   := sub_byte(w(7 downto 0));
    return r;
  end function;

  function rot_word(w: std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return w(23 downto 0) & w(31 downto 24);
  end function;

  function next_round_key(k: std_logic_vector(127 downto 0); round: integer)
           return std_logic_vector is
    variable w0,w1,w2,w3,t: std_logic_vector(31 downto 0);
    variable nk: std_logic_vector(127 downto 0);
  begin
    w0 := k(127 downto 96);
    w1 := k(95  downto 64);
    w2 := k(63  downto 32);
    w3 := k(31  downto 0);
    t  := std_logic_vector(unsigned(w0) xor unsigned(sub_word(rot_word(w3))) xor unsigned(rcon(round)));
    nk(127 downto 96) := t;
    nk(95  downto 64) := std_logic_vector(unsigned(w1) xor unsigned(t));
    nk(63  downto 32) := std_logic_vector(unsigned(w2) xor unsigned(nk(95 downto 64)));
    nk(31  downto 0)  := std_logic_vector(unsigned(w3) xor unsigned(nk(63 downto 32)));
    return nk;
  end function;

  -- ================== State ==================
  type state_t is (IDLE, ADDRK, ROUND1_9, FINAL, DONE);
  signal st        : state_t;
  signal round_ctr : integer range 0 to 10;
  signal rk        : std_logic_vector(127 downto 0);
  signal s_reg     : std_logic_vector(127 downto 0);
  signal out_reg   : std_logic_vector(127 downto 0);
  signal ready_r   : std_logic := '0';
begin
  ready <= ready_r;
  block_out <= out_reg;

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      st        <= IDLE;
      round_ctr <= 0;
      rk        <= (others => '0');
      s_reg     <= (others => '0');
      out_reg   <= (others => '0');
      ready_r   <= '0';
    elsif rising_edge(clk) then
      ready_r <= '0';
      case st is
        when IDLE =>
          if start = '1' then
            rk    <= key;
            s_reg <= block_in xor key; -- AddRoundKey
            round_ctr <= 1;
            st    <= ROUND1_9;
          end if;
        when ROUND1_9 =>
          -- 9 full rounds
          s_reg <= (mix_columns(shift_rows(sub_bytes(s_reg)))) xor next_round_key(rk, round_ctr);
          rk    <= next_round_key(rk, round_ctr);
          if round_ctr = 9 then
            st <= FINAL;
          else
            round_ctr <= round_ctr + 1;
          end if;
        when FINAL =>
          -- final round (no MixColumns), use round 10 key
          s_reg   <= (shift_rows(sub_bytes(s_reg))) xor next_round_key(rk, 10);
          out_reg <= (shift_rows(sub_bytes(s_reg))) xor next_round_key(rk, 10); -- latch output
          st      <= DONE;
        when DONE =>
          ready_r   <= '1';
          st        <= IDLE;
        when others =>
          st <= IDLE;
      end case;
    end if;
  end process;
end architecture;
