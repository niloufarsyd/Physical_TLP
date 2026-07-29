
-- VHDL Instantiation Created from source file puf_bit.vhd -- 10:44:55 06/24/2020
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT puf_bit
	PORT(
		clk : IN std_logic;
		en : IN std_logic;
		selA : IN std_logic_vector(7 downto 0);
		selB : IN std_logic_vector(7 downto 0);
		aclr : IN std_logic;
		cnt_en : IN std_logic;          
		p1 : OUT std_logic;
		p2 : OUT std_logic;
		res : OUT std_logic
		);
	END COMPONENT;

	Inst_puf_bit: puf_bit PORT MAP(
		clk => ,
		en => ,
		selA => ,
		selB => ,
		aclr => ,
		cnt_en => ,
		p1 => ,
		p2 => ,
		res => 
	);


