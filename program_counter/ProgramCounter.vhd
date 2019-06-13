library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ProgramCounter is
	port
	(
		-- Input ports
		clk, load, incr, rst	: in std_LOGIC;
		I_PC	: in std_LOGIC_VECTOR (10 downto 0);
				
		-- Output ports
		O_PC	: buffer std_LOGIC_VECTOR (10 downto 0)
	);
end ProgramCounter;

architecture ProgramCounter_arch of ProgramCounter is

begin
	process (clk, rst)
	begin
	if (rst='1') then
			O_PC <= (others => '0');
	elsif rising_edge(clk) and clk'event then
			if (incr='1') then
					O_PC <= std_logic_vector(unsigned(O_PC) + 1);
			elsif (load='1') then
					O_PC <= I_PC;
			end if;
	end if;
	end process;

end ProgramCounter_arch;
