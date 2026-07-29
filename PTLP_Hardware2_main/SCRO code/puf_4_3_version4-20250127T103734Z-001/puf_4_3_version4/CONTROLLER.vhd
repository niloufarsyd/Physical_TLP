----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:04:19 03/30/2020 
-- Design Name: 
-- Module Name:    PUF_MACHINE - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

------------------------------------------------------------------------------------
---delay: The amount of clock cycles to leave the RO enabled for.
---clock: a clock for this state machine
---w: Allows the state machine to leave the start state when high
---reset:resets the state machine to the start state
---en:output that enable RO
---a_clr:output that clears PUF counters
---cnt_en_ar:output that enables PUF counters to increment
ENTITY CONTROLLER IS
	generic (delay : integer := 125000;--0xFFFFFF
				CI_MUX : integer := 63);
	PORT (  clock, w, Reset     : in std_logic;
			  Difference, XOR_OUT : in std_logic;
			  CI_out :inout std_logic_vector(7 downto 0);
			  latch_en : out std_logic;
			  en, a_clr, cnt_en_ar,mux_sel,CI_en,reg_clr : out std_logic);
END CONTROLLER;
-----------------------------------------------------
ARCHITECTURE Behavior OF CONTROLLER IS
	TYPE State_type IS (start, clear ,enable, diff_evaluation,CI_shift, disable);
	SIGNAL current_state, next_state : State_type :=start;
	SIGNAL counter : integer range 0 to delay := 0;
	SIGNAL cnt_reset, cnt_en, repeat_cnt : std_logic;
	SIGNAL S_MUX_SEL:STD_LOGIC:='0';
	signal CI2 :std_logic_vector(7 downto 0):=(OTHERS=>'0');
	SIGNAL CI : integer range 0 to 63 := 0;

BEGIN
PROCESS (w, current_state, counter, Difference) -- state table
BEGIN
------------------------
	case current_state IS
	WHEN start => --wait here for w input of 1
		IF (w = '0') THEN
		next_state <= start;
		ELSif(w = '1') then
		next_state <= clear;
		END IF;
------------------------
	WHEN clear => --clear the counters in the RO PUF
		next_state <= enABLE;
		latch_en<='0';
------------------------
	WHEN enable => --This is a delay state to allow PUF to count
		if (counter = delay-1) then
		latch_en<='1';
		next_state <= diff_evaluation;		
		else
		next_state <= enable;
		end if;

------------------------
	WHEN diff_evaluation =>
	latch_en<='0';
		if (Difference='1') then
					 S_mux_sel  <='0';
					 repeat_cnt <='0';
					 next_state <= CI_shift;
		elsif (Difference='0') then
					if(  repeat_cnt='0') then 
						  repeat_cnt <='1';
						  next_state <= enable;					  
					elsif ( repeat_cnt='1') then
						  if (XOR_OUT='1') then
							S_mux_sel <='1';
							repeat_cnt <='0';
						   next_state <= CI_shift;

						  else
							S_mux_sel <='0';
							repeat_cnt <='0';
						   next_state <= CI_shift;
						  end if;						 
					end if;
		END IF;		
------------------------
	WHEN CI_shift =>
		if (CI=63) THEN
		next_state <= disable;
		else
		CI<=CI+1;
		next_state <= enable;	
		end if;
------------------------	
	WHEN disable => --disable PUF and wait for w input to be 0

				IF (w = '1') THEN
				 next_state <= disable;
				ELSif(w = '0') then
				 CI<=0;
		next_state <= start;
				END IF;

	END CASE;
	-----------
	END PROCESS; -- state table
	-------------
	MUX_SEL<=S_MUX_SEL;
	--------------
	PROCESS (Clock, reset) -- state flip-flops
	BEGIN
		if (reset='1') then
			current_state<=start;
		elsif (rising_edge(clock)) then
			current_state<=next_state;
		end if;
	END PROCESS;
	--------------
	PROCESS (Clock, cnt_reset, cnt_en, counter) -- state flip-flops
	BEGIN
		if (cnt_reset='1') then
		counter <= 0;
		elsif (rising_edge(clock) and cnt_en = '1' and counter < delay-1) then
		counter <= counter + 1;
		end if;
	END PROCESS;
	--------------
	PROCESS (current_state) -- assign output values
	BEGIN
	-------
	case current_state IS
	WHEN start =>
		en<='0';
		a_clr<='0';
		cnt_en_ar<='0';
		cnt_reset<='1';
		cnt_en<='0';
		reg_clr<='1';
		CI_en<='0';
	WHEN clear => --set clear up
		en<='0';
		a_clr<='1';
		cnt_en_ar<='0';
		cnt_reset<='1';
		cnt_en<='0';
		reg_clr<='0';
		CI_en<='0';

	WHEN enable => --set enable up; reset clear down
		en<='1';
		a_clr<='0';
		cnt_en_ar<='1';
		cnt_reset<='0';
		cnt_en<='1';
		reg_clr<='0';

	WHEN diff_evaluation =>
		en<='1';
		a_clr<='0';
		cnt_en_ar<='0';
		cnt_reset<='0';--??
		cnt_en<='0';
		reg_clr<='0';
		--------------
		CI_en<='1';

	WHEN CI_shift =>
		en<='0';
		a_clr<='1';--??
		cnt_en_ar<='0';
		cnt_reset<='1';--?
		cnt_en<='0';
		reg_clr<='0';
		CI_en<='1';--<------	SHIFT CI REGISTER

	WHEN disable => --disable en
		en<='0';
		a_clr<='0';--??
		cnt_en_ar<='0';
		cnt_reset<='0';
		cnt_en<='0';
		reg_clr<='0';
		CI_en<='0';

	END CASE;
	------
	END PROCESS;
	----------------

CI_OUT <= std_logic_vector(to_unsigned(CI, 8));

END Behavior;