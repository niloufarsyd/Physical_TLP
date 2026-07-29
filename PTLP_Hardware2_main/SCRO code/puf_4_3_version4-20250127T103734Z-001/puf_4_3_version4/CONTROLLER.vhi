
-- VHDL Instantiation Created from source file CONTROLLER.vhd -- 16:04:32 02/07/2021
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT CONTROLLER
	PORT(
		clock : IN std_logic;
		w : IN std_logic;
		Reset : IN std_logic;
		Difference : IN std_logic;
		XOR_OUT : IN std_logic;          
		CI_out : OUT std_logic_vector(5 downto 0);
		ENABLE_SIGN : OUT std_logic;
		DISABLE_SIGN : OUT std_logic;
		en : OUT std_logic;
		a_clr : OUT std_logic;
		cnt_en_ar : OUT std_logic;
		mux_sel : OUT std_logic;
		CI_en : OUT std_logic
		);
	END COMPONENT;

	Inst_CONTROLLER: CONTROLLER PORT MAP(
		clock => ,
		w => ,
		Reset => ,
		Difference => ,
		XOR_OUT => ,
		CI_out => ,
		ENABLE_SIGN => ,
		DISABLE_SIGN => ,
		en => ,
		a_clr => ,
		cnt_en_ar => ,
		mux_sel => ,
		CI_en => 
	);


