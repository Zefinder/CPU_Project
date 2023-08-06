library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is

    generic(
        data_size : positive := 8       -- Size of the operands and of the output
    );

    port(
        a, b     : in  std_logic_vector(data_size - 1 downto 0); -- Operand of the ALU 
        selector : in  std_logic_vector(2 downto 0); -- Selector of the operation to use
        c_in     : in  std_logic;       -- Input carry for addition and subtraction
        flags    : out std_logic_vector(3 downto 0); -- Output flags (in order: C, Z, N, O)
        output   : out std_logic_vector(data_size - 1 downto 0) -- Output of the ALU
    );
end entity alu;

architecture RTL of alu is

    constant C : natural := 0;          -- Selector for C flag (carry)
    constant Z : natural := 1;          -- Selector for Z flag (zero)
    constant N : natural := 2;          -- Selector for N flag (negative)
    constant O : natural := 3;          -- Selector for O flag (overflow)

    constant zero_signal : std_logic_vector(output'length - 1 downto 0) := (others => '0'); -- Used as padding for multiplication

    signal temp_output : std_logic_vector(2 * output'length - 1 downto 0);

    function add_padding(std_vector : std_logic_vector(data_size - 1 downto 0)) return std_logic_vector is
    begin
        return zero_signal & std_vector;
    end function add_padding;

begin

    alu_selection : with selector select temp_output <=
        std_logic_vector(unsigned(add_padding(a)) + unsigned(add_padding(b)) + c_in) when "000", -- Addition
        std_logic_vector(unsigned(add_padding(a)) - unsigned(add_padding(b)) - c_in) when "001", -- Subtraction
        std_logic_vector(unsigned(a) * unsigned(b)) when "010", -- Multiplication
        add_padding(a) and add_padding(b) when "011", -- Bitwise and
        add_padding(a) or add_padding(b) when "100", -- Bitwise or
        add_padding(a) xor add_padding(b) when "101", -- Bitwise xor
        add_padding(not a) when "110",  -- Bitwise not
        add_padding(a) when "111",      -- Comparation
        add_padding(zero_signal) when others;

    flags(C) <= '1' when temp_output(output'length) = '1' and selector /= "111" else
                '1' when temp_output(output'length - 1 downto 0) > zero_signal and temp_output(output'length - 1) /= '1' and selector = "111" else
                '0';

    flags(Z) <= '1' when temp_output(output'length - 1 downto 0) = zero_signal else
                '0';

    flags(N) <= '1' when temp_output(output'length - 1) = '1' else
                '0';

    flags(O) <= '1' when temp_output(2 * output'length - 1 downto output'length) /= zero_signal and selector /= "111" else
                '1' when temp_output(output'length - 1) /= '1' and selector = "111" else
                '0';

    output <= temp_output(output'length - 1 downto 0);

end architecture RTL;
