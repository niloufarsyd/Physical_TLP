
-- VHDL Instantiation Created from source file PUF_and_CONTROL.vhd -- 16:03:46 02/07/2021
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT PUF_and_CONTROL
	PORT(
		CLK_PUF : IN std_logic;
		CLK_CONTROLLER : IN std_logic;
		w : IN std_logic;
		Reset : IN std_logic;
		selA : IN std_logic_vector(5 downto 0);
		selb : IN std_logic_vector(5 downto 0);          
		en_of_controller : OUT std_logic;
		ENABLE_SIGN : OUT std_logic;
		DISABLE_SIGN : OUT std_logic;
		PUF : OUT std_logic;
		PUF_OUT64 : OUT std_logic_vector(63 downto 0)
		);
	END COMPONENT;

	Inst_PUF_and_CONTROL: PUF_and_CONTROL PORT MAP(
		CLK_PUF => ,
		CLK_CONTROLLER => ,
		w => ,
		Reset => ,
		selA => ,
		selb => ,
		en_of_controller => ,
		ENABLE_SIGN => ,
		DISABLE_SIGN => ,
		PUF => ,
		PUF_OUT64 => 
	);


