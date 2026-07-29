
-- VHDL Instantiation Created from source file my_COMPARE.vhd -- 03:31:37 12/08/2020
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT my_COMPARE
	PORT(
		A : IN std_logic_vector(31 downto 0);
		B : IN std_logic_vector(31 downto 0);          
		diff : OUT std_logic;
		GTh : OUT std_logic
		);
	END COMPONENT;

	Inst_my_COMPARE: my_COMPARE PORT MAP(
		A => ,
		B => ,
		diff => ,
		GTh => 
	);


