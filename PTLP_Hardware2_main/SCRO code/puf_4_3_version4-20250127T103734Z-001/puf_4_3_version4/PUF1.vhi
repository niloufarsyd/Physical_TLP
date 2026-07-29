
-- VHDL Instantiation Created from source file PUF1.vhd -- 12:51:42 01/07/2021
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT PUF1
	PORT(
		CLK : IN std_logic;
		cnt_EN : IN std_logic;
		aCLR : IN std_logic;
		CI : IN std_logic_vector(4 downto 0);
		selA : IN std_logic_vector(5 downto 0);
		selb : IN std_logic_vector(5 downto 0);
		en : IN std_logic;
		mux_sel : IN std_logic;          
		XOR_OUT : OUT std_logic;
		Difference : OUT std_logic;
		PUF_OUT : OUT std_logic
		);
	END COMPONENT;

	Inst_PUF1: PUF1 PORT MAP(
		CLK => ,
		cnt_EN => ,
		aCLR => ,
		CI => ,
		selA => ,
		selb => ,
		en => ,
		mux_sel => ,
		XOR_OUT => ,
		Difference => ,
		PUF_OUT => 
	);


