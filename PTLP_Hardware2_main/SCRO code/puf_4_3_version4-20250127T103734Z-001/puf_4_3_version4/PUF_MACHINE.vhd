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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

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
ENTITY Machine IS
	generic (delay : integer := 12500000);
	PORT ( clock, w, Reset     : in std_logic;
			en, a_clr, cnt_en_ar : out std_logic);
END Machine;
-----------------------------------------------------
ARCHITECTURE Behavior OF Machine IS
	TYPE State_type IS (start, clear, enable, disable);
	SIGNAL current_state, next_state : State_type :=start;
	SIGNAL counter : integer range 0 to delay-1 := 0;
	SIGNAL cnt_reset, cnt_en : std_logic;
BEGIN
PROCESS (w, current_state, counter) -- state table
BEGIN
	----------
	case current_state IS
	WHEN start => --wait here for w input of 1
		IF (w = '0') THEN
		next_state <= start;
		ELSif(w = '1') then
		next_state <= clear;
		END IF;
	WHEN clear => --clear the counters in the RO PUF
		next_state <= enable;
	WHEN enable => --This is a delay state to allow PUF to count
		if (counter = delay-1) then
		next_state <= disable;
		else
		next_state <= enable;
		end if;
	WHEN disable => --disable PUF and wait for w input to be 0
		IF (w = '1') THEN
		next_state <= disable;
		ELSif(w = '0') then
		next_state <= start;
		END IF;
	END CASE;
	-----------
	END PROCESS; -- state table
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
		elsif (rising_edge(clock) and cnt_en = '1' and counter /= delay-1) then
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
	WHEN clear => --set clear up
		en<='0';
		a_clr<='1';
		cnt_en_ar<='0';
		cnt_reset<='1';
		cnt_en<='0';
	WHEN enable => --set enable up; reset clear down
		en<='1';
		a_clr<='0';
		cnt_en_ar<='1';
		cnt_reset<='0';
		cnt_en<='1';
	WHEN disable => --disable en
		en<='0';
		a_clr<='0';
		cnt_en_ar<='0';
		cnt_reset<='0';
		cnt_en<='0';
	END CASE;
	------
	END PROCESS;
	----------------
--	PROCESS (Difference) -- assign output values
--	BEGIN
--	if(Difference='1') then
--		puf_select <='0';
--	elsif (Difference='0') then
--		if (cnt_en='0') then
--		 cnt_en<='1';
--		elsif (cnt_en='1') then
--			if (XOR_OUT='0') then
--			 puf_select<='0';
--			else 
--			puf_select<='1';
--			end if;
--		end if;
--	end if;
--	
--	
--	END PROCESS;
	----------------
	
END Behavior;