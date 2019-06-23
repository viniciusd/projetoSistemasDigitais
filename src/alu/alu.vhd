library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
generic
(
	constant N: natural := 1 --numero de bits deslocados
);


port
(
	-- Input ports
	A, B		: in signed(7 downto 0);
	ALU_SEL	: in std_logic_vector(4 downto 0);		
		
	-- Output ports
	ALU_OUT	: out signed (7 downto 0);
	carryout	: out std_logic; --Flag carryout;
	alu_flags: out std_logic := '0'
);
end alu;


architecture behavioral of alu is

-- Declarations (optional)
signal alu_result : signed(7 downto 0);
signal tmp : std_logic_vector(8 downto 0);
signal compare_sel : std_logic_vector(2 downto 0); --compare selector	

begin
process(A, B, ALU_SEL, compare_sel)
begin
	case (ALU_SEL) is
	when "01000" => --add
		alu_result <= A + B;
	when "01001" => --sub
		alu_result <= A - B;
	when "01010" => --inc
		alu_result <= A + 1;
	when "01011" => --dec
		alu_result <= A - 1;
	when "01100" => --inv
		alu_result <= not A;
	when "01101" => --compl
		alu_result <= (not A) + 1;
	when "01110" => --shift_left
		alu_result <= A sll N;
	when "01111" => --shift_right
		alu_result <= A srl N;
	when "11000" => --and
		alu_result <= A and B;
	when "11001" => --or
		alu_result <= A or B;
	when "11010" => --xor
		alu_result <= A xor B;
	when "10111" => --compare
		case (compare_sel) is
		when "000" => --A=B
			if (A=B) then
				alu_flags <= '1';
			end if;
		when "001" => --A>B
			if (A>B) then
				alu_flags <= '1';					 		   			
			end if;
		when "010" => --A<B
			if (A<B) then
				alu_flags <= '1';					 
			end if;
		when "011" => --A>=B
			if (A>=B) then	
				alu_flags <= '1';
			end if;
		when "100" => --A<=B
			if (A<=B) then
				alu_flags <= '1';
			end if;
		when "101" => --A/=B
			if (A/=B) then
				alu_flags <= '1'; 
			end if;
		when others =>
			alu_flags <= '0';
		end case;
	when others =>
		alu_result <= x"00";
	end case;
end process;
ALU_OUT <= ALU_result;
tmp <= ('0' & A) + ('0' & B);
Carryout <= tmp(8); --Carryout flag
end behavioral;
