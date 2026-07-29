
-- VHDL Instantiation Created from source file Multiplexer_D.vhd -- 12:25:45 12/05/2020
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT Multiplexer_D
	PORT(
		Sel : IN std_logic_vector(5 downto 0);
		dati : IN std_logic_vector(63 downto 0);          
		dato : OUT std_logic
		);
	END COMPONENT;

	Inst_Multiplexer_D: Multiplexer_D PORT MAP(
		Sel => ,
		dati => ,
		dato => 
	);


