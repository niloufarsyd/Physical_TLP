
-- VHDL Instantiation Created from source file PUF_OUT_REGISTER.vhd -- 06:15:55 02/01/2021
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT PUF_OUT_REGISTER
	PORT(
		PUF_i : IN std_logic;
		EN : IN std_logic;
		CLK : IN std_logic;          
		PUF_o : OUT std_logic_vector(63 downto 0)
		);
	END COMPONENT;

	Inst_PUF_OUT_REGISTER: PUF_OUT_REGISTER PORT MAP(
		PUF_i => ,
		EN => ,
		CLK => ,
		PUF_o => 
	);


