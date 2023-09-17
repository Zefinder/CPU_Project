library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.DATA_SIZE;

-- Package that contains all operations for the ALU so the code is may more readable.
-- Operator overload for logic operators are apparently not possible since I still 
-- need to use their old form and it's detected as a recursive function (if someone
-- has an idea to call the standard logical operators, please tell how)
--
-- All ALU operations that have been implemented here are:
-- - "+" (including between std_logic_vector and std_logic)
-- - "-" (including between std_logic_vector and std_logic)
-- - "*"
-- - and
-- - or
-- - xor
-- - not
-- - cmp (compare)
--
-- All operations return a *result_vector_t* which is simply an std_logic_vector with
-- the size of the biggest possible vector after an operation (here "*"). Most of 
-- operations take a *operand_vector_t* which is simply a std_logic_vector with a size
-- of *DATA_SIZE* declared in *cpu_utils*
package calculation_utils is
    -- Size of the resulting vector
    constant result_size : natural := 2 * DATA_SIZE;
    -- Vector type of an ALU result operation
    subtype result_vector_t is std_logic_vector(result_size - 1 downto 0);
    -- Vector type of an ALU operand
    subtype operand_vector_t is std_logic_vector(DATA_SIZE - 1 downto 0);

    -- Used as padding for calculations
    constant zero_signal : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');
    -- The constant 0 result for non-calculation ALU operands
    constant zero_result : std_logic_vector(result_size - 1  downto 0) := (others => '0');

    -- The overloaded + operator for two *operand_vector_t*
    function "+"(a, b : operand_vector_t) return result_vector_t;
    -- The overloaded + operator for an *std_logic_vector* and a std_logic
    function "+"(a : std_logic_vector; b : std_logic) return result_vector_t;

    -- The overloaded - operator for two *operand_vector_t*
    function "-"(a, b : operand_vector_t) return result_vector_t;
    -- The overloaded + operator for an *std_logic_vector* and a std_logic
    function "-"(a : std_logic_vector; b : std_logic) return result_vector_t;

    -- The overloaded \* operator for two *operand_vector_t*
    function "*"(a, b : operand_vector_t) return result_vector_t;

    -- The "overloaded" and operator for two *operand_vector_t*
    function and_op(a, b : operand_vector_t) return result_vector_t;
    -- The "overloaded" or operator for two *operand_vector_t*
    function or_op(a, b : operand_vector_t) return result_vector_t;
    -- The "overloaded" xor operator for two *operand_vector_t*
    function xor_op(a, b : operand_vector_t) return result_vector_t;
    -- The "overloaded" not operator for an *operand_vector_t*
    function not_op(a : operand_vector_t) return result_vector_t;
    -- The cmp operation for an *operand_vector_t*
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
