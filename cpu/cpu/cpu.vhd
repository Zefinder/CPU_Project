library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

-- This entity represents the global supercomponent CPU. It will instantiate all
-- components and is basically the top level of this project.
--
-- A few things must still be discussed with myself (or with Nicolas because he has good ideas) 
-- regarding the input and outputs. For the input, the best idea is to make an instruction memory
-- and an instruction loader. With this, it would just need to load a program in some place in
-- the CPU and then starts. It allows custom programs to be run on the CPU and it's not that hard
-- to make (bonus point!)
--
-- For the output, I think that pointing to the first register's output can be a good idea, 
-- like for functions in assembly where the result will be contained in `R0`.
entity cpu is
    port(
        -- Main clock
        clk                : in  std_logic;
        -- Main reset
        rst                : in  std_logic;
        -- Instruction vector (to maybe move elsewhere)
        instruction_vector : in  std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
        -- Output of the cpu (maybe to ask for next operation?)
        output             : out std_logic_vector(DATA_SIZE - 1 downto 0)
    );
end entity cpu;

architecture RTL of cpu is
    component control_unit
        port(
            instruction_vector                 : in  std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
            operand1                           : out std_logic_vector(DATA_SIZE - 1 downto 0);
            operand2                           : out std_logic_vector(DATA_SIZE - 1 downto 0);
            alu_selector                       : out std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
            register_address_read_1            : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_read_2            : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_read_3            : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_write             : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            flag_address                       : out std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
            use_alu                            : out std_logic;
            update_one_flag                    : out std_logic;
            use_register_1                     : out std_logic;
            use_register_2                     : out std_logic;
            use_register_for_register          : out std_logic;
            use_memory_for_register            : out std_logic;
            use_branching_unit                 : out std_logic;
            use_branching_offset               : out std_logic;
            use_register_for_branching_address : out std_logic;
            use_register_for_branching_offset  : out std_logic;
            branch_invert_flag                 : out std_logic;
            write_register                     : out std_logic;
            write_ram                          : out std_logic;
            use_ram_offset                     : out std_logic
        );
    end component control_unit;

    component alu
        port(
            a, b     : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            selector : in  std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
            c_in     : in  std_logic;
            flags    : out std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0);
            output   : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component alu;

    component flag_bank
        port(
            clk             : in  std_logic;
            rst             : in  std_logic;
            flag_selector   : in  std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
            input_flags     : in  std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0);
            update_flags    : in  std_logic;
            update_one_flag : in  std_logic;
            output_flag     : out std_logic
        );
    end component flag_bank;

    component register_bank
        port(
            clk                     : in  std_logic;
            rst                     : in  std_logic;
            register_address_read_1 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_read_2 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_read_3 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_write  : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_load           : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            write_register          : in  std_logic;
            register_output_1       : out std_logic_vector(DATA_SIZE - 1 downto 0);
            register_output_2       : out std_logic_vector(DATA_SIZE - 1 downto 0);
            register_output_3       : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component register_bank;

    component ram_memory
        port(
            clk        : in  std_logic;
            rst        : in  std_logic;
            write      : in  std_logic;
            use_offset : in  std_logic;
            address    : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            offset     : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            value_in   : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            value_out  : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component ram_memory;

    component branching_unit
        port(
            branching_address      : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            offset                 : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            use_offset             : in  std_logic;
            flag                   : in  std_logic;
            is_inverted_test       : in  std_logic;
            out_program_counter    : out std_logic_vector(DATA_SIZE - 1 downto 0);
            update_program_counter : out std_logic
        );
    end component branching_unit;

    for all : control_unit use entity work.control_unit(RTL);
    for all : alu use entity work.alu(RTL);
    for all : flag_bank use entity work.flag_bank(RTL);
    for all : register_bank use entity work.register_bank(RTL);
    for all : ram_memory use entity work.ram_memory(RTL);
    for all : branching_unit use entity work.branching_unit(RTL);

    -- Input operand of the ALU
    signal operand_1, operand_2                                                      : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output operand from the register for the ALU and RAM
    signal register_operand_1                                                        : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output operand from the register for the ALU
    signal register_operand_2                                                        : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output operand from the register for the RAM address
    signal register_operand_3                                                        : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output operand from the control unit for the ALU and RAM
    signal cu_operand_1                                                              : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output operand from the control unit for the ALU
    signal cu_operand_2                                                              : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Selector for the ALU
    signal alu_selector                                                              : std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
    -- Result flags after process from the ALU
    signal alu_flags_output                                                          : std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0);
    -- Output of the ALU
    signal alu_output                                                                : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Selector for flags
    signal flag_selector                                                             : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
    -- Address to read a register
    signal register_address_read_1, register_address_read_2, register_address_read_3 : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
    -- Address to write to a register
    signal register_address_write                                                    : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
    -- Data to load in a register
    signal register_load                                                             : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output of the RAM
    signal ram_output                                                                : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Branching address as branching unit input
    signal branching_address_input                                                   : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Branching address as branching unit output
    signal branching_address_output                                                  : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Data used as offset for branching address
    signal branching_offset                                                          : std_logic_vector(DATA_SIZE - 1 downto 0);

    -- Output of the flags
    signal flag_output                        : std_logic;
    -- Uses the result of the ALU
    signal use_alu                            : std_logic;
    -- Updates only one flag
    signal update_one_flag                    : std_logic;
    -- Uses the first register as an operand for the ALU or to load in the RAM
    signal use_register_1                     : std_logic;
    -- Uses the second register as an operand for the ALU or to load in the RAM
    signal use_register_2                     : std_logic;
    -- Uses the register output as register input
    signal use_register_for_register          : std_logic;
    -- Uses the output of the memory as data to load in the register
    signal use_memory_for_register            : std_logic;
    -- Enables writing in the register bank
    signal cu_write_register                  : std_logic;
    -- Enables writing in the register bank
    signal branch_write_register              : std_logic;
    -- Enables writing in the register bank
    signal write_register                     : std_logic;
    -- Enables writing in the RAM
    signal write_ram                          : std_logic;
    -- Enables RAM offset address
    signal use_ram_offset                     : std_logic;
    -- Enables branching unit
    signal use_branching_unit                 : std_logic;
    -- Uses offset for branching
    signal use_branching_offset               : std_logic;
    -- Inverts the test of the flag for branching test
    signal branch_invert_flag                 : std_logic;
    -- Uses the first register as branching address
    signal use_register_for_branching_address : std_logic;
    -- Uses the second register as branching offset
    signal use_register_for_branching_offset  : std_logic;

begin
    operand_1 <= register_operand_1 when use_register_1 = '1' else
                 cu_operand_1;

    operand_2 <= register_operand_2 when use_register_2 = '1' else
                 cu_operand_2;

    -- TODO Redo this condition for priority check
    register_load <= branching_address_output when use_branching_unit = '1' else
                     register_operand_1 when use_register_for_register = '1' else
                     ram_output when use_memory_for_register = '1' else
                     alu_output when use_alu = '1' else
                     register_operand_1 when use_register_for_register = '1' else
                     cu_operand_1;

    write_register <= branch_write_register when use_branching_unit = '1' else
                      cu_write_register;

    branching_address_input <= register_operand_1 when use_register_for_branching_address = '1' else
                               cu_operand_1;

    branching_offset <= register_operand_2 when use_register_for_branching_offset = '1' else
                        cu_operand_2;

    output <= alu_output;

    -- Instantiation of the control unit, it is linked to the ALU, register bank, 
    -- flag bank and RAM
    control_unit_inst : component control_unit
        port map(
            -- Vector of instruction
            instruction_vector                 => instruction_vector,
            -- First operand for the ALU
            operand1                           => cu_operand_1,
            -- Second operand for the ALU
            operand2                           => cu_operand_2,
            -- Selector of the ALU
            alu_selector                       => alu_selector,
            -- First address for the register to output
            register_address_read_1            => register_address_read_1,
            -- Second address for the register to output
            register_address_read_2            => register_address_read_2,
            -- Third address for the register to output
            register_address_read_3            => register_address_read_3,
            -- Addres for the register to write
            register_address_write             => register_address_write,
            -- Address for the flag to output
            flag_address                       => flag_selector,
            -- Enables the ALU
            use_alu                            => use_alu,
            -- Updates only one flag
            update_one_flag                    => update_one_flag,
            -- Enables the first register output
            use_register_1                     => use_register_1,
            -- Enables the second register output
            use_register_2                     => use_register_2,
            -- Uses register as register input
            use_register_for_register => use_register_for_register,
            -- Uses the memory as register input
            use_memory_for_register            => use_memory_for_register,
            -- Uses the branching output for register load
            use_branching_unit                 => use_branching_unit,
            -- Uses the branching offset
            use_branching_offset               => use_branching_offset,
            -- Uses the first register as branching address
            use_register_for_branching_address => use_register_for_branching_address,
            -- Uses the second register as branching offset
            use_register_for_branching_offset  => use_register_for_branching_offset,
            -- Tests if the flag is not set
            branch_invert_flag                 => branch_invert_flag,
            -- Enables writing in the register
            write_register                     => cu_write_register,
            -- Enables writing in the RAM
            write_ram                          => write_ram,
            -- Enables offset for RAM
            use_ram_offset                     => use_ram_offset
        );

    -- Instantiation of the ALU, it is linked to the flag and register banks and the RAM
    alu_inst : component alu
        port map(
            -- First operand of the ALU (chosen between control unit and register)
            a        => operand_1,
            -- Second operand of the ALU (chosen between control unit and register)
            b        => operand_2,
            -- Selector of the ALU
            selector => alu_selector,
            -- Input carry (don't forget to input the carry flag selector!)
            c_in     => flag_output,
            -- Output flags after ALU processing
            flags    => alu_flags_output,
            -- Output result of the ALU
            output   => alu_output
        );

    -- Instantiation of the flag bank, it is linked to the ALU
    flag_bank_inst : component flag_bank
        port map(
            -- Clock used to update the flags
            clk             => clk,
            -- Reset used to put flags to 0
            rst             => rst,
            -- Selector of the flags
            flag_selector   => flag_selector,
            -- Input flags to update
            input_flags     => alu_flags_output,
            -- Enables flag update
            update_flags    => use_alu,
            -- Updates only one flag
            update_one_flag => update_one_flag,
            -- Output the flag chosen by the selector
            output_flag     => flag_output
        );

    -- Instantiation of the register bank, it is linked to the ALU and the RAM memory
    register_bank_inst : component register_bank
        port map(
            -- Clock used to update the register
            clk                     => clk,
            -- Reset used to put register to 0
            rst                     => rst,
            -- Address for the first output
            register_address_read_1 => register_address_read_1,
            -- Address for the second output
            register_address_read_2 => register_address_read_2,
            -- Address for the third output
            register_address_read_3 => register_address_read_3,
            -- Address for writing in the register bank
            register_address_write  => register_address_write,
            -- Data to write in the register bank 
            register_load           => register_load,
            -- Enables writing in the register
            write_register          => write_register,
            -- First register output
            register_output_1       => register_operand_1,
            -- Second register output
            register_output_2       => register_operand_2,
            -- Third register output
            register_output_3       => register_operand_3
        );

    -- Instantiation of the RAM, it is linked to the register bank
    ram_memory_inst : component ram_memory
        port map(
            -- Clock used to update RAM cells
            clk        => clk,
            -- Reset used to put all memory to 0
            rst        => rst,
            -- Enables writing in the RAM
            write      => write_ram,
            -- Enables offset for address
            use_offset => use_ram_offset,
            -- Address of cell to write or to read
            address    => register_operand_3,
            -- Value of the offset
            offset     => register_operand_2,
            -- Data to write in the RAM
            value_in   => register_operand_1,
            -- Output of the RAM
            value_out  => ram_output
        );

    branching_unit_inst : component branching_unit
        port map(
            branching_address      => branching_address_input,
            offset                 => branching_offset,
            use_offset             => use_branching_offset,
            flag                   => flag_output,
            is_inverted_test       => branch_invert_flag,
            out_program_counter    => branching_address_output,
            update_program_counter => branch_write_register
        );

end architecture RTL;
