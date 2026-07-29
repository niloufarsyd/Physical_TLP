----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/18/2024 11:22:05 AM
-- Design Name: 
-- Module Name: encoder256to8 - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encoder256to8 is
    Port ( b : in STD_LOGIC_VECTOR (255 downto 0);
           a : out STD_LOGIC_VECTOR (7 downto 0));
end encoder256to8;

architecture Behavioral of encoder256to8 is
begin
    a(7) <= b(128) or b(129) or b(130) or b(131) or b(132) or b(133) or b(134) or b(135) or 
            b(136) or b(137) or b(138) or b(139) or b(140) or b(141) or b(142) or b(143) or 
            b(144) or b(145) or b(146) or b(147) or b(148) or b(149) or b(150) or b(151) or 
            b(152) or b(153) or b(154) or b(155) or b(156) or b(157) or b(158) or b(159) or
            b(160) or b(161) or b(162) or b(163) or b(164) or b(165) or b(166) or b(167) or
            b(168) or b(169) or b(170) or b(171) or b(172) or b(173) or b(174) or b(175) or
            b(176) or b(177) or b(178) or b(179) or b(180) or b(181) or b(182) or b(183) or
            b(184) or b(185) or b(186) or b(187) or b(188) or b(189) or b(190) or b(191) or
            b(192) or b(193) or b(194) or b(195) or b(196) or b(197) or b(198) or b(199) or
            b(200) or b(201) or b(202) or b(203) or b(204) or b(205) or b(206) or b(207) or
            b(208) or b(209) or b(210) or b(211) or b(212) or b(213) or b(214) or b(215) or
            b(216) or b(217) or b(218) or b(219) or b(220) or b(221) or b(222) or b(223) or
            b(224) or b(225) or b(226) or b(227) or b(228) or b(229) or b(230) or b(231) or
            b(232) or b(233) or b(234) or b(235) or b(236) or b(237) or b(238) or b(239) or
            b(240) or b(241) or b(242) or b(243) or b(244) or b(245) or b(246) or b(247) or
            b(248) or b(249) or b(250) or b(251) or b(252) or b(253) or b(254) or b(255);

    a(6) <= b(64) or b(65) or b(66) or b(67) or b(68) or b(69) or b(70) or b(71) or
            b(72) or b(73) or b(74) or b(75) or b(76) or b(77) or b(78) or b(79) or
            b(80) or b(81) or b(82) or b(83) or b(84) or b(85) or b(86) or b(87) or
            b(88) or b(89) or b(90) or b(91) or b(92) or b(93) or b(94) or b(95) or
            b(96) or b(97) or b(98) or b(99) or b(100) or b(101) or b(102) or b(103) or
            b(104) or b(105) or b(106) or b(107) or b(108) or b(109) or b(110) or b(111) or
            b(112) or b(113) or b(114) or b(115) or b(116) or b(117) or b(118) or b(119) or
            b(120) or b(121) or b(122) or b(123) or b(124) or b(125) or b(126) or b(127);

    a(5) <= b(32) or b(33) or b(34) or b(35) or b(36) or b(37) or b(38) or b(39) or
            b(40) or b(41) or b(42) or b(43) or b(44) or b(45) or b(46) or b(47) or
            b(48) or b(49) or b(50) or b(51) or b(52) or b(53) or b(54) or b(55) or
            b(56) or b(57) or b(58) or b(59) or b(60) or b(61) or b(62) or b(63);

    a(4) <= b(16) or b(17) or b(18) or b(19) or b(20) or b(21) or b(22) or b(23) or
            b(24) or b(25) or b(26) or b(27) or b(28) or b(29) or b(30) or b(31);

    a(3) <= b(8) or b(9) or b(10) or b(11) or b(12) or b(13) or b(14) or b(15);

    a(2) <= b(4) or b(5) or b(6) or b(7);

    a(1) <= b(2) or b(3);

    a(0) <= b(1);
end Behavioral;