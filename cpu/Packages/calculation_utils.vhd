library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.DATA_SIZE;

-- TODO Add documentation

package calculation_utils is
    constant result_size : natural := 2 * DATA_SIZE;
    subtype result_vector_t is std_logic_vector(result_size - 1 downto 0);
    subtype operand_vector_t is std_logic_vector(DATA_SIZE - 1 downto 0);

    -- Used as padding for calculations
    constant zero_signal : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');
    constant zero_result : std_logic_vector(result_size - 1  downto 0) := (others => '0');

    function "+"(a, b : operand_vector_t) return result_vector_t;
    function "+"(a : std_logic_vector; b : std_logic) return result_vector_t;

    function "-"(a, b : operand_vector_t) return result_vector_t;
    function "-"(a : std_logic_vector; b : std_logic) return result_vector_t;

    function "*"(a, b : operand_vector_t) return result_vector_t;

    function and_op(a, b : operand_vector_t) return result_vector_t;
    function or_op(a, b : operand_vector_t) return result_vector_t;
    function xor_op(a, b : operand_vector_t) return result_vector_t;
    function not_op(a : operand_vector_t) return result_vector_t;
    function cmp(a : operand_vector_t) return result_vector_t;

end package calculation_utils;

package body calculation_utils is
    -- Adds padding to the input std_logic_vector
    function add_padding(std_vector : std_logic_vector) return std_logic_vector is
    begin
        return zero_signal & std_vector;
    end function add_padding;

    function "+"(a, b : operand_vector_t) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := std_logic_vector(RESIZE(unsigned(add_padding(a)) + unsigned(add_padding(b)), result_size));
        return result;
    end function "+";

    function "+"(a : std_logic_vector; b : std_logic) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := std_logic_vector(RESIZE(unsigned(a) + b, result_size));
        return result;
    end function "+";

    function "-"(a, b : operand_vector_t) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := std_logic_vector(RESIZE(unsigned(add_padding(a)) - unsigned(add_padding(b)), result_size));
        return result;
    end function "-";

    function "-"(a : std_logic_vector; b : std_logic) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := std_logic_vector(RESIZE(unsigned(add_padding(a)) - b, result_size));
        return result;
    end function "-";

    function "*"(a, b : operand_vector_t) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := std_logic_vector(RESIZE(unsigned(a) * unsigned(b), result_size));
        return result;
    end function "*";

    function and_op(a, b : operand_vector_t) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := add_padding(a) and add_padding(b);
        return result;
    end function and_op;

    function or_op(a, b : operand_vector_t) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := add_padding(a) or add_padding(b);
        return result;
    end function or_op;

    function xor_op(a, b : operand_vector_t) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := add_padding(a) xor add_padding(b);
        return result;
    end function xor_op;

    function not_op(a : operand_vector_t) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := add_padding(not a);
        return result;
    end function not_op;

    function cmp(a : operand_vector_t) return result_vector_t is
        variable result : result_vector_t;
    begin
        result := add_padding(a);
        return result;
    end function cmp;

end package body calculation_utils;
