
-- VHDL Instantiation Created from source file RO_PUF_Main.vhd -- 12:56:15 06/27/2020
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT RO_PUF_Main
	PORT(
		clk_machine : IN std_logic;
		clk_array : IN std_logic;
		w : IN std_logic;
		reset : IN std_logic;
		selA : IN std_logic_vector(7 downto 0);
		selB : IN std_logic_vector(7 downto 0);          
		res_ar : OUT std_logic
		);
	END COMPONENT;

	Inst_RO_PUF_Main: RO_PUF_Main PORT MAP(
		clk_machine => ,
		clk_array => ,
		w => ,
		reset => ,
		selA => ,
		selB => ,
		res_ar => 
	);


