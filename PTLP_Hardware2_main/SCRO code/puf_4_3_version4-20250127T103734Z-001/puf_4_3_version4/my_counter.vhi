
-- VHDL Instantiation Created from source file my_counter.vhd -- 12:29:32 05/20/2020
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT my_counter
	PORT(
		Clk : IN std_logic;
		CE : IN std_logic;
		CLR : IN std_logic;          
		Q : OUT std_logic_vector(63 downto 0)
		);
	END COMPONENT;

	Inst_my_counter: my_counter PORT MAP(
		Clk => ,
		CE => ,
		CLR => ,
		Q => 
	);


