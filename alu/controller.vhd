library ieee;
use ieee.std_logic_1164.all;

entity four_state_moore_state_machine is

	port(
		clk	 : in	std_logic;
		input	 : in	std_logic;
		reset	 : in	std_logic;
		output : out	std_logic_vector(1 downto 0)
	);

end entity;

architecture rtl of four_state_moore_state_machine is

	type state_type is (inicio, busca, decodificacao,
							  noop, load, store, set, swap,
							  move, copy, drop
							  
							  add, sub, inc, dec, inv, compl
							  
							  l_shift, r_shift, bit_or, bit_and,
							  bit_xor, bit_set, bit_clear, _in, _out
							  
							  compare, _and, _or, _xor, jump_if, jump_else,
							  jump, call, _return
	);
	signal state   : state_type;

begin
	process (clk, reset)
	begin
		if reset = '1' then
			state <= inicio;
		elsif (rising_edge(clk)) then
			case state is
				when inicio =>
					state <= busca;
				when busca =>
					state <= decodificacao
				when decodificacao =>
					case opcode is
                  when '00000' =>
                     state <= noop;
                  when '00001' =>
							state <= load;
                  when '00010' =>
                     state <= store;
						when '00011' =>
                     state <= set;
                  when '00100' =>
                     state <= swap;
                  when '00101' =>
							state <= move;
                  when '00110' =>
                     state <= copy;
                  when '00111' =>
                     state <= drop;
                  when '01000' =>
                     state <= add;
                  when '01001' =>
                     state <= sub;
                  when '01010' =>
                     state <= inc;
                  when '01011' =>
                     state <= dec;
                  when '01100' =>
                     state <= inv;
                  when '01101' =>
                     state <= compl;
                  when '01110' =>
                     state <= l_shift;
                  when '01111' =>
                     state <= r_shift;
                  when '10000' =>
                     state <= bit_or;
                  when '10001' =>
                     state <= bit_and;
                  when '10010' =>
                     state <= bit_xor;
                  when '10011' =>
                     state <= bit_set;
                  when '10100' =>
                     state <= bit_clear;
                  when '10101' =>
                     state <= _in;
                  when '10110' =>
                     state <= _out;
                  when '10111' =>
                     state <= compare;
                  when '11000' =>
                     state <= _and;
                  when '11001' =>
                     state <= _or;
                  when '11010' =>
                     state <= _xor;
                  when '11011' =>
                     state <= jump_if;
                  when '11100' =>
                     state <= jump_else;
                  when '11101' =>
                     state <= jump;
                  when '11110' =>
                     state <= call;
                  when '11111' =>
                     state <= _return;
					end case;
				when others =>
					state <= busca;
			end case;
		end if;
	end process;

	process (state)
	begin
		case state is
			when s0 =>
				output <= "00";
			when s1 =>
				output <= "01";
			when s2 =>
				output <= "10";
			when s3 =>
				output <= "11";
		end case;
	end process;

end rtl;
