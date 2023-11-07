library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Package that contains all constants and types used for the CPU. It
-- is very useful to avoid duplication between either multiple design
-- units either between a design unit and its test bench.
package cpu_utils is
    constant BYTE_SIZE : natural := 8;  -- Size of a byte

    constant INSTRUCTION_SIZE       : natural := 32; -- Size of an instruction
    constant DATA_SIZE              : natural := 16; -- Size of an data (data includes register size, operand size, addresses size)
    constant ALU_SELECTOR_SIZE      : natural := 4; -- Size of the ALU selector
    constant REGISTER_SELECTOR_SIZE : natural := 4; -- Size of the register selector 
    constant FLAG_SELECTOR_SIZE     : natural := 2; -- Size of the flag selector

    constant REG_LR : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0) := "1110"; -- Register address of LR
    constant REG_PC : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0) := "1111"; -- Register address of PC

    constant CMP_OPCODE : std_logic_vector(7 downto 0) := x"1F"; -- Opcode of the CMP instruction

    constant FLAG_C : natural := 0;     -- Selector for C flag (carry)
    constant FLAG_Z : natural := 1;     -- Selector for Z flag (zero)
    constant FLAG_N : natural := 2;     -- Selector for N flag (negative)
    constant FLAG_O : natural := 3;     -- Selector for O flag (overflow)

    constant FLAG_C_ADDR : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0) := "00"; -- Address of Carry flag
    constant FLAG_Z_ADDR : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0) := "01"; -- Address of Zero flag
    constant FLAG_N_ADDR : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0) := "10"; -- Address of Negative flag
    constant FLAG_O_ADDR : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0) := "11"; -- Address of Overflow flag

    -- ALU opcode bits (still unused bit 7)
    -- TODO Bit that inputs the result of the ALU in the memory

    constant ALU_SEL_3 : natural := 6;  -- Bit representing the fourth ALU selector bit
    constant USE_REG_2 : natural := 5;  -- Bit representing the usage of the second register
    constant USE_REG_1 : natural := 4;  -- Bit representing the usage of the first register
    constant EN_ALU    : natural := 3;  -- Bit enabling the ALU
    constant ALU_SEL_2 : natural := 2;  -- Bit representing the third ALU selector bit
    constant ALU_SEL_1 : natural := 1;  -- Bit representing the second ALU selector bit
    constant ALU_SEL_0 : natural := 0;  -- Bit representing the first ALU selector bit

    -- Non branching opcode bits

    constant STR_MEM    : natural := 7; -- Bit enabling storage in the RAM memory
    constant STR_REG    : natural := 6; -- Bit enabling storage in the register bank
    constant USE_MEM    : natural := 5; -- Bit putting memory output to register input
    constant MEM_OFFSET : natural := 4; -- Bit putting register output to memory offset input
    constant USE_REG    : natural := 0; -- Bit putting register output to register input

    -- Branching opcodes bits

    constant FL_SEL_1       : natural := 7; -- Bit representing the usage of the second register
    constant FL_SEL_0       : natural := 6; -- Bit representing the usage of the first register
    constant USE_REG_OFFSET : natural := 5; -- Bit representing the usage of the second register for the offset
    constant USE_REG_ADDR   : natural := 4; -- Bit representing the usage of the first register for the address
    constant INV_FLAG       : natural := 2; -- Bit inverting flag test ('0' instead of '1')
    constant EN_BRANCH      : natural := 1; -- Bit representing the usage of the first register
    constant EN_REL_BRANCH  : natural := 0; -- Bit representing the usage of the first register

    -- Type used for memories
    type t_memory_array is array (natural range <>) of std_logic_vector(DATA_SIZE - 1 downto 0);
end package cpu_utils;
