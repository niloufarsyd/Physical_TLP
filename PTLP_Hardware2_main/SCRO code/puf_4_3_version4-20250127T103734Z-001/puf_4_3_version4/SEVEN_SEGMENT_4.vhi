
-- VHDL Instantiation Created from source file SEVEN_SEGMENT_4.vhd -- 16:10:59 02/07/2021
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT SEVEN_SEGMENT_4
	PORT(
		clk : IN std_logic;
		num1 : IN std_logic_vector(3 downto 0);
		num2 : IN std_logic_vector(3 downto 0);
		num3 : IN std_logic_vector(3 downto 0);
		num4 : IN std_logic_vector(3 downto 0);          
		ds_en : OUT std_logic_vector(3 downto 0);
		ds_reg : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;

	Inst_SEVEN_SEGMENT_4: SEVEN_SEGMENT_4 PORT MAP(
		clk => ,
		num1 => ,
		num2 => ,
		num3 => ,
		num4 => ,
		ds_en => ,
		ds_reg => 
	);


