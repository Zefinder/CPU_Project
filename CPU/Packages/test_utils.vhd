library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

package test_utils is
    function print_error(context_message : string; expected, got : std_logic_vector) return string;
    function print_bit_error(context_message : string; expected, got : std_logic) return string;
end package test_utils;

package body test_utils is
    function logic_to_string(logic : std_logic) return string is
        variable x01_logic     : X01;
        variable return_string : string(1 to 1);
    begin
        x01_logic := X01(logic);
        case x01_logic is
            when '0' => return_string := "0";
            when '1' => return_string := "1";
            when 'X' => return_string := "X";
        end case;

        return return_string;
    end logic_to_string;

    function print_error(context_message : string; expected, got : std_logic_vector) return string is
    begin
        return "Error: " & context_message & ", expected 0x" & to_hstring(expected) & " but got 0x" & to_hstring(got);
    end print_error;

    function print_bit_error(context_message : string; expected, got : std_logic) return string is
    begin
        return "Error: " & context_message & ", expected " & logic_to_string(expected) & " but got " & logic_to_string(got);
    end print_bit_error;

end package body test_utils;
