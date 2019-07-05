library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port (
        clock                : in std_logic;
        reset                : in std_logic;
        pc_switch            : in std_logic;
        pc_incr              : in std_logic;
        pc_ld                : in std_logic;
        ir_load              : in std_logic;
        pilha_ld             : in std_logic;
        register_file_switch : in std_logic_vector (2 downto 0);
        alu_switch           : in std_logic_vector (4 downto 0);
        reg_load             : in std_logic_vector (7 downto 0);
        reg_reset            : in std_logic_vector (7 downto 0);
        D_wr                 : in std_logic;

        io_in0               : in std_logic_vector (7 downto 0);
        io_in1               : in std_logic_vector (7 downto 0);
        io_in2               : in std_logic_vector (7 downto 0);
        io_in3               : in std_logic_vector (7 downto 0);

        io_load_in           : in std_logic_vector (3 downto 0);
        io_load_out          : in std_logic_vector (3 downto 0);

        io_out0              : out std_logic_vector (7 downto 0);
        io_out1              : out std_logic_vector (7 downto 0);
        io_out2              : out std_logic_vector (7 downto 0);
        io_out3              : out std_logic_vector (7 downto 0);
        cmp                  : buffer std_logic;
        instruction          : out std_logic_vector (15 downto 0)
    );
end entity;

ARCHITECTURE datapath_arch OF datapath IS

    COMPONENT alu
        PORT 
        (
            -- Input ports
            A, B    : in signed(7 downto 0);
            ALU_SEL	: in std_logic_vector(4 downto 0);
            compare_sel : in std_logic_vector(2 downto 0);
                
            -- Output ports
            ALU_OUT	: out signed (7 downto 0);
            carryout	: out std_logic; --Flag carryout;
            alu_flags: buffer std_logic
        );
    END COMPONENT alu;

    COMPONENT ir
        PORT
        (
            -- Input ports
            program_data : in std_logic_vector (15 downto 0);
            clk          : in std_logic;
            load         : in std_logic;

            -- Output ports
            program_statement : out std_logic_vector (15 downto 0)
        );
    END COMPONENT ir;

    COMPONENT mux2_1
        PORT
        (
            -- Input ports
            e0, e1 : in std_logic_vector(10 downto 0);
            switch : in std_logic;

            -- Output ports
            y : out std_logic_vector(10 downto 0)
        );
    END COMPONENT mux2_1;

    COMPONENT mux8_1
        PORT
        (
            -- Input ports
            e0, e1, e2, e3, e4, e5, e6, e7 : in std_logic_vector(7 downto 0);
            switch : in std_logic_vector(2 downto 0);

            -- Output ports
            y : out std_logic_vector(7 downto 0)
        );
    END COMPONENT mux8_1;

    COMPONENT ProgramCounter
        PORT
        (
            -- Input ports
            clk, load, incr, rst	: in std_LOGIC;
            I_PC	: in std_LOGIC_VECTOR (10 downto 0);
                    
            -- Output ports
            O_PC	: buffer std_LOGIC_VECTOR (10 downto 0)
        );
    END COMPONENT ProgramCounter;

    COMPONENT reg8
        PORT
        (
            -- Input ports
            load   : in std_logic;
            reset  : in std_logic;
            clock  : in std_logic;
            input  : in std_logic_vector (7 downto 0);

            -- Output ports
            output : out std_logic_vector (7 downto 0)
        );
    END COMPONENT reg8;

    COMPONENT reg11
        PORT
        (
            -- Input ports
            load   : in std_logic;
            reset  : in std_logic;
            clock  : in std_logic;
            input  : in std_logic_vector (10 downto 0);

            -- Output ports
            output : out std_logic_vector (10 downto 0)
        );
    END COMPONENT reg11;

    COMPONENT data_memory
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            wren		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END COMPONENT data_memory;

    COMPONENT program_memory 
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
    END COMPONENT program_memory;

    SIGNAL I_PC                 : std_logic_vector (10 downto 0);
    SIGNAL stack_value          : std_logic_vector (10 downto 0);

    SIGNAL program_data         : std_logic_vector (15 downto 0);
    SIGNAL data_memory_rd       : std_logic_vector (7 downto 0);

    SIGNAL reg_input            : std_logic_vector (7 downto 0);
    SIGNAL reg0_output          : std_logic_vector (7 downto 0);
    SIGNAL reg1_output          : std_logic_vector (7 downto 0);
    SIGNAL reg2_output          : std_logic_vector (7 downto 0);
    SIGNAL reg3_output          : std_logic_vector (7 downto 0);
    SIGNAL reg4_output          : std_logic_vector (7 downto 0);
    SIGNAL reg5_output          : std_logic_vector (7 downto 0);
    SIGNAL reg6_output          : std_logic_vector (7 downto 0);
    SIGNAL reg7_output          : std_logic_vector (7 downto 0);

    SIGNAL reg_mux_out_A_output : std_logic_vector (7 downto 0);
    SIGNAL reg_mux_out_B_output : std_logic_vector (7 downto 0);
    SIGNAL ALU_OUT              : signed (7 downto 0);
    SIGNAL alu_carryout         : std_logic;

    SIGNAL reg_in_output        : std_logic_vector (7 downto 0);

    SIGNAL program_address      : std_logic_vector (10 downto 0);
    SIGNAL instruction_data     : std_logic_vector (15 downto 0);

BEGIN
    stack_reg         : reg11          PORT MAP (pilha_ld, reset, clock, program_address, stack_value);
    pc                : ProgramCounter PORT MAP (clock, pc_ld, pc_incr, reset, I_PC, program_address);
    dp_ir             : ir             PORT MAP (program_data, clock, ir_load, instruction_data);
    instruction    <= instruction_data;
    pc_mux            : mux2_1         PORT MAP (instruction_data(10 downto 0), stack_value, pc_switch, I_PC);
    dp_program_memory : program_memory PORT MAP (program_address, clock, program_data);
    dp_data_memory    : data_memory    PORT MAP (instruction_data(7 downto 0), clock, reg_mux_out_A_output, D_wr, data_memory_rd);
    reg_mux_in        : mux8_1         PORT MAP (std_logic_vector(ALU_OUT), data_memory_rd, instruction_data(7 downto 0),
                                                 reg_mux_out_A_output, reg_in_output,
                                                 "00000000", "00000000", "00000000",
                                                 register_file_switch, reg_input);
    reg0              : reg8           PORT MAP (reg_load(0), reg_reset(0), clock, reg_input, reg0_output);
    reg1              : reg8           PORT MAP (reg_load(1), reg_reset(1), clock, reg_input, reg1_output);
    reg2              : reg8           PORT MAP (reg_load(2), reg_reset(2), clock, reg_input, reg2_output);
    reg3              : reg8           PORT MAP (reg_load(3), reg_reset(3), clock, reg_input, reg3_output);
    reg4              : reg8           PORT MAP (reg_load(4), reg_reset(4), clock, reg_input, reg4_output);
    reg5              : reg8           PORT MAP (reg_load(5), reg_reset(5), clock, reg_input, reg5_output);
    reg6              : reg8           PORT MAP (reg_load(6), reg_reset(6), clock, reg_input, reg6_output);
    reg7              : reg8           PORT MAP (reg_load(7), reg_reset(7), clock, reg_input, reg7_output);
    reg_mux_out_A     : mux8_1         PORT MAP (reg0_output, reg1_output, reg2_output, reg3_output,
                                                 reg4_output, reg5_output, reg6_output, reg7_output,
                                                 instruction_data(10 downto 8), reg_mux_out_A_output);
    reg_mux_out_B     : mux8_1         PORT MAP (reg0_output, reg1_output, reg2_output, reg3_output,
                                                 reg4_output, reg5_output, reg6_output, reg7_output,
                                                 instruction_data(7 downto 5), reg_mux_out_B_output);
    dp_alu            : alu            PORT MAP (signed(reg_mux_out_A_output), signed(reg_mux_out_B_output), alu_switch,
                                                 instruction_data(4 downto 2), ALU_OUT, alu_carryout, cmp);

    reg_in0            : reg8          PORT MAP (io_load_in(0), reset, clock, io_in0, reg_in_output);
    reg_in1            : reg8          PORT MAP (io_load_in(1), reset, clock, io_in1, reg_in_output);
    reg_in2            : reg8          PORT MAP (io_load_in(2), reset, clock, io_in2, reg_in_output);
    reg_in3            : reg8          PORT MAP (io_load_in(3), reset, clock, io_in3, reg_in_output);

    reg_out0           : reg8          PORT MAP (io_load_out(0), reset, clock, reg_mux_out_A_output, io_out0);
    reg_out1           : reg8          PORT MAP (io_load_out(1), reset, clock, reg_mux_out_A_output, io_out1);
    reg_out2           : reg8          PORT MAP (io_load_out(2), reset, clock, reg_mux_out_A_output, io_out2);
    reg_out3           : reg8          PORT MAP (io_load_out(3), reset, clock, reg_mux_out_A_output, io_out3);

END datapath_arch;
