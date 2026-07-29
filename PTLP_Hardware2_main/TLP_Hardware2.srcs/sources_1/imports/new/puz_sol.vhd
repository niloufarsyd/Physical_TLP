----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/24/2024 03:46:43 PM
-- Design Name: 
-- Module Name: puz_sol - Behavioral
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
use ieee.numeric_std.all;
use work.my_constants.all;  -- Import the package
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity puz_sol is
--generic (
--        L : integer := DEFAULT_L;  -- Number of vectors --- WAS 16
--        MAX_N :integer := MAX_N;
--        lambda : integer := LAMBDA  -- Default value or specify as needed
--    );
generic (
        L : integer := 1;  -- Number of vectors --- WAS 16
        MAX_N :integer := 300;
        lambda : integer := 256  -- Default value or specify as needed
    );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           --Z_dec : in STD_LOGIC_VECTOR (7 downto 0);
           c0_seed : in STD_LOGIC_VECTOR (lambda-1 downto 0);
           Z : in STD_LOGIC_VECTOR (L*lambda-1 downto 0);
           --lib : in STD_LOGIC_VECTOR ((MAX_N*lambda)-1 downto 0);
           lib : in bram_type;
           Helper_index : in integer;
           N : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           ready_gen : in STD_LOGIC;

           ready_output :out STD_LOGIC;
           S  : out STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0)          
           --S_enc : out STD_LOGIC_VECTOR (7 downto 0)
           );
end puz_sol;

architecture Behavioral of puz_sol is
    
    --signal s                  : std_logic_vector(lambda-1 downto 0);--related to decoder
    --signal Z                  : std_logic_vector(lambda-1 downto 0):= (others => '0');--related to decoder
    --type bram_type is array (0 to MAX_N-1) of std_logic_vector(lambda-1 downto 0);
    
    signal c0             :  STD_LOGIC_VECTOR (lambda-1 downto 0):= x"0D0000000000000000000000000000000000000000000000000000000000ACE3";

    
    type state_type2 is (reset2, idle, computeP0, checkN, checkB, computeCi, wait2, checkHelper, checkL,computeXOR,done2);
    signal current_state2, next_state2 : state_type2 := reset2;  -- Initialize to idle state 
    
    signal lfsr               : std_logic_vector(31 downto 0) := x"0000ACE1";  -- Initial seed for the LFSR
    
    signal rst_n : std_logic;
    signal data_ready         : std_logic := '0';               -- Trigger for starting the hashing
    signal data_ready_signal  : std_logic := '0';               -- 
    signal n_blocks_signal    : natural := 1;                   -- Assuming 1 block of data, adjust as needed
    signal msg_block          : std_logic_vector(2*lambda-1 downto 0):= (others => '0'); -- Message input for SHA-256, 512 bits
    signal msg_block_signal   : std_logic_vector(2*lambda-1 downto 0):= (others => '0'); -- Message input for SHA-256, 512 bits
    signal hash_output_signal : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash
    signal hash_finished      : std_logic:= '0';
    signal r_i                : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash
    signal ci         : unsigned  (lambda-1 downto 0):= (others => '0');
    signal S_temp                : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash
    signal Z_temp                : std_logic_vector(lambda-1 downto 0):= (others => '0');--related to decoder
    signal Si                    : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash
    
    signal counterN             : integer :=1;
    signal counterB             : integer :=1;
    signal counterL             : integer :=0;
    --signal rN_i             : integer :=0;
    signal rN_i              :unsigned(lambda-1 downto 0);
    signal N_int             : integer :=0;
    signal B_int             : integer :=0;
    --signal k                 : integer :=0;
    signal match_lib  : std_logic := '0';
    signal checkPass  : std_logic := '0';
    
    signal lib_output             : std_logic_vector(lambda-1 downto 0):= (others => '0');
    signal lib_index          :integer:=0;
    signal lib_read    :std_logic:= '0';
    
    component decoder8to256 is
    Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
           b : out STD_LOGIC_VECTOR (255 downto 0)
           );
    end component;
    component encoder256to8 is
    Port ( b : in STD_LOGIC_VECTOR (255 downto 0);
           a : out STD_LOGIC_VECTOR (7 downto 0)
           );
    end component;
    
   
begin
--D2: decoder8to256
--    port map(
--            a => Z_dec,
--            b => Z_temp
--            );
--E2: encoder256to8
--    port map(
--            b => S_temp,
--            a => s_enc
--            );

P5: process(clk, reset)
    begin
        if(reset='1') then
            current_state2 <= reset2;          
        elsif(clk'event and clk='1') then
            current_state2 <= next_state2;
        end if;
    end process;
 pBs:
    process(clk,lib_read)
    begin
      if rising_edge(clk) then
        if (lib_read = '1') then
           lib_output<= lib(lib_index);
        end if;
    
        --data_out <= lib_b(read_address);
      end if;
    end process;   
  -- LFSR process to generate random numbers
--P2: process(clk, reset)
--    begin
--        if reset = '1' then
--            lfsr <= x"BBBBACE1";  -- Reset the LFSR to its seed value
--        elsif rising_edge(clk) then
--            -- Update the LFSR using XOR feedback (example for a 32-bit LFSR)
--            lfsr <= lfsr(30 downto 0) & (lfsr(31) xor lfsr(21) xor lfsr(1) xor lfsr(0));  
--        end if;
--    end process;
   c0<=c0_seed; 
P6: process(clk, reset, current_state2, start)
    begin
        if reset = '1' then
            counterN<=0;
            match_lib<='0';
            checkPass <='0';
            ready_output<='0';
        elsif rising_edge(clk) then
            case current_state2 is
                when reset2 =>
                    data_ready_signal <= '0';
                    ready_output<='0';
                    counterN<=0;
                    counterB<=0;
                    lib_read<='0';
                    --k<=0;
                when idle =>
                    if start = '1' then
                        msg_block_signal(lambda-1 downto 0) <= c0;  -- Assume c0 is provided externally or generated
                        data_ready_signal <= '1';
                        ready_output<='0';
                    else
                        data_ready_signal <= '0';
                        ready_output<='0';
                    end if;
                when computeP0 =>
                    if hash_finished='1' then
                        r_i<=hash_output_signal;
                    end if;
                when checkN =>
                    if counterN< (N_int +1) then
                        counterN<=counterN+1;
                        lib_index<=counterN;
                        lib_read<='1';
                    
                    end if;
                    counterB<=0;
                    checkPass <='0';
                when checkB =>
                    if counterB< (B_int +1) then
                        
                        ci <= to_unsigned(counterB,lambda)+unsigned(r_i);
                        counterB<=counterB+1;
                    end if;
                    checkPass <='0';
                    lib_read<='0';
                when computeCi =>
                    
                    msg_block_signal(lambda-1 downto 0)<= std_logic_vector(ci);
                     
                    data_ready_signal <= '1';
                    match_lib<='0';
                    lib_read<='1';
                when wait2 =>
                    if hash_finished='1' then
                        r_i<=hash_output_signal;
                        data_ready_signal <= '1';
                        
                    else
                        data_ready_signal <= '0';
                        
                    end if;
                when checkHelper =>
                    data_ready_signal <= '0';
                    --if r_i=lib((counterN+1)*(lambda)-1 downto (counterN)*(lambda))then
                    
                    --if r_i=lib(counterN-1) then
                    if r_i=lib_output then
                        match_lib<='1';
                    else
                        match_lib<='0';
                    end if;
                    lib_read<='0';
                    checkPass <='1';
                when checkL =>
                    rN_i<=to_unsigned(counterL, lambda)+unsigned(r_i);
                    msg_block_signal(lambda-1 downto 0)<=std_logic_vector(rN_i);
                    data_ready_signal<= '1';
                    lib_read<='0';    
                when computeXOR =>
                    if hash_finished = '1' then
                        
                        Si<=hash_output_signal xor Z((counterL+1)*(lambda)-1 downto (counterL)*(lambda));
                        S((counterL+1)*(lambda)-1 downto (counterL)*(lambda))<= Si;

                        counterL<=counterL+1;
                    end if;
                when done2 =>
                    ready_output<='1';
             end case;
        end if;
    end process;
 
 
 -- State machine for managing the hashing process
P7: process(current_state2, reset, start, hash_finished, counterN, counterB, match_lib, checkPass, ready_gen)
    begin
            case current_state2 is
                when reset2 =>
                    if(reset='1') then
                        next_state2 <= reset2;
                    elsif ready_gen='1' then
                        next_state2 <= idle;
                    else
                        next_state2 <= reset2;
                    end if;

                when idle =>
                    if start = '1' then
                        next_state2 <= computeP0;
                    else
                        next_state2<= idle;
                    end if;
                when computeP0 =>
                    if hash_finished='1' then
                        next_state2 <= checkN;
                    else
                        next_state2 <= computeP0;
                    end if;
                    
                when checkN =>
                    if counterN< (N_int +1) then
                        next_state2 <=checkB;
                    else
                        next_state2 <=checkL;
                    end if;
                    --K<=1;
                when checkB =>
                    if counterB< (B_int +1) then
                        next_state2 <=computeCi;
                    else
                        next_state2 <=checkN;
                    end if;
                
                when computeCi =>
                    next_state2<= wait2;
                when wait2 =>
                    if hash_finished='1' then
                        next_state2 <= checkHelper;
                    else
                        next_state2<= wait2;
                    end if;  

                 when checkHelper =>
                    if    match_lib='1' and checkPass='1' then
                        next_state2 <= checkN;
                    elsif match_lib='0' and checkPass='1' then
                        next_state2 <= checkB;
                    else
                        next_state2 <= checkHelper;
                    end if; 
                                  
                when checkL =>
                    if counterL<L-1 then
                        next_state2 <=computeXOR;
                    else
                        next_state2 <=done2;
                    end if;
                when computeXOR =>
                    next_state2 <=checkL;
                when done2 =>
                     next_state2 <=done2;
                when others =>
                    next_state2 <= idle;
            end case;

    end process;
N_int<=to_integer(unsigned(N)); 
B_int<=to_integer(unsigned(B));  
data_ready <= data_ready_signal;
rst_n<= not reset; 

-- Instantiate the SHA-256 core
sha256_core_inst_solve : entity work.sha_256_core
    generic map (
        RESET_VALUE => '0'
    )
    port map (
        clk           => clk,                  -- Clock signal
        rst           => rst_n,           -- Reset signal
        data_ready    => data_ready,    -- Start the hashing process
        n_blocks      => n_blocks_signal,      -- Number of 512-bit blocks
        msg_block_in  => msg_block,     -- 512-bit input message
        finished      => hash_finished,        -- Indication that the hash is complete
        data_out      => hash_output_signal    -- 256-bit hash output
    );
end Behavioral;
