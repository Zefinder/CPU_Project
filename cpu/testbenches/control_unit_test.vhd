library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;
use utils.test_utils.all;

entity control_unit_test is
end entity control_unit_test;

architecture testbench of control_unit_test is

    component control_unit
        port(
            instruction_vector                 : in  std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
            operand1                           : out std_logic_vector(DATA_SIZE - 1 downto 0);
            operand2                           : out std_logic_vector(DATA_SIZE - 1 downto 0);
            alu_selector                       : out std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
            register_address_read_1            : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_read_2            : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_write             : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            flag_address                       : out std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
            ram_address                        : out std_logic_vector(DATA_SIZE - 1 downto 0);
            use_alu                            : out std_logic;
            update_one_flag                    : out std_logic;
            use_register_1                     : out std_logic;
            use_register_2                     : out std_logic;
            use_memory_for_register            : out std_logic;
            use_register_for_memory            : out std_logic;
            use_branching_unit                 : out std_logic;
            use_branching_offset               : out std_logic;
            use_register_for_branching_address : out std_logic;
            use_register_for_branching_offset  : out std_logic;
            branch_invert_flag                 : out std_logic;
            write_register                     : out std_logic;
            write_ram                          : out std_logic
        );
    end component control_unit;

    -- Bit representing the fourth ALU selector bit
    constant ALU_SEL_3 : natural := 6;
    -- Bit representing the usage of the second register
    constant USE_REG_2 : natural := 5;
    -- Bit representing the usage of the first register
    constant USE_REG_1 : natural := 4;
    -- Bit enabling the ALU
    constant EN_ALU    : natural := 3;
    -- Bit representing the third ALU selector bit
    constant ALU_SEL_2 : natural := 2;
    -- Bit representing the second ALU selector bit
    constant ALU_SEL_1 : natural := 1;
    -- Bit representing the first ALU selector bit
    constant ALU_SEL_0 : natural := 0;

    -- Non branching opcode bits

    -- Bit enabling storage in the RAM memory
    constant STR_MEM : natural := 7;
    -- Bit enabling storage in the register bank
    constant STR_REG : natural := 6;
    -- Bit putting memory output to register input
    constant USE_MEM : natural := 5;
    -- Bit putting register output to memory input
    constant USE_REG : natural := 4;

    -- Branching opcodes bits

    -- Bit representing the usage of the second register
    constant FL_SEL_1       : natural := 7;
    -- Bit representing the usage of the first register
    constant FL_SEL_0       : natural := 6;
    -- Bit representing the usage of the second register for the offset
    constant USE_REG_OFFSET : natural := 5;
    -- Bit representing the usage of the first register for the address
    constant USE_REG_ADDR   : natural := 4;
    -- Bit inverting flag test ('0' instead of '1')
    constant INV_FLAG       : natural := 2;
    -- Bit representing the usage of the first register
    constant EN_BRANCH      : natural := 1;
    -- Bit representing the usage of the first register
    constant EN_REL_BRANCH  : natural := 0;

    for all : control_unit use entity work.control_unit(RTL);

    signal instruction_vector                 : std_logic_vector(INSTRUCTION_SIZE - 1 downto 0) := (x"00", x"12", x"34", x"56");
    signal operand1                           : std_logic_vector(DATA_SIZE - 1 downto 0);
    signal operand2                           : std_logic_vector(DATA_SIZE - 1 downto 0);
    signal alu_selector                       : std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
    signal register_address_read_1            : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
    signal register_address_read_2            : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
    signal register_address_write             : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
    signal flag_address                       : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
    signal ram_address                        : std_logic_vector(DATA_SIZE - 1 downto 0);
    signal use_alu                            : std_logic;
    signal update_one_flag                    : std_logic;
    signal use_register_1                     : std_logic;
    signal use_register_2                     : std_logic;
    signal use_memory_for_register            : std_logic;
    signal use_register_for_memory            : std_logic;
    signal use_branching_unit                 : std_logic;
    signal use_branching_offset               : std_logic;
    signal use_register_for_branching_address : std_logic;
    signal use_register_for_branching_offset  : std_logic;
    signal branch_invert_flag                 : std_logic;
    signal write_register                     : std_logic;
    signal write_ram                          : std_logic;
begin

    control_unit_inst : component control_unit
        port map(
            instruction_vector                 => instruction_vector,
            operand1                           => operand1,
            operand2                           => operand2,
            alu_selector                       => alu_selector,
            register_address_read_1            => register_address_read_1,
            register_address_read_2            => register_address_read_2,
            register_address_write             => register_address_write,
            flag_address                       => flag_address,
            ram_address                        => ram_address,
            use_alu                            => use_alu,
            update_one_flag                    => update_one_flag,
            use_register_1                     => use_register_1,
            use_register_2                     => use_register_2,
            use_memory_for_register            => use_memory_for_register,
            use_register_for_memory            => use_register_for_memory,
            use_branching_unit                 => use_branching_unit,
            use_branching_offset               => use_branching_offset,
            use_register_for_branching_address => use_register_for_branching_address,
            use_register_for_branching_offset  => use_register_for_branching_offset,
            branch_invert_flag                 => branch_invert_flag,
            write_register                     => write_register,
            write_ram                          => write_ram
        );

    control_unit_process_test : process is
        constant instruction_a       : std_logic_vector(DATA_SIZE - 1 downto 0) := x"12";
        constant instruction_b       : std_logic_vector(DATA_SIZE - 1 downto 0) := x"34";
        constant instruction_address : std_logic_vector(DATA_SIZE - 1 downto 0) := x"56";

        variable opcode_variable        : natural := 0;
        variable opcode_variable_vector : std_logic_vector(DATA_SIZE - 1 downto 0);
        variable instruction_opcode     : std_logic_vector(DATA_SIZE - 1 downto 0);

        variable alu_selector_variable  : std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
        variable flag_selector_variable : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
    begin
        wait for 5 ns;

        -- Assert values
        instruction_opcode     := instruction_vector(4 * DATA_SIZE - 1 downto 3 * DATA_SIZE);
        opcode_variable_vector := std_logic_vector(to_unsigned(opcode_variable, DATA_SIZE));
        alu_selector_variable  := instruction_opcode(ALU_SEL_3) & instruction_opcode(ALU_SEL_2) & instruction_opcode(ALU_SEL_1) & instruction_opcode(ALU_SEL_0);
        flag_selector_variable := instruction_opcode(FL_SEL_1) & instruction_opcode(FL_SEL_0);

        assert instruction_opcode = opcode_variable_vector
        report print_error("Different opcodes", opcode_variable_vector, instruction_opcode) severity error;

        assert operand1 = instruction_a
        report print_error("Wrong first ALU operand", instruction_a, operand1) severity error;

        assert operand2 = instruction_b
        report print_error("Wrong second ALU operand", instruction_b, operand2) severity error;

        assert alu_selector = alu_selector_variable
        report print_error("Wrong ALU selector", alu_selector_variable, alu_selector) severity error;

        assert update_one_flag = instruction_opcode(ALU_SEL_3)
        report print_bit_error("Wrong one flag update", instruction_opcode(ALU_SEL_3), update_one_flag);

        assert register_address_read_1 = instruction_a(REGISTER_SELECTOR_SIZE - 1 downto 0)
        report print_error("Wrong first register address", instruction_address(DATA_SIZE - 1 downto DATA_SIZE / 2), register_address_read_1) severity error;

        assert register_address_read_2 = instruction_b(REGISTER_SELECTOR_SIZE - 1 downto 0)
        report print_error("Wrong second register address", instruction_address(DATA_SIZE / 2 - 1 downto 0), register_address_read_2) severity error;

        assert ram_address = instruction_address
        report print_error("Wrong RAM address", instruction_address, ram_address) severity error;

        assert use_branching_offset = instruction_opcode(EN_REL_BRANCH)
        report print_bit_error("Wrong branching offset enabling", instruction_opcode(EN_REL_BRANCH), use_branching_offset) severity error;

        assert branch_invert_flag = instruction_opcode(INV_FLAG)
        report print_bit_error("Wrong invert flag enabling", instruction_opcode(INV_FLAG), branch_invert_flag) severity error;

        assert use_register_for_branching_address = instruction_opcode(USE_REG_ADDR)
        report print_bit_error("Wrong using first register for branching address enabling", instruction_opcode(USE_REG_ADDR), use_register_for_branching_address) severity error;

        assert use_register_for_branching_offset = instruction_opcode(USE_REG_OFFSET)
        report print_bit_error("Wrong using second register for branching offset enabling", instruction_opcode(USE_REG_OFFSET), use_register_for_branching_offset) severity error;

        if instruction_opcode(EN_ALU) = '1' then
            assert use_alu = '1'
            report print_bit_error("ALU must be enabled", '1', use_alu) severity error;

            assert use_memory_for_register = '0'
            report print_bit_error("Using memory as register input must be off", '0', use_memory_for_register) severity error;

            assert use_register_for_memory = '0'
            report print_bit_error("Using register as memory input must be off", '0', use_register_for_memory) severity error;

            assert use_register_1 = instruction_opcode(USE_REG_1)
            report print_bit_error("Using first register as ALU input must be off", instruction_opcode(USE_REG_1), use_register_1) severity error;

            assert use_register_2 = instruction_opcode(USE_REG_2)
            report print_bit_error("Using second register as ALU input must be off", instruction_opcode(USE_REG_2), use_register_2) severity error;

            assert use_branching_unit = '0'
            report print_bit_error("Branching unit must be disabled for ALU", '0', use_branching_unit) severity error;

            -- TODO To change when ALU improved
            if alu_selector = "0111" or instruction_opcode(ALU_SEL_3) = '1' then
                assert write_register = '0'
                report print_bit_error("Writing in register must be disabled for ALU", '0', write_register) severity error;
            else
                assert write_register = '1'
                report print_bit_error("Writing in register must be enabled for ALU", '1', write_register) severity error;

            end if;

            assert write_ram = '0'
            report print_bit_error("Writing in RAM must be disabled for ALU", '0', write_ram) severity error;

            assert flag_address = FLAG_C_ADDR
            report print_error("Wrong flag address for ALU", FLAG_C_ADDR, flag_address) severity error;

            assert register_address_write = instruction_address(DATA_SIZE / 2 - 1 downto 0)
            report print_error("Wrong register write address for ALU", instruction_address(DATA_SIZE / 2 - 1 downto 0), register_address_write) severity error;
        else
            assert use_alu = '0'
            report print_bit_error("ALU must be disabled when not ALU", '0', use_alu) severity error;

            assert use_register_1 = '0'
            report print_bit_error("Using first register as ALU input must be off when not ALU", '0', use_register_1) severity error;

            assert use_register_2 = '0'
            report print_bit_error("Using second register as ALU input must be off when not ALU", '0', use_register_2) severity error;

            if instruction_opcode(EN_BRANCH) = '1' then
                assert use_branching_unit = '1'
                report print_bit_error("Branching unit must be enabled", '1', use_branching_unit) severity error;

                assert use_memory_for_register = '0'
                report print_bit_error("Using memory as register input must be off for branching", '0', use_memory_for_register) severity error;

                assert use_register_for_memory = '0'
                report print_bit_error("Using register as memory input must be off for branching", '0', use_register_for_memory) severity error;

                assert write_register = '1'
                report print_bit_error("Writing in register must be enabled for branching", '1', write_register) severity error;

                assert write_ram = '0'
                report print_bit_error("Writing in RAM must be disabled for branching", '0', write_ram) severity error;

                assert flag_address = flag_selector_variable
                report print_error("Wrong flag address for branching", flag_selector_variable, flag_address) severity error;

                assert register_address_write = REG_PC
                report print_error("Wrong register write address for branching", REG_PC, register_address_write) severity error;
            else
                assert use_memory_for_register = instruction_opcode(USE_MEM)
                report print_bit_error("Wrong use memory for register input enabling for storing", instruction_opcode(USE_MEM), use_memory_for_register) severity error;

                assert use_register_for_memory = instruction_opcode(USE_REG)
                report print_bit_error("Wrong use register for memory input enabling for storing", instruction_opcode(USE_REG), use_register_for_memory) severity error;

                assert use_branching_unit = '0'
                report print_bit_error("Branching unit must be disabled for storing", '0', use_branching_unit) severity error;

                assert write_register = instruction_opcode(STR_REG)
                report print_bit_error("Wrong write register for storing", instruction_opcode(STR_REG), write_register) severity error;

                assert write_ram = instruction_opcode(STR_MEM)
                report print_bit_error("Writing in RAM must be disabled for storing", instruction_opcode(STR_MEM), write_ram) severity error;

                assert flag_address = FLAG_C_ADDR
                report print_error("Wrong flag address for storing", FLAG_C_ADDR, flag_address) severity error;

                assert register_address_write = instruction_address(DATA_SIZE / 2 - 1 downto 0)
                report print_error("Wrong register write address for storing", instruction_b(DATA_SIZE / 2 - 1 downto 0), register_address_write) severity error;
            end if;
        end if;

        -- Update opcode
        if opcode_variable = 2 ** DATA_SIZE - 1 then
            report "End of tests" severity note;
            wait;
        else
            opcode_variable := opcode_variable + 1;
        end if;

        instruction_vector(4 * DATA_SIZE - 1 downto 3 * DATA_SIZE) <= std_logic_vector(to_unsigned(opcode_variable, DATA_SIZE));
    end process control_unit_process_test;

end architecture testbench;
