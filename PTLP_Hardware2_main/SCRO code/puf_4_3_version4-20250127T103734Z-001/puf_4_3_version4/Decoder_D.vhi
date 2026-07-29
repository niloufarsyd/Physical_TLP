
-- VHDL Instantiation Created from source file Decoder_D.vhd -- 12:27:56 12/05/2020
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT Decoder_D
	PORT(
		en : IN std_logic;
		inA : IN std_logic_vector(5 downto 0);
		inB : IN std_logic_vector(5 downto 0);          
		output : OUT std_logic_vector(63 downto 0)
		);
	END COMPONENT;

	Inst_Decoder_D: Decoder_D PORT MAP(
		en => ,
		inA => ,
		inB => ,
		output => 
	);


