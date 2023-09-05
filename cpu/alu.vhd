library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

entity alu is
    port(
        a, b     : in  std_logic_vector(DATA_SIZE - 1 downto 0); -- Operand of the ALU 
        selector : in  std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0); -- Selector of the operation to use
        c_in     : in  std_logic;       -- Input carry for addition and subtraction
        flags    : out std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0); -- Output flags (in order: C, Z, N, O)
        output   : out std_logic_vector(DATA_SIZE - 1 downto 0) -- Output of the ALU
    );
end entity alu;

architecture RTL of alu is
    -- Used as padding for multiplication
    constant zero_signal : std_logic_vector(output'length - 1 downto 0) := (others => '0');

    -- Result of operations of the ALU. Bigger than output since multiplication 
    -- can go to 2 times the size of the input
    signal temp_output : std_logic_vector(2 * output'length - 1 downto 0);

    -- Adds padding to the input std_logic_vector
    function add_padding(std_vector : std_logic_vector(DATA_SIZE - 1 downto 0)) return std_logic_vector is
    begin
        return zero_signal & std_vector;
    end function add_padding;

begin

    alu_selection : with selector select temp_output <=
        std_logic_vector(unsigned(add_padding(a)) + unsigned(add_padding(b)) + c_in) when "0000", -- Addition
        std_logic_vector(unsigned(add_padding(a)) - unsigned(add_padding(b)) - c_in) when "0001", -- Subtraction
        std_logic_vector(unsigned(a) * unsigned(b)) when "0010", -- Multiplication
        add_padding(a) and add_padding(b) when "0011", -- Bitwise and
        add_padding(a) or add_padding(b) when "0100", -- Bitwise or
        add_padding(a) xor add_padding(b) when "0101", -- Bitwise xor
        add_padding(not a) when "0110",  -- Bitwise not
        add_padding(a) when "0111",      -- Comparation
        add_padding(zero_signal) when others;

    flags(FLAG_C) <= '1' when selector = "1000" else
                     '0' when selector = "1100" else
                     '1' when temp_output(output'length) = '1' and selector /= "0111" else
                     '1' when temp_output(output'length - 1 downto 0) > zero_signal and temp_output(output'length - 1) /= '1' and selector = "0111" else
                     '0';

    flags(FLAG_Z) <= '1' when selector = "1001" else
                     '0' when selector = "1101" else
                     '1' when temp_output(output'length - 1 downto 0) = zero_signal else
                     '0';

    flags(FLAG_N) <= '1' when selector = "1010" else
                     '0' when selector = "1110" else
                     '1' when temp_output(output'length - 1) = '1' else
                     '0';

    flags(FLAG_O) <= '1' when selector = "1011" else
                     '0' when selector = "1111" else
                     '1' when temp_output(2 * output'length - 1 downto output'length) /= zero_signal and selector /= "0111" else
                     '1' when temp_output(output'length - 1) /= '1' and selector = "0111" else
                     '0';

    output <= temp_output(output'length - 1 downto 0);

end architecture RTL;
