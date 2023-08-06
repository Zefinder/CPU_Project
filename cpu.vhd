library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        -- Main clock
        clk                : in  std_logic;
        -- Instruction vector (to maybe move elsewhere)
        instruction_vector : in  std_logic_vector(31 downto 0);
        -- Output of the cpu (maybe to ask for next operation?)
        output             : out std_logic_vector(7 downto 0)
    );
end entity cpu;

architecture RTL of cpu is

    -- Size of an instruction (must be a multiple of 4)
    constant instruction_size       : natural := instruction_vector'length;
    -- Size of a data (address or data)
    constant data_size              : natural := output'length;
    -- Size of the ALU selector
    constant alu_selector_size      : natural := 3;
    -- Size of the register selector
    constant register_selector_size : natural := 4;
    -- Size of the flag selector
    constant flag_selector_size     : natural := 2;

    component control_unit
        generic(
            instruction_size       : natural := 32;
            data_size              : natural := 8;
            alu_selector_size      : natural := 3;
            register_selector_size : natural := 4;
            flag_selector_size     : natural := 2
        );
        port(
            instruction_vector      : in  std_logic_vector(instruction_size - 1 downto 0);
            operand1                : out std_logic_vector(data_size - 1 downto 0);
            operand2                : out std_logic_vector(data_size - 1 downto 0);
            alu_selector            : out std_logic_vector(alu_selector_size - 1 downto 0);
            register_address_read_1 : out std_logic_vector(register_selector_size - 1 downto 0);
            register_address_read_2 : out std_logic_vector(register_selector_size - 1 downto 0);
            register_address_write  : out std_logic_vector(register_selector_size - 1 downto 0);
            flag_address            : out std_logic_vector(flag_selector_size - 1 downto 0);
            ram_address             : out std_logic_vector(data_size - 1 downto 0);
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
        generic(data_size : positive := 8);
        port(
            a, b     : in  std_logic_vector(data_size - 1 downto 0);
            selector : in  std_logic_vector(2 downto 0);
            c_in     : in  std_logic;
            flags    : out std_logic_vector(3 downto 0);
            output   : out std_logic_vector(data_size - 1 downto 0)
        );
    end component alu;

    component flag_bank
        generic(flag_selector_size : natural := 2);
        port(
            clk           : in  std_logic;
            flag_selector : in  std_logic_vector(flag_selector_size - 1 downto 0);
            input_flags   : in  std_logic_vector(2 ** flag_selector_size - 1 downto 0);
            update_flags  : in  std_logic;
            output_flag   : out std_logic
        );
    end component flag_bank;

    component register_bank
        generic(
            data_size              : natural := 8;
            register_selector_size : natural := 4
        );
        port(
            clk                     : in  std_logic;
            register_address_read_1 : in  std_logic_vector(register_selector_size - 1 downto 0);
            register_address_read_2 : in  std_logic_vector(register_selector_size - 1 downto 0);
            register_address_write  : in  std_logic_vector(register_selector_size - 1 downto 0);
            register_load           : in  std_logic_vector(data_size - 1 downto 0);
            write_register          : in  std_logic;
            register_output_1       : out std_logic_vector(data_size - 1 downto 0);
            register_output_2       : out std_logic_vector(data_size - 1 downto 0)
        );
    end component register_bank;

    component ram_memory
        generic(
            data_size : natural := 8
        );
        port(
            clk       : in  std_logic;
            write     : in  std_logic;
            address   : in  std_logic_vector(data_size - 1 downto 0);
            value_in  : in  std_logic_vector(data_size - 1 downto 0);
            value_out : out std_logic_vector(data_size - 1 downto 0)
        );
    end component ram_memory;

    for all : control_unit use entity work.control_unit(RTL);
    for all : alu use entity work.alu(RTL);
    for all : flag_bank use entity work.flag_bank(RTL);
    for all : register_bank use entity work.register_bank(RTL);
    for all : ram_memory use entity work.ram_memory(RTL);

    -- Input operand of the ALU
    signal operand_1, operand_2                             : std_logic_vector(data_size - 1 downto 0);
    -- Output operand from the register for the ALU and RAM
    signal register_operand_1                               : std_logic_vector(data_size - 1 downto 0);
    -- Output operand from the register for the ALU
    signal register_operand_2                               : std_logic_vector(data_size - 1 downto 0);
    -- Output operand from the control unit for the ALU and RAM
    signal cu_operand_1                                     : std_logic_vector(data_size - 1 downto 0);
    -- Output operand from the control unit for the ALU
    signal cu_operand_2                                     : std_logic_vector(data_size - 1 downto 0);
    -- Selector for the ALU
    signal alu_selector                                     : std_logic_vector(alu_selector_size - 1 downto 0);
    -- Result flags after process from the ALU
    signal alu_flags_output                                 : std_logic_vector(2 ** flag_selector_size - 1 downto 0);
    -- Output of the ALU
    signal alu_output                                       : std_logic_vector(data_size - 1 downto 0);
    -- Selector for flags
    signal flag_selector                                    : std_logic_vector(flag_selector_size - 1 downto 0);
    -- Address to read a register
    signal register_address_read_1, register_address_read_2 : std_logic_vector(register_selector_size - 1 downto 0);
    -- Address to write to a register
    signal register_address_write                           : std_logic_vector(register_selector_size - 1 downto 0);
    -- Data to load in a register
    signal register_load                                    : std_logic_vector(data_size - 1 downto 0);
    -- Address to read or write in the RAM
    signal ram_address                                      : std_logic_vector(data_size - 1 downto 0);
    -- Output of the RAM
    signal ram_output                                       : std_logic_vector(data_size - 1 downto 0);
    -- Data to load in the RAM
    signal ram_load                                         : std_logic_vector(data_size - 1 downto 0);

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
                     alu_output;

    ram_load <= register_operand_1 when use_register_for_memory = '1' else
                alu_output;

    output <= alu_output;

    control_unit_inst : component control_unit
        generic map(
            -- Size of an instruction
            instruction_size       => instruction_size,
            -- Size of data and addresses
            data_size              => data_size,
            -- Size of the ALU selector
            alu_selector_size      => alu_selector_size,
            -- Size of the register selector
            register_selector_size => register_selector_size,
            -- Size of the flag selector
            flag_selector_size     => flag_selector_size
        )
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

    alu_inst : component alu
        generic map(
            -- Size of data and addresses
            data_size => data_size
        )
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

    flag_bank_inst : component flag_bank
        generic map(
            -- Size of the flag selector
            flag_selector_size => flag_selector_size
        )
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

    register_bank_inst : component register_bank
        generic map(
            -- Size of data
            data_size              => data_size,
            -- Size of register selector
            register_selector_size => register_selector_size
        )
        port map(
            clk                     => clk,
            register_address_read_1 => register_address_read_1,
            register_address_read_2 => register_address_read_2,
            register_address_write  => register_address_write,
            register_load           => register_load,
            write_register          => write_register,
            register_output_1       => register_operand_1,
            register_output_2       => register_operand_2
        );

    ram_memory_inst : component ram_memory
        generic map(
            data_size => data_size
        )
        port map(
            clk       => clk,
            write     => write_ram,
            address   => ram_address,
            value_in  => ram_load,
            value_out => ram_output
        );

end architecture RTL;
