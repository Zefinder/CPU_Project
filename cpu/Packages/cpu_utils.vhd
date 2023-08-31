library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cpu_utils is
    constant INSTRUCTION_SIZE       : natural := 32; -- Size of an instruction
    constant DATA_SIZE              : natural := 8;  -- Size of an data (data includes register size, operand size, addresses size)
    constant ALU_SELECTOR_SIZE      : natural := 4;  -- Size of the ALU selector
    constant REGISTER_SELECTOR_SIZE : natural := 4;  -- Size of the register selector
    constant FLAG_SELECTOR_SIZE     : natural := 2;  -- Size of the flag selector
    
    constant REG_LR : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0) := "1110";
    constant REG_PC : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0) := "1111";

    constant CMP_OPCODE : std_logic_vector(7 downto 0) := x"1F";

    constant FLAG_C : natural := 0;     -- Selector for C flag (carry)
    constant FLAG_Z : natural := 1;     -- Selector for Z flag (zero)
    constant FLAG_N : natural := 2;     -- Selector for N flag (negative)
    constant FLAG_O : natural := 3;     -- Selector for O flag (overflow)

    constant FLAG_C_ADDR : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0) := "00"; -- Address of Carry flag
    constant FLAG_Z_ADDR : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0) := "01"; -- Address of Zero flag
    constant FLAG_N_ADDR : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0) := "10"; -- Address of Negative flag
    constant FLAG_O_ADDR : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0) := "11"; -- Address of Overflow flag
end package cpu_utils;
