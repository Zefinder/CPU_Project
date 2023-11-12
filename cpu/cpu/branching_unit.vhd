library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

entity branching_unit is
    port(
        -- Branch address to maybe update before outputing it
        branching_address      : in  std_logic_vector(DATA_SIZE - 1 downto 0);
        -- Offset to apply to the branching address
        offset                 : in  std_logic_vector(BYTE_SIZE - 1 downto 0);
        -- Uses the offset to modify the branching address
        use_offset             : in  std_logic;
        -- Flag in to check
        flag                   : in  std_logic;
        -- Indicate that we want to check if the flag is 0
        is_inverted_test       : in  std_logic;
        -- Output branching address
        out_program_counter    : out std_logic_vector(DATA_SIZE - 1 downto 0);
        -- Enables writing in the program counter
        update_program_counter : out std_logic
    );
end entity branching_unit;

architecture RTL of branching_unit is
    -- Temporary branching address
    signal tmp_branching_address : std_logic_vector(DATA_SIZE - 1 downto 0);
begin
    -- Flag xor inverted = '1' means that we update
    update_program_counter <= is_inverted_test xor flag;
    out_program_counter   <= tmp_branching_address(DATA_SIZE - 1 downto 0);
    tmp_branching_address <= std_logic_vector(unsigned(branching_address) + unsigned(offset)) when use_offset = '1' else
            branching_address;
    
end architecture RTL;
