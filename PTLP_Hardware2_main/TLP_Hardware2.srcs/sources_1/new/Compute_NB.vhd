----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2024 12:56:28 PM
-- Design Name: 
-- Module Name: Gen_Sol - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.my_constants.all;  -- Import the package
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Gen_Sol is
    generic (
        L : integer := 1;  -- Number of vectors --- WAS 16
        MAX_N :integer := 300;
        lambda : integer := 256  -- Default value or specify as needed
        
    );
    Port ( start_gen : in STD_LOGIC;
           start_sol : in STD_LOGIC;
           clk   : in STD_LOGIC;
           reset : in STD_LOGIC;
           --rs : in STD_LOGIC;
           t : in STD_LOGIC_VECTOR (31 downto 0);
           --s : in STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0);
           e : in STD_LOGIC_VECTOR(31 downto 0);  -- Example bit width
           tc: in STD_LOGIC_VECTOR(31 downto 0);
           h : in STD_LOGIC_VECTOR (7 downto 0);
           s_solution : out STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0);
           s_solved : out STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0);
           gen_done : out STD_LOGIC;
           sol_done : out STD_LOGIC);
end Gen_Sol;

architecture Behavioral of Gen_Sol is
    
    signal s        : std_logic_vector((L*lambda)-1 downto 0):= (others => '1');

    signal lib            : bram_type;
    signal r_n, r_b, r_n2 : integer:= 0;
    signal hash_output    : std_logic_vector(lambda-1 downto 0); -- Assuming 256-bit hash output
    signal counter        : integer := 0;
    signal h_int          : integer := 0;
    signal tc_int         : integer := 0;
    signal e_int          : integer := 0;
    signal t_int          : integer := 0;
    signal c0             : STD_LOGIC_VECTOR (lambda-1 downto 0):= x"0D0000000000000000000000000000000000000000000000000000000000ACE3";
    constant scaleT       : integer := 1000; --scale tc from ps to ns

    type state_type1 is (reset1, initial, idle1,  computeP1, computeCi, checkN, computeRn, computeP3, computeXOR, checkL, done1);
    signal current_state1, next_state1 : state_type1 := reset1;  -- Initialize to idle state   
    type state_type2 is (reset2, idle2, computeP0, checkN, checkB, computeCi2, wait2, checkHelper, checkL,computeXOR2,done2);
    signal current_state2, next_state2 : state_type2 := reset2;  -- Initialize to idle state 
    
    signal Zi                 : std_logic_vector(lambda-1 downto 0):= (others => '0');--related to decoder
    signal hash_output_signal : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash
    signal lib_input          : std_logic_vector(lambda-1 downto 0):= (others => '0');
    signal lib_index1          : integer:=0;
    signal lib_index2          : integer:=0;
    signal write_lib          : std_logic:= '0';
    signal hash_finished      : std_logic:= '0';                      -- Indicates when hashing is done
    signal data_ready         : std_logic := '0';                      -- Trigger for starting the hashing
    signal data_ready_signal1  : std_logic := '0';
    signal data_ready_signal2  : std_logic := '0';               -- 
    signal n_blocks_signal    : natural := 1;                   -- Assuming 1 block of data, adjust as needed
    signal msg_block          : std_logic_vector(2*lambda-1 downto 0):= (others => '0'); -- Message input for SHA-256, 512 bits
    signal msg_block_signal1   : std_logic_vector(2*lambda-1 downto 0):= (others => '0'); -- Message input for SHA-256, 512 bits
    signal msg_block_signal2   : std_logic_vector(2*lambda-1 downto 0):= (others => '0'); -- Message input for SHA-256, 512 bits
    
    signal rst_signal         : std_logic := '0';               -- Reset signal for the core
    signal H_data : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- Helper
    signal rst_n  : std_logic;
    signal lfsr         : std_logic_vector(31 downto 0) := x"0000ACE1";  -- Initial seed for the LFSR
    signal random_val   : integer:= 0;
    signal k            : integer:= 0;
    signal ci           : STD_LOGIC_VECTOR (lambda-1 downto 0):=(others => '0');
    signal Helper_index : integer;
    signal counter2     : integer := 0;
    signal L_bound      : integer := 0;
    signal r            : unsigned(lambda-1 downto 0);
    signal L_check      : std_logic := '0';
    signal ready_Gen    : std_logic := '0';
    signal pass_idle    : std_logic := '0';
    signal Z            : STD_LOGIC_VECTOR (L*lambda-1 downto 0);
    signal N :  STD_LOGIC_VECTOR (7 downto 0);
    signal B :  STD_LOGIC_VECTOR (7 downto 0);
    signal lib_output : std_logic_vector(lambda-1 downto 0):= (others => '0');   
    signal lib_read   : std_logic:= '0';    
    signal ri        : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash
    signal ri_1        : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash
    
    signal Si         : std_logic_vector(lambda-1 downto 0):= (others => '0'); -- 256-bit output for hash    
    signal counterN   : integer :=1;
    signal counterB   : integer :=0;
    signal counterL   : integer :=0;
    signal rN_i       : unsigned(lambda-1 downto 0);
    signal N_int      : integer :=0;
    signal B_int      : integer :=0;
    signal match_lib  : std_logic := '0';
    signal checkPass  : std_logic := '0';
    signal start_sol_confirmed: std_logic := '0';
    signal sol_done2  : STD_LOGIC :='0';
    signal ci_s       : unsigned  (lambda-1 downto 0):= (others => '0');
    signal checkk_c0   : STD_LOGIC :='0';
    --signal rs1, rs2   : STD_LOGIC :='0';
    signal lib_output_flag : STD_LOGIC :='0'; 
    --signal s_solved   : STD_LOGIC_VECTOR ((L * lambda) - 1 downto 0):=(others => '0');
begin

P1: process(clk, reset)
    begin
        if(reset='1') then
            current_state1 <= reset1;
        elsif(clk'event and clk='1') then
            current_state1 <= next_state1;
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
          lib(lib_index1) <= lib_input;
        end if;
      end if;
    end process;
 pBs:
    process(clk,lib_read)
    begin
      if rising_edge(clk) then
        if (lib_read = '1') then
           lib_output<= lib(lib_index2);
           lib_output_flag<= '1';
        else
            lib_output_flag<= '0';
        end if;
      end if;
    end process;
    
P3: process(clk, reset, current_state1, start_gen)
    begin
        if reset = '1' then
            counter <= 0;
            ready_Gen <= '0';
            data_ready_signal1 <= '0'; --related to sha256
        elsif rising_edge(clk) then
            case current_state1 is
                when reset1 =>
                    data_ready_signal1 <= '0';
                    counter <= 0;
                    counter2<= 0;
                    ready_Gen<='0';
                    write_lib <='0';
                when initial =>
                    h_int <= to_integer(unsigned(h));
                    tc_int<= to_integer(unsigned(tc));
                    t_int <= to_integer(unsigned(t));
                    e_int <= to_integer(unsigned(e));
--                when HashReset1 =>
--                    rs1<='1';
--                when HashSet1 =>
--                    rs1<='0';
                when idle1 =>
                    
                    if start_gen = '1' and e_int /= 0 and h_int/=0 and t_int/=0 and tc_int/=0 then
                        r_n <= (4 * (h_int**2) * (t_int**2)) / (3 * (e_int)**2);                       
                        r_b <= (3 * (e_int**2)*scaleT) / (2 * (h_int**2) * t_int * tc_int);
                        msg_block_signal1(lambda-1 downto 0) <= c0;  -- Assume c0 is provided externally or generated
                        data_ready_signal1 <= '1';  -- Trigger the hashing process
                        pass_idle<='1';
                    else
                        pass_idle<='0';
                    end if;
                    write_lib <='0';
                when computeP1 =>
                    if hash_finished = '1' then                                             
                        hash_output <= hash_output_signal;  -- Capture the hash output when finished                      
                        write_lib <='1';
                        lib_input<=hash_output_signal;
                        lib_index1<=counter;
                        k <= to_integer(unsigned(lfsr(7 downto 0))) mod (r_b);  -- Scale the LFSR output
                        counter <= counter + 1;
                        data_ready_signal1<= '1';
                    else
                        data_ready_signal1<= '0';
                        pass_idle<='0';
                        write_lib <='0';
                    end if;
                when computeCi =>
                    write_lib <='0';
                    --rs1<='1';
                    ci<= std_logic_vector(to_unsigned(k, lambda)+unsigned(hash_output));
                when CheckN =>
                    if counter < (r_n)+1 then
                        --rs1<='0';                     
                        msg_block_signal1(lambda-1 downto 0) <= ci;                        
                        data_ready_signal1<= '1';                        
                     else                        
                        data_ready_signal1<= '0';
                        Helper_index<=counter;
                        counter<=0;
                        --rs1<='1';   
                     end if;
                when computeRn =>                   
                    r<=to_unsigned(counter2, lambda)+unsigned(hash_output);
                    --rs1<='1';
                when computeP3 =>
                    --rs1<='0';
                    msg_block_signal1(lambda-1 downto 0)<=std_logic_vector(r);
                    data_ready_signal1<= '1';
                 when computeXOR =>
                    if hash_finished = '1' then
                        Z((counter2+1)*(lambda)-1 downto (counter2)*(lambda))<=hash_output_signal xor s((counter2+1)*(lambda)-1 downto (counter2)*(lambda));
                        L_bound<=L-1;
                        data_ready_signal1<= '1';                              
                    end if;
                 when checkL =>
                    if counter2 < L_bound then
                        L_check<='0';
                        counter2<=counter2+1;
                    else
                        L_check<='1';
                    end if;
                    data_ready_signal1<= '0';
                when done1 =>
                    ready_Gen <= '1'; -- Indicate computation is done
                    data_ready_signal1<= '0';
                    msg_block_signal1<=(others=>'0');
            end case;
        end if;
    end process;
 -- State machine for managing the hashing process
P4: process(current_state1, reset, start_Gen, hash_finished, counter, pass_idle)
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
--                when HashReset1 =>
--                    next_state1<=HashSet1;
--                when HashSet1 =>
--                    next_state1<=idle1;
                
                when idle1 =>
                    if start_Gen = '1' and pass_idle='1' then
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
P5: process(clk, reset)
    begin
        if(reset='1') then
            current_state2 <= reset2;          
        elsif(clk'event and clk='1') then
            current_state2 <= next_state2;
        end if;
    end process;

-----------Solve the puzzle:--------------
P6: process(clk, reset, current_state2, start_sol)
    begin
        if reset = '1' then
            counterN<=0;
            match_lib<='0';
            checkPass <='0';
            sol_done2<='0';
        elsif rising_edge(clk) then
            case current_state2 is
                when reset2 =>
                    data_ready_signal2 <= '0';
                    sol_done2<='0';
                    counterN<=0;
                    counterB<=0;
                    lib_read<='0';
--                when HashReset2 =>
--                    rs2<='1';
--                when HashSet2 =>
--                    rs2<='0';
                when idle2 =>
                    if start_sol_confirmed = '1' then
                        msg_block_signal2(lambda-1 downto 0) <= c0;  -- Assume c0 is provided externally or generated
                        data_ready_signal2 <= '1';
                        sol_done2<='0';
                    else
                        data_ready_signal2 <= '0';
                        sol_done2<='0';
                    end if;
                    checkk_c0<='0';
                when computeP0 =>
                    if hash_finished='1' then
                        ri_1<=hash_output_signal;
                        ri <=hash_output_signal;
                        data_ready_signal2 <= '1';
                        lib_index2<=counterN;
                        lib_read<='1';
                        checkk_c0<='1';
                    end if;
                when checkN =>
                    if counterN< (N_int +1) then
                        counterN<=counterN+1;
                        lib_index2<=counterN+1;
                        --lib_read<='1';                   
                    end if;
                    counterB<=0;
                    checkPass <='0';
                    checkk_c0<='0';
                when checkB =>
                    if counterB< (B_int +1) then                        
                        ci_s <= to_unsigned(counterB,lambda)+unsigned(ri_1);
                        --lib_index2<=counterB;
                        --rs2<='1';
                        counterB<=counterB+1;--counterB is corresponding to 'k' in puzzle generation process
                    end if;
                    checkPass <='0';
                    lib_read<='0';
                when computeCi2 =>   
                    --rs2<='0';               
                    msg_block_signal2(lambda-1 downto 0)<= std_logic_vector(ci_s);                     
                    data_ready_signal2 <= '1';
                    match_lib<='0';
                    --lib_read<='1';
                when wait2 =>
                    if hash_finished='1' then
                        ri<=hash_output_signal;
                        data_ready_signal2 <= '1';
                        
                        lib_read<='1';
                        checkk_c0<='1';
                    else
                        data_ready_signal2 <= '0';
                        
                    end if;
                when checkHelper =>
                    data_ready_signal2 <= '0';

                    if ri=lib_output and lib_output_flag= '1' then
                        match_lib<='1';
                        checkPass <='1';
                        ri_1<=ri;
                    elsif lib_output_flag= '1' then --then, update r_i again
                        match_lib<='0';
                        checkPass <='1';
                    end if;
                    lib_read<='0';
                    
                when checkL =>
                    rN_i<=to_unsigned(counterL, lambda)+unsigned(ri_1);
                    --rs2<='0';
                    msg_block_signal2(lambda-1 downto 0)<=std_logic_vector(rN_i);
                    data_ready_signal2<= '1';
                    lib_read<='0';    
                when computeXOR2 =>
                    if hash_finished = '1' then
                        
                        --Si<=hash_output_signal xor Z((counterL+1)*(lambda)-1 downto (counterL)*(lambda));
                        s_solved((counterL+1)*(lambda)-1 downto (counterL)*(lambda))<= hash_output_signal xor Z((counterL+1)*(lambda)-1 downto (counterL)*(lambda));
                        counterL<=counterL+1;
                        --rs2<='1';
                    end if;
                when done2 =>
                    sol_done2<='1';
                    data_ready_signal2<= '0';
             end case;
        end if;
    end process;
    
 P7: process(current_state2, reset, start_sol, ready_gen , hash_finished, counterN, counterB, match_lib, checkPass, ready_gen)
    begin
            case current_state2 is
                when reset2 =>
                    if(reset='1') then
                        next_state2 <= reset2;
                    elsif ready_gen='1' then
                        next_state2 <= idle2;
                    else
                        next_state2 <= reset2;
                    end if;

                when idle2 =>
                    if start_sol_confirmed = '1' then
                        next_state2 <= computeP0;
                    else
                        next_state2<= idle2;
                    end if;
                when computeP0 =>
                    if hash_finished='1' then
                        next_state2 <= checkHelper;
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
                        next_state2 <=computeCi2;
                    else
                        next_state2 <=checkN;
                    end if;
                
                when computeCi2 =>
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
--                    elsif check_c0= '1' then
--                        next_state2 <= checkN;
                    else
                        next_state2 <= checkHelper;
                    end if; 
                                  
                when checkL =>
                    if counterL<L then
                        next_state2 <=computeXOR2;
                    else
                        next_state2 <=done2;
                    end if;
                when computeXOR2 =>
                    next_state2 <=checkL;
                when done2 =>
                     next_state2 <=done2;
                when others =>
                    next_state2 <= idle2;
            end case;

    end process;
 s_solution<=s;   
 gen_done<=ready_gen;
 sol_done<=sol_done2;
 N_int<=r_n;
 B_int<=r_b;        
 start_sol_confirmed<=ready_Gen and start_sol; 
 data_ready<=data_ready_signal1 xor data_ready_signal2;  
 msg_block <=msg_block_signal1 xor msg_block_signal2;
 rst_n     <= (not reset)  ;
     --c0_seed <= c0; --uncomment it later
     
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
---- Create Date: 10/14/2024 03:51:03 PM
---- Design Name: 
---- Module Name: Compute_NB - Behavioral
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

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity Compute_NB is
--    Port ( clk : in std_logic;
--           ready_in : in std_logic;
--           t : in integer;
--           tc : in integer;
--           h : in integer;
--           e : in integer;
--           N : out integer;
--           B : out integer;
--           ready_out : out STD_LOGIC);
--end Compute_NB;

--architecture Behavioral of Compute_NB is
--constant scaleT       : integer := 1000; --scale tc from ps to ns
--signal temp1, temp2, temp3 : integer := 0;
--signal temp_r_n_stage1, temp_r_n_stage2 : integer := 0;
--signal temp_r_b_stage1, temp_r_b_stage2 : integer := 0;
--signal flag1, flag2 :std_logic :='0';
--signal ready_out_temp: std_logic :='0';
--begin

---- Stage 1: Partial multiplication
--process(clk, ready_in)
--begin
--    if rising_edge(clk) then
--            if ready_in = '1' then
--                temp_r_n_stage1 <= 4 * (h ** 2);
--                temp_r_b_stage1 <= 3 * (e ** 2) * scaleT;
--                flag1 <= '1';
--            else
--                flag1 <= '0';
--            end if;
--        end if;
--end process;

---- Stage 2: More multiplication and division
--process(clk, flag1)
--begin
--    if rising_edge(clk) then
--            if flag1 = '1' then
--                temp_r_n_stage2 <= temp_r_n_stage1 * (t ** 2);
--                temp_r_b_stage2 <= temp_r_b_stage1 / (2 * (h ** 2) * t * tc);
--                flag2 <= '1';
--            else
--                flag2 <= '0';
--            end if;
--        end if;
--end process;

---- Stage 3: Final division
--process(clk, flag2)
--begin
--    if rising_edge(clk) then
--            if flag2 = '1' then
--                N <= temp_r_n_stage2 / (3 * (e ** 2));
--                B <= temp_r_b_stage2;
--                ready_out_temp <= '1';
--            else
--                ready_out_temp <= '0';
--            end if;
--        end if;
--end process;
--ready_out<=ready_out_temp;
--end Behavioral;
