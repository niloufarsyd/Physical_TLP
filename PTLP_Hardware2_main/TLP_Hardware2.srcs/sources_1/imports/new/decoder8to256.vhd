----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/18/2024 11:06:30 AM
-- Design Name: 
-- Module Name: decoder8to256 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder8to256 is
    Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
           b : out STD_LOGIC_VECTOR (255 downto 0));
end decoder8to256;

architecture bhv of decoder8to256 is
    signal lower : STD_LOGIC_VECTOR(15 downto 0);  -- Intermediate signals for the lower bits
    signal upper : STD_LOGIC_VECTOR(15 downto 0);  -- Intermediate signals for the upper bits
begin

    -- Decode the upper 4 bits of 'a' (a(7 downto 4)) into 16 outputs
    upper(0)  <= not a(7) and not a(6) and not a(5) and not a(4);
    upper(1)  <= not a(7) and not a(6) and not a(5) and a(4);
    upper(2)  <= not a(7) and not a(6) and a(5) and not a(4);
    upper(3)  <= not a(7) and not a(6) and a(5) and a(4);
    upper(4)  <= not a(7) and a(6) and not a(5) and not a(4);
    upper(5)  <= not a(7) and a(6) and not a(5) and a(4);
    upper(6)  <= not a(7) and a(6) and a(5) and not a(4);
    upper(7)  <= not a(7) and a(6) and a(5) and a(4);
    upper(8)  <= a(7) and not a(6) and not a(5) and not a(4);
    upper(9)  <= a(7) and not a(6) and not a(5) and a(4);
    upper(10) <= a(7) and not a(6) and a(5) and not a(4);
    upper(11) <= a(7) and not a(6) and a(5) and a(4);
    upper(12) <= a(7) and a(6) and not a(5) and not a(4);
    upper(13) <= a(7) and a(6) and not a(5) and a(4);
    upper(14) <= a(7) and a(6) and a(5) and not a(4);
    upper(15) <= a(7) and a(6) and a(5) and a(4);

    -- Decode the lower 4 bits of 'a' (a(3 downto 0)) into 16 outputs
    lower(0)  <= not a(3) and not a(2) and not a(1) and not a(0);
    lower(1)  <= not a(3) and not a(2) and not a(1) and a(0);
    lower(2)  <= not a(3) and not a(2) and a(1) and not a(0);
    lower(3)  <= not a(3) and not a(2) and a(1) and a(0);
    lower(4)  <= not a(3) and a(2) and not a(1) and not a(0);
    lower(5)  <= not a(3) and a(2) and not a(1) and a(0);
    lower(6)  <= not a(3) and a(2) and a(1) and not a(0);
    lower(7)  <= not a(3) and a(2) and a(1) and a(0);
    lower(8)  <= a(3) and not a(2) and not a(1) and not a(0);
    lower(9)  <= a(3) and not a(2) and not a(1) and a(0);
    lower(10) <= a(3) and not a(2) and a(1) and not a(0);
    lower(11) <= a(3) and not a(2) and a(1) and a(0);
    lower(12) <= a(3) and a(2) and not a(1) and not a(0);
    lower(13) <= a(3) and a(2) and not a(1) and a(0);
    lower(14) <= a(3) and a(2) and a(1) and not a(0);
    lower(15) <= a(3) and a(2) and a(1) and a(0);

    -- Manually assign each output signal
    -- Upper(0) and Lower(0)
    b(0)  <= upper(0)  and lower(0);
    b(1)  <= upper(0)  and lower(1);
    b(2)  <= upper(0)  and lower(2);
    b(3)  <= upper(0)  and lower(3);
    b(4)  <= upper(0)  and lower(4);
    b(5)  <= upper(0)  and lower(5);
    b(6)  <= upper(0)  and lower(6);
    b(7)  <= upper(0)  and lower(7);
    b(8)  <= upper(0)  and lower(8);
    b(9)  <= upper(0)  and lower(9);
    b(10) <= upper(0)  and lower(10);
    b(11) <= upper(0)  and lower(11);
    b(12) <= upper(0)  and lower(12);
    b(13) <= upper(0)  and lower(13);
    b(14) <= upper(0)  and lower(14);
    b(15) <= upper(0)  and lower(15);

    -- Upper(1) and Lower(0)
    b(16)  <= upper(1)  and lower(0);
    b(17)  <= upper(1)  and lower(1);
    b(18)  <= upper(1)  and lower(2);
    b(19)  <= upper(1)  and lower(3);
    b(20)  <= upper(1)  and lower(4);
    b(21)  <= upper(1)  and lower(5);
    b(22)  <= upper(1)  and lower(6);
    b(23)  <= upper(1)  and lower(7);
    b(24)  <= upper(1)  and lower(8);
    b(25)  <= upper(1)  and lower(9);
    b(26)  <= upper(1)  and lower(10);
    b(27)  <= upper(1)  and lower(11);
    b(28)  <= upper(1)  and lower(12);
    b(29)  <= upper(1)  and lower(13);
    b(30)  <= upper(1)  and lower(14);
    b(31)  <= upper(1)  and lower(15);
    b(32)  <= upper(2)  and lower(0);
    b(33)  <= upper(2)  and lower(1);
    b(34)  <= upper(2)  and lower(2);
    b(35)  <= upper(2)  and lower(3);
    b(36)  <= upper(2)  and lower(4);
    b(37)  <= upper(2)  and lower(5);
    b(38)  <= upper(2)  and lower(6);
    b(39)  <= upper(2)  and lower(7);
    b(40)  <= upper(2)  and lower(8);
    b(41)  <= upper(2)  and lower(9);
    b(42)  <= upper(2)  and lower(10);
    b(43)  <= upper(2)  and lower(11);
    b(44)  <= upper(2)  and lower(12);
    b(45)  <= upper(2)  and lower(13);
    b(46)  <= upper(2)  and lower(14);
    b(47)  <= upper(2)  and lower(15);
    b(48)  <= upper(3)  and lower(0);
    b(49)  <= upper(3)  and lower(1);
    b(50)  <= upper(3)  and lower(2);
    b(51)  <= upper(3)  and lower(3);
    b(52)  <= upper(3)  and lower(4);
    b(53)  <= upper(3)  and lower(5);
    b(54)  <= upper(3)  and lower(6);
    b(55)  <= upper(3)  and lower(7);
    b(56)  <= upper(3)  and lower(8);
    b(57)  <= upper(3)  and lower(9);
    b(58)  <= upper(3)  and lower(10);
    b(59)  <= upper(3)  and lower(11);
    b(60)  <= upper(3)  and lower(12);
    b(61)  <= upper(3)  and lower(13);
    b(62)  <= upper(3)  and lower(14);
    b(63)  <= upper(3)  and lower(15);
    b(64)  <= upper(4)  and lower(0);
    b(65)  <= upper(4)  and lower(1);
    b(66)  <= upper(4)  and lower(2);
    b(67)  <= upper(4)  and lower(3);
    b(68)  <= upper(4)  and lower(4);
    b(69)  <= upper(4)  and lower(5);
    b(70)  <= upper(4)  and lower(6);
    b(71)  <= upper(4)  and lower(7);
    b(72)  <= upper(4)  and lower(8);
    b(73)  <= upper(4)  and lower(9);
    b(74)  <= upper(4)  and lower(10);
    b(75)  <= upper(4)  and lower(11);
    b(76)  <= upper(4)  and lower(12);
    b(77)  <= upper(4)  and lower(13);
    b(78)  <= upper(4)  and lower(14);
    b(79)  <= upper(4)  and lower(15);
    b(80)  <= upper(5)  and lower(0);
    b(81)  <= upper(5)  and lower(1);
    b(82)  <= upper(5)  and lower(2);
    b(83)  <= upper(5)  and lower(3);
    b(84)  <= upper(5)  and lower(4);
    b(85)  <= upper(5)  and lower(5);
    b(86)  <= upper(5)  and lower(6);
    b(87)  <= upper(5)  and lower(7);
    b(88)  <= upper(5)  and lower(8);
    b(89)  <= upper(5)  and lower(9);
    b(90)  <= upper(5)  and lower(10);
    b(91)  <= upper(5)  and lower(11);
    b(92)  <= upper(5)  and lower(12);
    b(93)  <= upper(5)  and lower(13);
    b(94)  <= upper(5)  and lower(14);
    b(95)  <= upper(5)  and lower(15);

    b(96)  <= upper(6)  and lower(0);
    b(97)  <= upper(6)  and lower(1);
    b(98)  <= upper(6)  and lower(2);
    b(99)  <= upper(6)  and lower(3);
    b(100) <= upper(6)  and lower(4);
    b(101) <= upper(6)  and lower(5);
    b(102) <= upper(6)  and lower(6);
    b(103) <= upper(6)  and lower(7);
    b(104) <= upper(6)  and lower(8);
    b(105) <= upper(6)  and lower(9);
    b(106) <= upper(6)  and lower(10);
    b(107) <= upper(6)  and lower(11);
    b(108) <= upper(6)  and lower(12);
    b(109) <= upper(6)  and lower(13);
    b(110) <= upper(6)  and lower(14);
    b(111) <= upper(6)  and lower(15);

    b(112) <= upper(7)  and lower(0);
    b(113) <= upper(7)  and lower(1);
    b(114) <= upper(7)  and lower(2);
    b(115) <= upper(7)  and lower(3);
    b(116) <= upper(7)  and lower(4);
    b(117) <= upper(7)  and lower(5);
    b(118) <= upper(7)  and lower(6);
    b(119) <= upper(7)  and lower(7);
    b(120) <= upper(7)  and lower(8);
    b(121) <= upper(7)  and lower(9);
    b(122) <= upper(7)  and lower(10);
    b(123) <= upper(7)  and lower(11);
    b(124) <= upper(7)  and lower(12);
    b(125) <= upper(7)  and lower(13);
    b(126) <= upper(7)  and lower(14);
    b(127) <= upper(7)  and lower(15);

    b(128) <= upper(8)  and lower(0);
    b(129) <= upper(8)  and lower(1);
    b(130) <= upper(8)  and lower(2);
    b(131) <= upper(8)  and lower(3);
    b(132) <= upper(8)  and lower(4);
    b(133) <= upper(8)  and lower(5);
    b(134) <= upper(8)  and lower(6);
    b(135) <= upper(8)  and lower(7);
    b(136) <= upper(8)  and lower(8);
    b(137) <= upper(8)  and lower(9);
    b(138) <= upper(8)  and lower(10);
    b(139) <= upper(8)  and lower(11);
    b(140) <= upper(8)  and lower(12);
    b(141) <= upper(8)  and lower(13);
    b(142) <= upper(8)  and lower(14);
    b(143) <= upper(8)  and lower(15);

    b(144) <= upper(9)  and lower(0);
    b(145) <= upper(9)  and lower(1);
    b(146) <= upper(9)  and lower(2);
    b(147) <= upper(9)  and lower(3);
    b(148) <= upper(9)  and lower(4);
    b(149) <= upper(9)  and lower(5);
    b(150) <= upper(9)  and lower(6);
    b(151) <= upper(9)  and lower(7);
    b(152) <= upper(9)  and lower(8);
    b(153) <= upper(9)  and lower(9);
    b(154) <= upper(9)  and lower(10);
    b(155) <= upper(9)  and lower(11);
    b(156) <= upper(9)  and lower(12);
    b(157) <= upper(9)  and lower(13);
    b(158) <= upper(9)  and lower(14);
    b(159) <= upper(9)  and lower(15);

    b(160) <= upper(10) and lower(0);
    b(161) <= upper(10) and lower(1);
    b(162) <= upper(10) and lower(2);
    b(163) <= upper(10) and lower(3);
    b(164) <= upper(10) and lower(4);
    b(165) <= upper(10) and lower(5);
    b(166) <= upper(10) and lower(6);
    b(167) <= upper(10) and lower(7);
    b(168) <= upper(10) and lower(8);
    b(169) <= upper(10) and lower(9);
    b(170) <= upper(10) and lower(10);
    b(171) <= upper(10) and lower(11);
    b(172) <= upper(10) and lower(12);
    b(173) <= upper(10) and lower(13);
    b(174) <= upper(10) and lower(14);
    b(175) <= upper(10) and lower(15);

    b(176) <= upper(11) and lower(0);
    b(177) <= upper(11) and lower(1);
    b(178) <= upper(11) and lower(2);
    b(179) <= upper(11) and lower(3);
    b(180) <= upper(11) and lower(4);
    b(181) <= upper(11) and lower(5);
    b(182) <= upper(11) and lower(6);
    b(183) <= upper(11) and lower(7);
    b(184) <= upper(11) and lower(8);
    b(185) <= upper(11) and lower(9);
    b(186) <= upper(11) and lower(10);
    b(187) <= upper(11) and lower(11);
    b(188) <= upper(11) and lower(12);
    b(189) <= upper(11) and lower(13);
    b(190) <= upper(11) and lower(14);
    b(191) <= upper(11) and lower(15);

    b(192) <= upper(12) and lower(0);
    b(193) <= upper(12) and lower(1);
    b(194) <= upper(12) and lower(2);
    b(195) <= upper(12) and lower(3);
    b(196) <= upper(12) and lower(4);
    b(197) <= upper(12) and lower(5);
    b(198) <= upper(12) and lower(6);
    b(199) <= upper(12) and lower(7);
    b(200) <= upper(12) and lower(8);
    b(201) <= upper(12) and lower(9);
    b(202) <= upper(12) and lower(10);
    b(203) <= upper(12) and lower(11);
    b(204) <= upper(12) and lower(12);
    b(205) <= upper(12) and lower(13);
    b(206) <= upper(12) and lower(14);
    b(207) <= upper(12) and lower(15);
    
    b(208) <= upper(13) and lower(0);
    b(209) <= upper(13) and lower(1);
    b(210) <= upper(13) and lower(2);
    b(211) <= upper(13) and lower(3);
    b(212) <= upper(13) and lower(4);
    b(213) <= upper(13) and lower(5);
    b(214) <= upper(13) and lower(6);
    b(215) <= upper(13) and lower(7);
    b(216) <= upper(13) and lower(8);
    b(217) <= upper(13) and lower(9);
    b(218) <= upper(13) and lower(10);
    b(219) <= upper(13) and lower(11);
    b(220) <= upper(13) and lower(12);
    b(221) <= upper(13) and lower(13);
    b(222) <= upper(13) and lower(14);
    b(223) <= upper(13) and lower(15);

    b(224) <= upper(14) and lower(0);
    b(225) <= upper(14) and lower(1);
    b(226) <= upper(14) and lower(2);
    b(227) <= upper(14) and lower(3);
    b(228) <= upper(14) and lower(4);
    b(229) <= upper(14) and lower(5);
    b(230) <= upper(14) and lower(6);
    b(231) <= upper(14) and lower(7);
    b(232) <= upper(14) and lower(8);
    b(233) <= upper(14) and lower(9);
    b(234) <= upper(14) and lower(10);
    b(235) <= upper(14) and lower(11);
    b(236) <= upper(14) and lower(12);
    b(237) <= upper(14) and lower(13);
    b(238) <= upper(14) and lower(14);
    b(239) <= upper(14) and lower(15);

   

    -- Upper(15) and Lower(15)
    b(240) <= upper(15) and lower(0);
    b(241) <= upper(15) and lower(1);
    b(242) <= upper(15) and lower(2);
    b(243) <= upper(15) and lower(3);
    b(244) <= upper(15) and lower(4);
    b(245) <= upper(15) and lower(5);
    b(246) <= upper(15) and lower(6);
    b(247) <= upper(15) and lower(7);
    b(248) <= upper(15) and lower(8);
    b(249) <= upper(15) and lower(9);
    b(250) <= upper(15) and lower(10);
    b(251) <= upper(15) and lower(11);
    b(252) <= upper(15) and lower(12);
    b(253) <= upper(15) and lower(13);
    b(254) <= upper(15) and lower(14);
    b(255) <= upper(15) and lower(15);

end bhv;