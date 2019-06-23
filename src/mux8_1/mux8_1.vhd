library ieee;

use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

entity mux8_1 is
	port
	(
		-- Input ports
		e0, e1, e2, e3, e4, e5, e6, e7 : in std_logic_vector(7 downto 0);
		switch : in std_logic_vector(2 downto 0);

		-- Output ports
		y : out std_logic_vector(7 downto 0)
	);
end mux8_1;


architecture arch_mux8_1 of mux8_1 is
begin

	WITH switch SELECT
	  y <= e0 WHEN "000",
	       e1 WHEN "001",
	       e2 WHEN "010",
	       e3 WHEN "011",
	       e4 WHEN "100",
	       e5 WHEN "101",
	       e6 WHEN "110",
	       e7 WHEN "111"
	  ;
end arch_mux8_1;
