
-- VHDL Instantiation Created from source file RO_DCU_MACRO_instantiate.vhd -- 15:25:33 12/12/2020
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT RO_DCU_MACRO_instantiate
	PORT(
		CLK : IN std_logic;
		cnt_EN : IN std_logic;
		aCLR : IN std_logic;
		CI : IN std_logic_vector(4 downto 0);
		selA : IN std_logic_vector(7 downto 0);
		selb : IN std_logic_vector(7 downto 0);
		en : IN std_logic;
		mux_sel : IN std_logic;          
		XOR_OUT : OUT std_logic;
		Difference : OUT std_logic;
		PUF_OUT : OUT std_logic
		);
	END COMPONENT;

	Inst_RO_DCU_MACRO_instantiate: RO_DCU_MACRO_instantiate PORT MAP(
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


