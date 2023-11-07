library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;
use utils.test_utils.all;

entity alu_test is
end entity alu_test;

architecture testbench of alu_test is
    component alu
        port(
            a, b     : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            selector : in  std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
            c_in     : in  std_logic;
            flags    : out std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0);
            output   : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component alu;
    for all : alu use entity work.alu(RTL);

    constant zero_vector : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');

    signal a, b     : std_logic_vector(DATA_SIZE - 1 downto 0)         := (others => '0');
    signal selector : std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0) := (others => '0');
    signal c_in     : std_logic                                        := '0';
    signal flags    : std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0);
    signal output   : std_logic_vector(DATA_SIZE - 1 downto 0);

    function report_error(arg_a, arg_b : std_logic_vector(DATA_SIZE - 1 downto 0); arg_c_in : std_logic; expected, got : std_logic_vector(DATA_SIZE - 1 downto 0)) return string is
        constant hex_a        : string(1 to 1 + ((DATA_SIZE - 1) / 4)) := to_hstring(arg_a);
        constant hex_b        : string(1 to 1 + ((DATA_SIZE - 1) / 4)) := to_hstring(arg_b);
        constant hex_expected : string(1 to 1 + ((DATA_SIZE - 1) / 4)) := to_hstring(expected);
        constant hex_got      : string(1 to 1 + ((DATA_SIZE - 1) / 4)) := to_hstring(got);

        variable val_c_in : string(1 to 1);
    begin
        if arg_c_in = '1' then
            val_c_in := "1";
        else
            val_c_in := "0";
        end if;

        return "a=0x" & hex_a & ", b=0x" & hex_b & ", c_in=0b" & val_c_in & ", expected 0x" & hex_expected & " but got 0x" & hex_got;
    end function report_error;

begin

    alu_inst : component alu
        port map(
            a        => a,
            b        => b,
            selector => selector,
            c_in     => c_in,
            flags    => flags,
            output   => output
        );

    alu_process : process is
        variable init : natural := 0;

        variable value_sel        : natural   := 0;
        variable value_a, value_b : natural   := 0;
        variable value_c_in       : std_logic := '0';
        variable int_value_c_in   : natural   := 0;

        variable result        : integer := 0;
        variable result_vector : std_logic_vector(DATA_SIZE - 1 downto 0);
    begin
        -- Test if needs init
        if init = 0 then
            init     := 1;
            a        <= (others => '0');
            b        <= (others => '0');
            selector <= (others => '0');
            c_in     <= '0';

            report "Begin tests for alu (selector=0)" severity note;
            wait for 10 ns;
        else
            -- Test old value 
            case value_sel is
                when 0 =>
                    result := value_a + value_b + int_value_c_in;
                    assert output = std_logic_vector(to_unsigned(result mod 2 ** DATA_SIZE, DATA_SIZE))
                    report "Error '+': " & report_error(arg_a    => a,
                                                        arg_b    => b,
                                                        arg_c_in => c_in,
                                                        expected => std_logic_vector(to_unsigned(value_a + value_b + int_value_c_in, DATA_SIZE)),
                                                        got      => output
                                                       ) severity error;

                    if result > 2 ** DATA_SIZE - 1 then
                        assert flags(FLAG_C) = '1' report "Error '+': overflow, expected Carry flag C on" severity error;
                        assert flags(FLAG_O) = '1' report "Error '+': overflow, expected Overflow flag O on" severity error;
                    else
                        assert flags(FLAG_C) = '0' report "Error '+': expected Carry flag C off" severity error;
                        assert flags(FLAG_O) = '0' report "Error '+': expected Overflow flag O off" severity error;
                    end if;

                    if result mod 2 ** DATA_SIZE = 0 then
                        assert flags(FLAG_Z) = '1' report "Error '+': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(FLAG_Z) = '0' report "Error '+': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result mod 2 ** DATA_SIZE >= 2 ** (DATA_SIZE - 1) then
                        assert flags(FLAG_N) = '1' report "Error '+': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(FLAG_N) = '0' report "Error '+': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 1 =>
                    result := value_a - value_b - int_value_c_in;

                    assert output = std_logic_vector(to_unsigned(result mod 2 ** DATA_SIZE, DATA_SIZE))
                    report "Error '-': " & report_error(arg_a    => a,
                                                        arg_b    => b,
                                                        arg_c_in => c_in,
                                                        expected => std_logic_vector(to_unsigned(value_a - value_b - int_value_c_in, DATA_SIZE)),
                                                        got      => output
                                                       ) severity error;

                    if result > 2 ** DATA_SIZE - 1 or result < 0 then
                        assert flags(FLAG_C) = '1' report "Error '-': overflow, expected Carry flag C on" severity error;
                        assert flags(FLAG_O) = '1' report "Error '-': overflow, expected Overflow flag O on" severity error;
                    else
                        assert flags(FLAG_C) = '0' report "Error '-': expected Carry flag C off" severity error;
                        assert flags(FLAG_O) = '0' report "Error '-': expected Overflow flag O off" severity error;
                    end if;

                    if result mod 2 ** DATA_SIZE = 0 then
                        assert flags(FLAG_Z) = '1' report "Error '-': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(FLAG_Z) = '0' report "Error '-': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result mod 2 ** DATA_SIZE >= 2 ** (DATA_SIZE - 1) then
                        assert flags(FLAG_N) = '1' report "Error '-': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(FLAG_N) = '0' report "Error '-': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 2 =>
                    result := value_a * value_b;

                    assert output = std_logic_vector(to_unsigned(result mod 2 ** DATA_SIZE, DATA_SIZE))
                    report "Error '*': " & report_error(arg_a    => a,
                                                        arg_b    => b,
                                                        arg_c_in => c_in,
                                                        expected => std_logic_vector(to_unsigned(value_a * value_b, DATA_SIZE)),
                                                        got      => output
                                                       ) severity error;

                    if result > 2 ** DATA_SIZE - 1 then
                        if to_unsigned(result, 2 * DATA_SIZE)(DATA_SIZE) = '1' then
                            assert flags(FLAG_C) = '1' report "Error '*': overflow, expected Carry flag C on" severity error;
                        else
                            assert flags(FLAG_C) = '0' report "Error '*': expected Carry flag C off" severity error;
                        end if;
                        assert flags(FLAG_O) = '1' report "Error '*': overflow, expected Overflow flag O on" severity error;
                    else
                        assert flags(FLAG_C) = '0' report "Error '*': expected Carry flag C off" severity error;
                        assert flags(FLAG_O) = '0' report "Error '*': expected Overflow flag O off" severity error;
                    end if;

                    if result mod 2 ** DATA_SIZE = 0 then
                        assert flags(FLAG_Z) = '1' report "Error '*': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(FLAG_Z) = '0' report "Error '*': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result mod 2 ** DATA_SIZE >= 2 ** (DATA_SIZE - 1) then
                        assert flags(FLAG_N) = '1' report "Error '*': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(FLAG_N) = '0' report "Error '*': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 3 =>
                    result_vector := std_logic_vector(to_unsigned(value_a, DATA_SIZE)) and std_logic_vector(to_unsigned(value_b, DATA_SIZE));

                    assert output = result_vector
                    report "Error 'and': " & report_error(arg_a    => a,
                                                          arg_b    => b,
                                                          arg_c_in => c_in,
                                                          expected => result_vector,
                                                          got      => output
                                                         ) severity error;

                    assert flags(FLAG_C) = '0' report "Error 'and': no carry for this operation, expected Carry flag C off" severity error;
                    assert flags(FLAG_O) = '0' report "Error 'and': no carry for this operation, expected Overflow flag O off" severity error;

                    if result_vector = zero_vector then
                        assert flags(FLAG_Z) = '1' report "Error 'and': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(FLAG_Z) = '0' report "Error 'and': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result_vector(DATA_SIZE - 1) = '1' then
                        assert flags(FLAG_N) = '1' report "Error 'and': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(FLAG_N) = '0' report "Error 'and': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 4 =>
                    result_vector := std_logic_vector(to_unsigned(value_a, DATA_SIZE)) or std_logic_vector(to_unsigned(value_b, DATA_SIZE));

                    assert output = result_vector
                    report "Error 'or': " & report_error(arg_a    => a,
                                                         arg_b    => b,
                                                         arg_c_in => c_in,
                                                         expected => result_vector,
                                                         got      => output
                                                        ) severity error;

                    assert flags(FLAG_C) = '0' report "Error 'or': no carry for this operation, expected Carry flag C off" severity error;
                    assert flags(FLAG_O) = '0' report "Error 'or': no carry for this operation, expected Overflow flag O off" severity error;

                    if result_vector = zero_vector then
                        assert flags(FLAG_Z) = '1' report "Error 'or': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(FLAG_Z) = '0' report "Error 'or': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result_vector(DATA_SIZE - 1) = '1' then
                        assert flags(FLAG_N) = '1' report "Error 'or': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(FLAG_N) = '0' report "Error 'or': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 5 =>
                    result_vector := std_logic_vector(to_unsigned(value_a, DATA_SIZE)) xor std_logic_vector(to_unsigned(value_b, DATA_SIZE));

                    assert output = result_vector
                    report "Error 'xor': " & report_error(arg_a    => a,
                                                          arg_b    => b,
                                                          arg_c_in => c_in,
                                                          expected => result_vector,
                                                          got      => output
                                                         ) severity error;

                    assert flags(FLAG_C) = '0' report "Error 'xor': no carry for this operation, expected Carry flag C off" severity error;
                    assert flags(FLAG_O) = '0' report "Error 'xor': no carry for this operation, expected Overflow flag O off" severity error;

                    if result_vector = zero_vector then
                        assert flags(FLAG_Z) = '1' report "Error 'xor': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(FLAG_Z) = '0' report "Error 'xor': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result_vector(DATA_SIZE - 1) = '1' then
                        assert flags(FLAG_N) = '1' report "Error 'xor': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(FLAG_N) = '0' report "Error 'xor': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 6 =>
                    result_vector := not std_logic_vector(to_unsigned(value_a, DATA_SIZE));

                    assert output = result_vector
                    report "Error 'not': " & report_error(arg_a    => a,
                                                          arg_b    => b,
                                                          arg_c_in => c_in,
                                                          expected => result_vector,
                                                          got      => output
                                                         ) severity error;

                    assert flags(FLAG_C) = '0' report "Error 'not': no carry for this operation, expected Carry flag C off" severity error;
                    assert flags(FLAG_O) = '0' report "Error 'not': no carry for this operation, expected Overflow flag O off" severity error;

                    if result_vector = zero_vector then
                        assert flags(FLAG_Z) = '1' report "Error 'not': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(FLAG_Z) = '0' report "Error 'not': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result_vector(DATA_SIZE - 1) = '1' then
                        assert flags(FLAG_N) = '1' report "Error 'not': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(FLAG_N) = '0' report "Error 'not': non-negative, expected Negative flag N off" severity error;
                    end if;
                when 7 =>
                    result_vector := std_logic_vector(to_unsigned(value_a, DATA_SIZE));

                    assert output = result_vector
                    report "Error 'cmp': " & report_error(arg_a    => a,
                                                          arg_b    => b,
                                                          arg_c_in => c_in,
                                                          expected => result_vector,
                                                          got      => output
                                                         ) severity error;

                    if result_vector(DATA_SIZE - 1) = '1' then
                        assert flags(FLAG_N) = '1' report "Error 'cmp': expected Negative flag N on" severity error;
                        assert flags(FLAG_C) = '0' report "Error 'cmp': expected Carry flag C off" severity error;
                        assert flags(FLAG_Z) = '0' report "Error 'cmp': expected Zero flag Z off" severity error;
                        assert flags(FLAG_O) = '0' report "Error 'cmp': expected Overflow flag O off" severity error;
                    else
                        assert flags(FLAG_N) = '0' report "Error 'cmp': expected Negative flag N off" severity error;
                        assert flags(FLAG_O) = '1' report "Error 'cmp': expected Overflow flag O on" severity error;

                        if result_vector = zero_vector then
                            assert flags(FLAG_Z) = '1' report "Error 'cmp': expected Zero flag Z on" severity error;
                            assert flags(FLAG_C) = '0' report "Error 'cmp': expected Carry flag C off" severity error;
                        else
                            assert flags(FLAG_Z) = '0' report "Error 'cmp': expected Zero flag Z off" severity error;
                            assert flags(FLAG_C) = '1' report "Error 'cmp': expected Carry flag C on" severity error;
                        end if;
                    end if;

                when 8 =>
                    assert output = zero_vector
                    report print_error("Error 'sec':", zero_vector, output) severity error;

                    assert flags(FLAG_C) = '1'
                    report print_bit_error("Error 'sec':", '1', flags(FLAG_C)) severity error;
                when 9 =>
                    assert output = zero_vector
                    report print_error("Error 'sez':", zero_vector, output) severity error;

                    assert flags(FLAG_Z) = '1'
                    report print_bit_error("Error 'sez':", '1', flags(FLAG_Z)) severity error;
                when 10 =>
                    assert output = zero_vector
                    report print_error("Error 'sen':", zero_vector, output) severity error;

                    assert flags(FLAG_N) = '1'
                    report print_bit_error("Error 'sen':", '1', flags(FLAG_N)) severity error;
                when 11 =>
                    assert output = zero_vector
                    report print_error("Error 'sev':", zero_vector, output) severity error;

                    assert flags(FLAG_O) = '1'
                    report print_bit_error("Error 'sev':", '1', flags(FLAG_O)) severity error;
                when 12 =>
                    assert output = zero_vector
                    report print_error("Error 'clc':", zero_vector, output) severity error;

                    assert flags(FLAG_C) = '0'
                    report print_bit_error("Error 'clc':", '0', flags(FLAG_C)) severity error;
                when 13 =>
                    assert output = zero_vector
                    report print_error("Error 'clz':", zero_vector, output) severity error;

                    assert flags(FLAG_Z) = '0'
                    report print_bit_error("Error 'clz':", '0', flags(FLAG_Z)) severity error;
                when 14 =>
                    assert output = zero_vector
                    report print_error("Error 'cln':", zero_vector, output) severity error;

                    assert flags(FLAG_N) = '0'
                    report print_bit_error("Error 'cln':", '0', flags(FLAG_N)) severity error;
                when 15 =>
                    assert output = zero_vector
                    report print_error("Error 'clv':", zero_vector, output) severity error;

                    assert flags(FLAG_O) = '0'
                    report print_bit_error("Error 'clv':", '0', flags(FLAG_O)) severity error;
                when others => null;
            end case;

            -- Increment variables
            if value_c_in = '1' then
                value_c_in     := '0';
                int_value_c_in := 0;

                -- If b is at 0x100 then we add 1 to a
                if value_b = 2 ** (DATA_SIZE / 2) * 4 then
                    value_b := 0;

                    -- if a is at 0x100 then we add 1 to sel
                    if value_a = 2 ** (DATA_SIZE / 2) * 4 then
                        value_a   := 0;
                        value_sel := value_sel + 1;
                        if value_sel = 2 ** ALU_SELECTOR_SIZE then
                            report "End of tests!" severity note;
                            wait;
                        else
                            report "Next operation! (selector=" & integer'image(value_sel) & ")" severity note;
                        end if;
                    else
                        value_a := value_a + 1;
                    end if;
                else
                    value_b := value_b + 1;
                end if;
            else
                value_c_in     := '1';
                int_value_c_in := 1;
            end if;

            -- Assigning values
            a        <= std_logic_vector(to_unsigned(value_a, DATA_SIZE));
            b        <= std_logic_vector(to_unsigned(value_b, DATA_SIZE));
            selector <= std_logic_vector(to_unsigned(value_sel, ALU_SELECTOR_SIZE));
            c_in     <= value_c_in;
            wait for 5 ns;
        end if;
    end process alu_process;

end architecture testbench;
