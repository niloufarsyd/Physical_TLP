

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
-- Define a type for an array of n-bit vectors

--type vector_array is array (natural range <>) of std_logic_vector(m-1 downto 0);

entity puz_gen is
--    generic (
--        L : integer := DEFAULT_L;  -- Number of vectors --- WAS 16
--        MAX_N :integer := MAX_N;
        
--        --m : integer := 256;   -- Number of bits in each vector
--        lambda : integer := LAMBDA  -- Default value or specify as needed
        
--    );
    generic (
        L : integer := 1;  -- Number of vectors --- WAS 16
        MAX_N :integer := 300;
        
        --m : integer := 256;   -- Number of bits in each vector
        lambda : integer := 256  -- Default value or specify as needed
        
    );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           t : in STD_LOGIC_VECTOR (31 downto 0);
           s : in STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0);
           start    : in  std_logic;
           e  : in  std_logic_vector(31 downto 0);  -- Example bit width
           tc  : in  std_logic_vector(31 downto 0);
           h : in STD_LOGIC_VECTOR (7 downto 0);
           c0_seed : out STD_LOGIC_VECTOR (lambda-1 downto 0);
           N : out STD_LOGIC_VECTOR (7 downto 0);
           B : out STD_LOGIC_VECTOR (7 downto 0);
           Helper_index: out integer;
           Z : out STD_LOGIC_VECTOR (L*lambda-1 downto 0);
           lib : out bram_type;
           --lib : out STD_LOGIC_VECTOR ((MAX_N*lambda)-1 downto 0);
           ready_output    : out std_logic
           );
end puz_gen;

architecture Behavioral of puz_gen is
    -- Internal signals
    --type bram_type is array (0 to MAX_N-1) of std_logic_vector(lambda-1 downto 0);

    signal r_n, r_b, r_n2 : integer:= 0;
    signal hash_output    : std_logic_vector(lambda-1 downto 0); -- Assuming 256-bit hash output
    signal counter        : integer := 0;
    signal h_int          : integer := 0;
    signal tc_int         : integer := 0;
    signal e_int          : integer := 0;
    signal t_int          : integer := 0;
    signal c0             :  STD_LOGIC_VECTOR (lambda-1 downto 0):= x"0D0000000000000000000000000000000000000000000000000000000000ACE3";
    constant scaleT       : integer := 1000; --scale tc from ps to ns

    type state_type1 is (reset1, initial, idle1, computeP1, computeCi, checkN, computeRn, computeP3, computeXOR, checkL, done1);
    signal current_state1, next_state1 : state_type1 := reset1;  -- Initialize to idle state   
    --signal s                  : std_logic_vector(lambda-1 downto 0);--related to decoder
    signal Zi                  : std_logic_vector(lambda-1 downto 0):= (others => '0');--related to decoder
    signal PUZ                : std_logic_vector((L*lambda)-1 downto 0):= (others => '0');
    signal hash_output_signal : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash
    signal lib_input             : std_logic_vector(lambda-1 downto 0):= (others => '0');
    signal lib_index          :integer:=0;
    signal write_lib    :std_logic:= '0';
    signal hash_finished      : std_logic:= '0';                      -- Indicates when hashing is done
    signal data_ready         : std_logic := '0';                      -- Trigger for starting the hashing
    signal data_ready_signal  : std_logic := '0';               -- 
    signal n_blocks_signal    : natural := 1;                   -- Assuming 1 block of data, adjust as needed
    signal msg_block          : std_logic_vector(2*lambda-1 downto 0):= (others => '0'); -- Message input for SHA-256, 512 bits
    signal msg_block_signal   : std_logic_vector(2*lambda-1 downto 0):= (others => '0'); -- Message input for SHA-256, 512 bits
    signal rst_signal         : std_logic := '0';               -- Reset signal for the core
    signal H_data : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- Helper
    signal rst_n : std_logic;
    signal lfsr       : std_logic_vector(31 downto 0) := x"0000ACE1";  -- Initial seed for the LFSR
    signal random_val : integer:= 0;
    signal k          : integer:= 0;
    --signal ci         : integer:= 0;
    --signal ci         : unsigned  (lambda-1 downto 0):= (others => '0');
    signal ci              :  STD_LOGIC_VECTOR (lambda-1 downto 0):=(others => '0');
    --constant MAX_N : integer := 1000; -- Example maximum N value
 
    signal counter2        : integer := 0;
    signal L_bound        : integer := 0;
    --signal r        : integer := 0;
    signal r         :unsigned(lambda-1 downto 0);
    signal L_check    : std_logic := '0';
    signal ready      : std_logic := '0';
    signal pass_idle  : std_logic := '0';
    
    
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
--D1: decoder8to256
--    port map(
--            a => s_dec,
--            b => s
--            );
--E1: encoder256to8
--    port map(
--            b => Z,
--            a => Z_enc
--            );
    --current state logic
P1: process(clk, reset)
    begin
        if(reset='1') then
            current_state1 <= reset1;
            --current_state2 <= reset2;
        elsif(clk'event and clk='1') then
            current_state1 <= next_state1;
            --current_state2 <= next_state2;
        end if;
    end process;
    
  -- LFSR process to generate random numbers
P2: process(clk, reset)
    begin
        if reset = '1' then
            lfsr <= x"BBBBACE1";  -- Reset the LFSR to its seed value
        elsif rising_edge(clk) then
            -- Update the LFSR using XOR feedback (example for a 32-bit LFSR)
            lfsr <= lfsr(30 downto 0) & (lfsr(31) xor lfsr(21) xor lfsr(1) xor lfsr(0));  
        end if;
    end process;
pB:
    process(clk,write_lib)
    begin
      if rising_edge(clk) then
        if (write_lib = '1') then
          lib(lib_index) <= lib_input;
        end if;
    
        --data_out <= lib_b(read_address);
      end if;
    end process;

P3: process(clk, reset, current_state1, start)
    begin
        if reset = '1' then
            --current_state1 <= idle1;
            counter <= 0;
            ready <= '0';
            --appended_hash_output <= (others => '0'); -- Clear signal on reset
            data_ready_signal <= '0'; --related to sha256
        elsif rising_edge(clk) then
            case current_state1 is
                when reset1 =>
                    data_ready_signal <= '0';
                    counter <= 0;
                    counter2<= 0;
                    ready<='0';
                    write_lib <='0';
                when initial =>
                    h_int <= to_integer(unsigned(h));
                    tc_int<= to_integer(unsigned(tc));
                    t_int <= to_integer(unsigned(t));
                    e_int <= to_integer(unsigned(e));
                    --pass_idle<='1';
                when idle1 =>
                    
                    if start = '1' and e_int /= 0 and h_int/=0 and t_int/=0 and tc_int/=0 then
                        -- Initialize variables and start computation
                        --r_n <= to_integer(unsigned((4 * unsigned(h)*unsigned(h) * unsigned(t)*unsigned(t)) / (3 * unsigned(e)*unsigned(e))));
                        r_n <= (4 * (h_int**2) * (t_int**2)) / (3 * (e_int)**2);
                        
                        --r_b <= to_integer(unsigned((3 * unsigned(e)*unsigned(e)) / (2 * unsigned(h)*unsigned(h) * unsigned(t) * unsigned(tc))));
                        r_b <= (3 * (e_int**2)*scaleT) / (2 * (h_int**2) * t_int * tc_int);
                        msg_block_signal(lambda-1 downto 0) <= c0;  -- Assume c0 is provided externally or generated
                        data_ready_signal <= '1';  -- Trigger the hashing process
                        pass_idle<='1';
                    else
                        pass_idle<='0';
                    end if;
                    write_lib <='0';
                when computeP1 =>
                    if hash_finished = '1' then                       
                        -- Compute the hash for current input                      
                        hash_output <= hash_output_signal;  -- Capture the hash output when finished                      
                        --appended_hash_output(lambda*(counter+1)-1 downto lambda*counter) <= hash_output_signal;
                        write_lib <='1';
                        lib_input<=hash_output_signal;
                        lib_index<=counter;
                        ---if r_b >=256
                        --k <= to_integer(unsigned(lfsr(15 downto 0))) mod (r_b);  -- Scale the LFSR output
                        ---if r_b <256
                        k <= to_integer(unsigned(lfsr(7 downto 0))) mod (r_b);  -- Scale the LFSR output
                        -- Prepare next input
                        counter <= counter + 1;
                        data_ready_signal<= '1';
                    else
                        data_ready_signal<= '0';
                        pass_idle<='0';
                        write_lib <='0';
                    end if;
                when computeCi =>
                    write_lib <='0';
                    ci<= std_logic_vector(to_unsigned(k, lambda)+unsigned(hash_output));
                when CheckN =>
                    if counter < (r_n)+1 then

                        --ci <= k+to_integer(unsigned(hash_output));
                        --ci<=to_unsigned(k, lambda)+unsigned(hash_output);--just to see the result
                        --ci<= std_logic_vector(to_unsigned(k, lambda)+unsigned(hash_output));
                        --msg_block_signal(lambda-1 downto 0) <= std_logic_vector(to_unsigned((k+to_integer(unsigned(hash_output))), lambda));
                        msg_block_signal(lambda-1 downto 0) <= ci;                        
                        data_ready_signal<= '1';                        
                     else
                        
                        data_ready_signal<= '0';
                        Helper_index<=counter;
                        counter<=0;   
                     end if;
                when computeRn =>
                    --r<=counter2+to_integer(unsigned(hash_output));
                    r<=to_unsigned(counter2, lambda)+unsigned(hash_output);
                when computeP3 =>
                    --r<=counter2+to_integer(unsigned(hash_output));
                    msg_block_signal(lambda-1 downto 0)<=std_logic_vector(r);
                    data_ready_signal<= '1';

                 when computeXOR =>
                    if hash_finished = '1' then
                        Z((counter2+1)*(lambda)-1 downto (counter2)*(lambda))<=hash_output_signal xor s((counter2+1)*(lambda)-1 downto (counter2)*(lambda));
                        L_bound<=L-1;
        
                        
                    end if;
                 when checkL =>
                    if counter2 < L_bound then
                        L_check<='0';
                        counter2<=counter2+1;
                    else
                        L_check<='1';
                    end if;
                    data_ready_signal<= '0';
                when done1 =>
                    ready <= '1'; -- Indicate computation is done
            end case;
        end if;
    end process;
 -- State machine for managing the hashing process
P4: process(current_state1, reset, start, hash_finished, counter, pass_idle)
    begin
            case current_state1 is
                when reset1 =>
                    if(reset='1') then
                        next_state1 <= reset1;
                    else
                        next_state1 <= initial;
                    end if;
                when initial =>
                    next_state1<= idle1;
                when idle1 =>
                    if start = '1' and pass_idle='1' then
                        next_state1 <= computeP1;
                    else
                        next_state1<= idle1;
                    end if;
                when computeP1 =>
                    if hash_finished = '1' then                       
                        next_state1 <= computeCi;
                    else
                        next_state1 <= computeP1;
                    end if;  
                when computeCi =>
                    next_state1 <= CheckN;
                when CheckN =>
                    if counter < (r_n)+1 then                       
                        next_state1 <= computeP1;
                     else
                        next_state1<=computeRn; 
                     end if;
                when computeRn =>
                    next_state1<=computeP3;
                when computeP3 =>                  
                    next_state1<= computeXOR;                    
                when computeXOR =>
                    if hash_finished = '1' then
                        next_state1<=checkL;
                    else
                        next_state1 <= computeXOR;
                    end if;
                 when checkL =>
                    if counter2 < (L-1) then
                        next_state1 <=computeRn;
                    else
                        next_state1 <= done1;
                    end if;              
                when done1 =>
                    next_state1 <=done1;
                when others =>
                    next_state1 <= idle1;
            end case;

    end process;

     ready_output<=ready; 
     data_ready<=data_ready_signal;  
     msg_block<=msg_block_signal;
     c0_seed <= c0; --uncomment it later
     N<=std_logic_vector(to_unsigned(r_n, 8));
     B<=std_logic_vector(to_unsigned(r_b, 8));
     rst_n <= not reset;
-- Instantiate the SHA-256 core
sha256_core_inst : entity work.sha_256_core
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





------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date: 09/13/2024 03:07:15 PM
---- Design Name: 
---- Module Name: puz_gen - Behavioral
---- Project Name: 
---- Target Devices: 
---- Tool Versions: 
---- Description: 
---- 
---- Dependencies: 
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
------------------------------------------------------------------------------------


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;


---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;
---- Define a type for an array of n-bit vectors

----type vector_array is array (natural range <>) of std_logic_vector(m-1 downto 0);

--entity puz_gen is
--    generic (
--        L : integer := 1;  -- Number of vectors --- WAS 16
--        MAX_N :integer := 1000;
--        --m : integer := 256;   -- Number of bits in each vector
--        lambda : integer := 256  -- Default value or specify as needed
--    );
--    Port ( clk : in STD_LOGIC;
--           reset : in STD_LOGIC;
--           t : in STD_LOGIC_VECTOR (31 downto 0);
--           s_dec : in STD_LOGIC_VECTOR (7 downto 0);
--           --s : in STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0);
--           --S : in vector_array(0 to L-1);
--           start    : in  std_logic;
--           e  : in  std_logic_vector(31 downto 0);  -- Example bit width
--           tc  : in  std_logic_vector(31 downto 0);
--           h : in STD_LOGIC_VECTOR (7 downto 0);
--           --c0_seed : out STD_LOGIC_VECTOR (lambda-1 downto 0);
--           N : out STD_LOGIC_VECTOR (7 downto 0);
--           B : out STD_LOGIC_VECTOR (7 downto 0);
--           Z_enc : out STD_LOGIC_VECTOR (7 downto 0);
--           Z_lsb: out std_logic;
--           Helper_index: out integer;
--           --Z : out STD_LOGIC_VECTOR (L*lambda-1 downto 0);
--           --lib : out STD_LOGIC_VECTOR ((MAX_N*lambda)-1 downto 0);
--           ready_output    : out std_logic
--           );
--end puz_gen;

--architecture Behavioral of puz_gen is
--    -- Internal signals
--    signal r_n, r_b, r_n2 : integer:= 0;
--    signal hash_output    : std_logic_vector(lambda-1 downto 0); -- Assuming 256-bit hash output
--    signal counter        : integer := 0;
--    signal h_int          : integer := 0;
--    signal tc_int         : integer := 0;
--    signal e_int          : integer := 0;
--    signal t_int          : integer := 0;
--    signal c0             :  STD_LOGIC_VECTOR (lambda-1 downto 0):= x"0D0000000000000000000000000000000000000000000000000000000000ACE3";
--    constant scaleT       : integer := 1000; --scale tc from ps to ns

--    type state_type1 is (reset1, initial, idle1, computeP1, checkN, computeP3, computeXOR, checkL, done1);
--    signal current_state1, next_state1 : state_type1 := reset1;  -- Initialize to idle state   
--    signal s                  : std_logic_vector(lambda-1 downto 0);--related to decoder
--    signal Z                  : std_logic_vector(lambda-1 downto 0):= (others => '0');--related to decoder
--    signal PUZ                : std_logic_vector((L*lambda)-1 downto 0):= (others => '0');
--    signal hash_output_signal : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash
--    signal hash_finished      : std_logic:= '0';                      -- Indicates when hashing is done
--    signal data_ready         : std_logic := '0';                      -- Trigger for starting the hashing
--    signal data_ready_signal  : std_logic := '0';               -- 
--    signal n_blocks_signal    : natural := 1;                   -- Assuming 1 block of data, adjust as needed
--    signal msg_block          : std_logic_vector(2*lambda-1 downto 0):= (others => '0'); -- Message input for SHA-256, 512 bits
--    signal msg_block_signal   : std_logic_vector(2*lambda-1 downto 0):= (others => '0'); -- Message input for SHA-256, 512 bits
--    signal rst_signal         : std_logic := '0';               -- Reset signal for the core
--    signal H_data : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- Helper
--    signal rst_n : std_logic;
--    signal lfsr       : std_logic_vector(31 downto 0) := x"0000ACE1";  -- Initial seed for the LFSR
--    signal random_val : integer:= 0;
--    signal k          : integer:= 0;
--    signal ci         : integer:= 0;
    
--    --constant MAX_N : integer := 1000; -- Example maximum N value
--    signal appended_hash_output : std_logic_vector((MAX_N * lambda) - 1 downto 0); -- Large enough to hold MAX_N hashes
 
--    signal counter2        : integer := 0;
--    signal r        : integer := 0;
--    signal L_check    : std_logic := '0';
--    signal ready      : std_logic := '0';
--    signal pass_idle  : std_logic := '0';
    
--    component decoder8to256 is
--    Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
--           b : out STD_LOGIC_VECTOR (255 downto 0)
--           );
--    end component;
--    component encoder256to8 is
--    Port ( b : in STD_LOGIC_VECTOR (255 downto 0);
--           a : out STD_LOGIC_VECTOR (7 downto 0)
--           );
--    end component;
--begin
--D1: decoder8to256
--    port map(
--            a => s_dec,
--            b => s
--            );
--E1: encoder256to8
--    port map(
--            b => Z,
--            a => Z_enc
--            );
--    --current state logic
--P1: process(clk, reset)
--    begin
--        if(reset='1') then
--            current_state1 <= reset1;
--            --current_state2 <= reset2;
--        elsif(clk'event and clk='1') then
--            current_state1 <= next_state1;
--            --current_state2 <= next_state2;
--        end if;
--    end process;
    
--  -- LFSR process to generate random numbers
--P2: process(clk, reset)
--    begin
--        if reset = '1' then
--            lfsr <= x"BBBBACE1";  -- Reset the LFSR to its seed value
--        elsif rising_edge(clk) then
--            -- Update the LFSR using XOR feedback (example for a 32-bit LFSR)
--            lfsr <= lfsr(30 downto 0) & (lfsr(31) xor lfsr(21) xor lfsr(1) xor lfsr(0));  
--        end if;
--    end process;

--P3: process(clk, reset, current_state1, start)
--    begin
--        if reset = '1' then
--            --current_state1 <= idle1;
--            counter <= 0;
--            ready <= '0';
--            appended_hash_output <= (others => '0'); -- Clear signal on reset
--            data_ready_signal <= '0'; --related to sha256
--        elsif rising_edge(clk) then
--            case current_state1 is
--                when reset1 =>
--                    data_ready_signal <= '0';
--                    counter <= 0;
--                    counter2<= 0;
--                    ready<='0';
                    
--                when initial =>
--                    h_int <= to_integer(unsigned(h));
--                    tc_int<= to_integer(unsigned(tc));
--                    t_int <= to_integer(unsigned(t));
--                    e_int <= to_integer(unsigned(e));
--                    --pass_idle<='1';
--                when idle1 =>
                    
--                    if start = '1' and e_int /= 0 and h_int/=0 and t_int/=0 and tc_int/=0 then
--                        -- Initialize variables and start computation
--                        --r_n <= to_integer(unsigned((4 * unsigned(h)*unsigned(h) * unsigned(t)*unsigned(t)) / (3 * unsigned(e)*unsigned(e))));
--                        r_n <= (4 * (h_int**2) * (t_int**2)) / (3 * (e_int)**2);
                        
--                        --r_b <= to_integer(unsigned((3 * unsigned(e)*unsigned(e)) / (2 * unsigned(h)*unsigned(h) * unsigned(t) * unsigned(tc))));
--                        r_b <= (3 * (e_int**2)*scaleT) / (2 * (h_int**2) * t_int * tc_int);
--                        msg_block_signal(lambda-1 downto 0) <= c0;  -- Assume c0 is provided externally or generated
--                        data_ready_signal <= '1';  -- Trigger the hashing process
--                        pass_idle<='1';
--                    else
--                        pass_idle<='0';
--                    end if;
--                when computeP1 =>
--                    if hash_finished = '1' then                       
--                        -- Compute the hash for current input                      
--                        hash_output <= hash_output_signal;  -- Capture the hash output when finished                      
--                        appended_hash_output(lambda*(counter+1)-1 downto lambda*counter) <= hash_output_signal;
--                        ---if r_b >=256
--                        --k <= to_integer(unsigned(lfsr(15 downto 0))) mod (r_b);  -- Scale the LFSR output
--                        ---if r_b <256
--                        k <= to_integer(unsigned(lfsr(7 downto 0))) mod (r_b);  -- Scale the LFSR output
--                        -- Prepare next input
--                        counter <= counter + 1;
--                        data_ready_signal<= '1';
--                    else
--                        data_ready_signal<= '0';
--                        pass_idle<='0';
--                    end if;

--                when CheckN =>
--                    if counter < (r_n)-1 then
--                          -- Assign random value to k
--                        ci <= k+to_integer(unsigned(hash_output));
--                        msg_block_signal(lambda-1 downto 0) <= std_logic_vector(to_unsigned(ci, lambda));
--                        data_ready_signal<= '1';                        
--                     else
--                        data_ready_signal<= '0';
--                        Helper_index<=counter;
--                        counter<=0;   
--                     end if;
--                when computeP3 =>
--                    r<=counter2+to_integer(unsigned(hash_output));
--                    msg_block_signal(lambda-1 downto 0)<=std_logic_vector(to_unsigned(r, lambda));
--                    data_ready_signal<= '1';

--                 when computeXOR =>
--                    if hash_finished = '1' then
--                        Z<=hash_output_signal xor s((counter2+1)*(lambda)-1 downto (counter2)*(lambda));
--                        PUZ((counter2+1)*(lambda)-1 downto (counter2)*(lambda))<=Z;
----                        Z(255 downto 0)<=hash_output_signal xor s(255 downto 0);
----                        PUZ(255 downto 0)<=Z;
--                        counter2<=counter2+1;
--                    end if;
--                 when checkL =>
--                    if counter2 < L then
--                        L_check<='0';
--                    else
--                        L_check<='1';
--                    end if;
--                    data_ready_signal<= '0';
--                when done1 =>
--                    ready <= '1'; -- Indicate computation is done
--            end case;
--        end if;
--    end process;
-- -- State machine for managing the hashing process
--P4: process(current_state1, reset, start, hash_finished, counter, pass_idle)
--    begin
--            case current_state1 is
--                when reset1 =>
--                    if(reset='1') then
--                        next_state1 <= reset1;
--                    else
--                        next_state1 <= initial;
--                    end if;
--                when initial =>
--                    next_state1<= idle1;
--                when idle1 =>
--                    if start = '1' and pass_idle='1' then
--                        next_state1 <= computeP1;
--                    else
--                        next_state1<= idle1;
--                    end if;
--                when computeP1 =>
--                    if hash_finished = '1' then                       
--                        next_state1 <= CheckN;
--                    else
--                        next_state1 <= computeP1;
--                    end if;  
--                when CheckN =>
--                    if counter < (r_n)-1 then                       
--                        next_state1 <= computeP1;
--                     else
--                        next_state1<=computeP3; 
--                     end if;
--                when computeP3 =>                  
--                    next_state1<= computeXOR;                    
--                when computeXOR =>
--                    if hash_finished = '1' then
--                        next_state1<=checkL;
--                    else
--                        next_state1 <= computeXOR;
--                    end if;
--                 when checkL =>
--                    if counter2 < L then
--                        next_state1 <=computeP3;
--                    else
--                        next_state1 <= done1;
--                    end if;              
--                when done1 =>
--                    next_state1 <=done1;
--                when others =>
--                    next_state1 <= idle1;
--            end case;

--    end process;
--    -- lib <=appended_hash_output;
--     Z_lsb<= Z(0);
--     ready_output<=ready; 
--     data_ready<=data_ready_signal;  
--     msg_block<=msg_block_signal;
--     --c0_seed <= c0; --uncomment it later
--     N<=std_logic_vector(to_unsigned(r_n, 8));
--     B<=std_logic_vector(to_unsigned(r_b, 8));
--     rst_n <= not reset;
---- Instantiate the SHA-256 core
--sha256_core_inst : entity work.sha_256_core
--    generic map (
--        RESET_VALUE => '0'
--    )
--    port map (
--        clk           => clk,                  -- Clock signal
--        rst           => rst_n,           -- Reset signal
--        data_ready    => data_ready,    -- Start the hashing process
--        n_blocks      => n_blocks_signal,      -- Number of 512-bit blocks
--        msg_block_in  => msg_block,     -- 512-bit input message
--        finished      => hash_finished,        -- Indication that the hash is complete
--        data_out      => hash_output_signal    -- 256-bit hash output
--    );
--end Behavioral;


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/13/2024 03:07:15 PM
-- Design Name: 
-- Module Name: puz_gen - Behavioral
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
