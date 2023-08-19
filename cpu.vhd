library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

-- This entity represents the global supercomponent CPU. It will instantiate all
-- generics of all defined components and is basically the top level of this project.
--
-- A few things must still be discussed with myself (or with Nicolas because he has good ideas) 
-- regarding the input and outputs. For the input, I would be suggesting to make an instruction
-- memory in the CPU as a cached program but it will be impossible to make tests on it without
-- modifying directly the component and the constant array of instructions.
--
-- For the output, I think that pointing to the first register's output can be a good idea, 
-- like for functions in assembly where the result will be contained in `R0`.
entity cpu is
    port(
        -- Main clock
        clk                : in  std_logic;
        -- Instruction vector (to maybe move elsewhere)
        instruction_vector : in  std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
        -- Output of the cpu (maybe to ask for next operation?)
        output             : out std_logic_vector(DATA_SIZE - 1 downto 0)
    );
end entity cpu;

architecture RTL of cpu is
    component control_unit
        port(
            instruction_vector      : in  std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
            operand1                : out std_logic_vector(DATA_SIZE - 1 downto 0);
            operand2                : out std_logic_vector(DATA_SIZE - 1 downto 0);
            alu_selector            : out std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
            register_address_read_1 : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_read_2 : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_write  : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            flag_address            : out std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
            ram_address             : out std_logic_vector(DATA_SIZE - 1 downto 0);
            use_alu                 : out std_logic;
            use_register_1          : out std_logic;
            use_register_2          : out std_logic;
            use_memory_for_register : out std_logic;
            use_register_for_memory : out std_logic;
            write_register          : out std_logic;
            write_ram               : out std_logic
        );
    end component control_unit;

    component alu
        port(
            a, b     : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            selector : in  std_logic_vector(2 downto 0);
            c_in     : in  std_logic;
            flags    : out std_logic_vector(3 downto 0);
            output   : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component alu;

    component flag_bank
        port(
            clk           : in  std_logic;
            flag_selector : in  std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
            input_flags   : in  std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0);
            update_flags  : in  std_logic;
            output_flag   : out std_logic
        );
    end component flag_bank;

    component register_bank
        port(
            clk                     : in  std_logic;
            register_address_read_1 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_read_2 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_write  : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_load           : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            write_register          : in  std_logic;
            register_output_1       : out std_logic_vector(DATA_SIZE - 1 downto 0);
            register_output_2       : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component register_bank;

    component ram_memory
        port(
            clk       : in  std_logic;
            write     : in  std_logic;
            address   : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            value_in  : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            value_out : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component ram_memory;

    for all : control_unit use entity work.control_unit(RTL);
    for all : alu use entity work.alu(RTL);
    for all : flag_bank use entity work.flag_bank(RTL);
    for all : register_bank use entity work.register_bank(RTL);
    for all : ram_memory use entity work.ram_memory(RTL);

    -- Input operand of the ALU
    signal operand_1, operand_2                             : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output operand from the register for the ALU and RAM
    signal register_operand_1                               : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output operand from the register for the ALU
    signal register_operand_2                               : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output operand from the control unit for the ALU and RAM
    signal cu_operand_1                                     : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output operand from the control unit for the ALU
    signal cu_operand_2                                     : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Selector for the ALU
    signal alu_selector                                     : std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
    -- Result flags after process from the ALU
    signal alu_flags_output                                 : std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0);
    -- Output of the ALU
    signal alu_output                                       : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Selector for flags
    signal flag_selector                                    : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
    -- Address to read a register
    signal register_address_read_1, register_address_read_2 : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
    -- Address to write to a register
    signal register_address_write                           : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
    -- Data to load in a register
    signal register_load                                    : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Address to read or write in the RAM
    signal ram_address                                      : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Output of the RAM
    signal ram_output                                       : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Data to load in the RAM
    signal ram_load                                         : std_logic_vector(DATA_SIZE - 1 downto 0);

    -- Output of the flags
    signal flag_output             : std_logic;
    -- Uses the result of the ALU
    signal use_alu                 : std_logic;
    -- Uses the first register as an operand for the ALU or to load in the RAM
    signal use_register_1          : std_logic;
    -- Uses the second register as an operand for the ALU or to load in the RAM
    signal use_register_2          : std_logic;
    -- Uses the output of the memory as data to load in the register
    signal use_memory_for_register : std_logic;
    -- Uses the output of the register as data to load in the RAM
    signal use_register_for_memory : std_logic;
    -- Enables writing in the register bank
    signal write_register          : std_logic;
    -- Enables writing in the RAM
    signal write_ram               : std_logic;

begin

    operand_1 <= cu_operand_1 when use_register_1 = '1' else
                 register_operand_1;

    operand_2 <= cu_operand_2 when use_register_2 = '1' else
                 register_operand_2;

    register_load <= ram_output when use_memory_for_register = '1' else
                     cu_operand_1 when use_alu = '0' else
                     alu_output;

    ram_load <= register_operand_1 when use_register_for_memory = '1' else
                cu_operand_1 when use_alu = '0' else
                alu_output;

    output <= alu_output;

    -- Instantiation of the control unit, it is linked to the ALU, register bank, 
    -- flag bank and RAM
    control_unit_inst : component control_unit
        port map(
            -- Vector of instruction
            instruction_vector      => instruction_vector,
            -- First operand for the ALU
            operand1                => cu_operand_1,
            -- Second operand for the ALU
            operand2                => cu_operand_2,
            -- Selector of the ALU
            alu_selector            => alu_selector,
            -- First address for the register to output
            register_address_read_1 => register_address_read_1,
            -- Second address for the register to output
            register_address_read_2 => register_address_read_2,
            -- Addres for the register to write
            register_address_write  => register_address_write,
            -- Address for the flag to output
            flag_address            => flag_selector,
            -- Address for the RAM
            ram_address             => ram_address,
            -- Enables the ALU
            use_alu                 => use_alu,
            -- Enables the first register output
            use_register_1          => use_register_1,
            -- Enables the second register output
            use_register_2          => use_register_2,
            -- Uses the memory as register input
            use_memory_for_register => use_memory_for_register,
            -- Uses the register as memory input
            use_register_for_memory => use_register_for_memory,
            -- Enables writing in the register
            write_register          => write_register,
            -- Enables writing in the RAM
            write_ram               => write_ram
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

    -- Instantiation of the flag bank, it is linked to the ALU (TODO jump unit)
    flag_bank_inst : component flag_bank
        port map(
            -- Clock used to update the flags
            clk           => clk,
            -- Selector of the flags
            flag_selector => flag_selector,
            -- Input flags to update
            input_flags   => alu_flags_output,
            -- Enables flag update
            update_flags  => use_alu,
            -- Output the flag chosen by the selector
            output_flag   => flag_output
        );

    -- Instantiation of the register bank, it is linked to the ALU and the RAM memory
    register_bank_inst : component register_bank
        port map(
            -- Clock used to update the register
            clk                     => clk,
            -- Address for the first output
            register_address_read_1 => register_address_read_1,
            -- Address for the second output
            register_address_read_2 => register_address_read_2,
            -- Address for writing in the register bank
            register_address_write  => register_address_write,
            -- Data to write in the register bank 
            register_load           => register_load,
            -- Enables writing in the register
            write_register          => write_register,
            -- First register output
            register_output_1       => register_operand_1,
            -- Second register output
            register_output_2       => register_operand_2
        );

    -- Instantiation of the RAM, it is linked to the register bank
    ram_memory_inst : component ram_memory
        port map(
            -- Clock used to update RAM cells
            clk       => clk,
            -- Enables writing in the RAM
            write     => write_ram,
            -- Address of cell to write or to read
            address   => ram_address,
            -- Data to write in the RAM
            value_in  => ram_load,
            -- Output of the RAM
            value_out => ram_output
        );

end architecture RTL;
