library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    generic(
        -- Size of an instruction
        instruction_size       : natural := 32;
        -- Size of an data (data includes register size, operand size, addresses size)
        data_size              : natural := 8;
        -- Size of the ALU selector
        alu_selector_size      : natural := 3;
        -- Size of the register selector
        register_selector_size : natural := 4;
        -- Size of the flag selector
        flag_selector_size     : natural := 2
    );
    port(
        -- Contains the instruction
        instruction_vector      : in  std_logic_vector(instruction_size - 1 downto 0);
        -- First operand to give to the ALU
        operand1                : out std_logic_vector(data_size - 1 downto 0);
        -- Second operand to give to the ALU
        operand2                : out std_logic_vector(data_size - 1 downto 0);
        -- Selector of the ALU
        alu_selector            : out std_logic_vector(alu_selector_size - 1 downto 0);
        -- Address used to read a register (sends it to the first operand of the ALU)
        register_address_read_1 : out std_logic_vector(register_selector_size - 1 downto 0);
        -- Address used to read a register (sends it to the second operand of the ALU)
        register_address_read_2 : out std_logic_vector(register_selector_size - 1 downto 0);
        -- Address used to write in a register
        register_address_write  : out std_logic_vector(register_selector_size - 1 downto 0);
        -- Address used to read a flag
        flag_address            : out std_logic_vector(flag_selector_size - 1 downto 0);
        -- Address used to read in the RAM
        ram_address             : out std_logic_vector(data_size - 1 downto 0);
        -- Uses the result of the ALU
        use_alu                 : out std_logic;
        -- Uses the content of a register and outputs it to the first output (specified by __register_address_read_1__)
        use_register_1          : out std_logic;
        -- Uses the content of a register and outputs it to the second output (specified by __register_address_read_2__)
        use_register_2          : out std_logic;
        -- Uses the content of the memory cell for the input of the register bank (specified by __memory_address_read__)
        use_memory_for_register : out std_logic;
        -- Uses the content of the register for the input of the memory (specified by __register_address_read_1__)
        use_register_for_memory : out std_logic;
        -- Indicate if the register at address __register_address_write__ must be written
        write_register          : out std_logic;
        -- Indicate if the ram memory cell at address __ram_address_write__ must be written
        write_ram               : out std_logic
    );
end entity control_unit;

architecture RTL of control_unit is

begin

end architecture RTL;
