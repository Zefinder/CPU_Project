library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_test is
end entity alu_test;

architecture testbench of alu_test is
    component alu
        generic(data_size : positive := 8);
        port(
            a, b     : in  std_logic_vector(data_size - 1 downto 0);
            selector : in  std_logic_vector(2 downto 0);
            c_in     : in  std_logic;
            flags    : out std_logic_vector(3 downto 0);
            output   : out std_logic_vector(data_size - 1 downto 0)
        );
    end component alu;
    for all : alu use entity work.alu(RTL);

    constant data_size   : natural                                  := 8;
    constant C           : natural                                  := 0; -- Selector for C flag (carry)
    constant Z           : natural                                  := 1; -- Selector for Z flag (zero)
    constant N           : natural                                  := 2; -- Selector for N flag (negative)
    constant O           : natural                                  := 3; -- Selector for O flag (overflow)
    constant zero_vector : std_logic_vector(data_size - 1 downto 0) := (others => '0');

    signal a, b     : std_logic_vector(data_size - 1 downto 0) := x"00";
    signal selector : std_logic_vector(2 downto 0)             := "000";
    signal c_in     : std_logic                                := '0';
    signal flags    : std_logic_vector(3 downto 0);
    signal output   : std_logic_vector(data_size - 1 downto 0);

    function report_error(arg_a, arg_b : std_logic_vector(data_size - 1 downto 0); arg_c_in : std_logic; expected, got : std_logic_vector(data_size - 1 downto 0)) return string is
        constant hex_a        : string(1 to 2) := to_hstring(arg_a);
        constant hex_b        : string(1 to 2) := to_hstring(arg_b);
        constant hex_expected : string(1 to 2) := to_hstring(expected);
        constant hex_got      : string(1 to 2) := to_hstring(got);

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
        generic map(
            data_size => data_size
        )
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
        variable result_vector : std_logic_vector(data_size - 1 downto 0);
    begin
        -- Test if needs init
        if init = 0 then
            init     := 1;
            a        <= x"00";
            b        <= x"00";
            selector <= "000";
            c_in     <= '0';

            report "Begin tests for alu (selector=0)" severity note;
            wait for 10 ns;
        else
            -- Test old value 
            case value_sel is
                when 0 =>
                    result := value_a + value_b + int_value_c_in;
                    assert output = std_logic_vector(to_unsigned(result mod 2 ** data_size, data_size))
                    report "Error '+': " & report_error(arg_a    => a,
                                                        arg_b    => b,
                                                        arg_c_in => c_in,
                                                        expected => std_logic_vector(to_unsigned(value_a + value_b + int_value_c_in, data_size)),
                                                        got      => output
                                                       ) severity error;

                    if result > 2 ** data_size - 1 then
                        assert flags(C) = '1' report "Error '+': overflow, expected Carry flag C on" severity error;
                        assert flags(O) = '1' report "Error '+': overflow, expected Overflow flag O on" severity error;
                    else
                        assert flags(C) = '0' report "Error '+': expected Carry flag C off" severity error;
                        assert flags(O) = '0' report "Error '+': expected Overflow flag O off" severity error;
                    end if;

                    if result mod 2 ** data_size = 0 then
                        assert flags(Z) = '1' report "Error '+': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(Z) = '0' report "Error '+': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result mod 2 ** data_size >= 2 ** (data_size - 1) then
                        assert flags(N) = '1' report "Error '+': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(N) = '0' report "Error '+': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 1 =>
                    result := value_a - value_b - int_value_c_in;

                    assert output = std_logic_vector(to_unsigned(result mod 2 ** data_size, data_size))
                    report "Error '-': " & report_error(arg_a    => a,
                                                        arg_b    => b,
                                                        arg_c_in => c_in,
                                                        expected => std_logic_vector(to_unsigned(value_a - value_b - int_value_c_in, data_size)),
                                                        got      => output
                                                       ) severity error;

                    if result > 2 ** data_size - 1 or result < 0 then
                        assert flags(C) = '1' report "Error '-': overflow, expected Carry flag C on" severity error;
                        assert flags(O) = '1' report "Error '-': overflow, expected Overflow flag O on" severity error;
                    else
                        assert flags(C) = '0' report "Error '-': expected Carry flag C off" severity error;
                        assert flags(O) = '0' report "Error '-': expected Overflow flag O off" severity error;
                    end if;

                    if result mod 2 ** data_size = 0 then
                        assert flags(Z) = '1' report "Error '-': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(Z) = '0' report "Error '-': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result mod 2 ** data_size >= 2 ** (data_size - 1) then
                        assert flags(N) = '1' report "Error '-': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(N) = '0' report "Error '-': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 2 =>
                    result := value_a * value_b;

                    assert output = std_logic_vector(to_unsigned(result mod 2 ** data_size, data_size))
                    report "Error '*': " & report_error(arg_a    => a,
                                                        arg_b    => b,
                                                        arg_c_in => c_in,
                                                        expected => std_logic_vector(to_unsigned(value_a * value_b, data_size)),
                                                        got      => output
                                                       ) severity error;

                    if result > 2 ** data_size - 1 then
                        if to_unsigned(result, 2 * data_size)(data_size) = '1' then
                            assert flags(C) = '1' report "Error '*': overflow, expected Carry flag C on" severity error;
                        else
                            assert flags(C) = '0' report "Error '*': expected Carry flag C off" severity error;
                        end if;
                        assert flags(O) = '1' report "Error '*': overflow, expected Overflow flag O on" severity error;
                    else
                        assert flags(C) = '0' report "Error '*': expected Carry flag C off" severity error;
                        assert flags(O) = '0' report "Error '*': expected Overflow flag O off" severity error;
                    end if;

                    if result mod 2 ** data_size = 0 then
                        assert flags(Z) = '1' report "Error '*': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(Z) = '0' report "Error '*': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result mod 2 ** data_size >= 2 ** (data_size - 1) then
                        assert flags(N) = '1' report "Error '*': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(N) = '0' report "Error '*': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 3 =>
                    result_vector := std_logic_vector(to_unsigned(value_a, data_size)) and std_logic_vector(to_unsigned(value_b, data_size));

                    assert output = result_vector
                    report "Error 'and': " & report_error(arg_a    => a,
                                                          arg_b    => b,
                                                          arg_c_in => c_in,
                                                          expected => result_vector,
                                                          got      => output
                                                         ) severity error;

                    assert flags(C) = '0' report "Error 'and': no carry for this operation, expected Carry flag C off" severity error;
                    assert flags(O) = '0' report "Error 'and': no carry for this operation, expected Overflow flag O off" severity error;

                    if result_vector = zero_vector then
                        assert flags(Z) = '1' report "Error 'and': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(Z) = '0' report "Error 'and': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result_vector(data_size - 1) = '1' then
                        assert flags(N) = '1' report "Error 'and': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(N) = '0' report "Error 'and': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 4 =>
                    result_vector := std_logic_vector(to_unsigned(value_a, data_size)) or std_logic_vector(to_unsigned(value_b, data_size));

                    assert output = result_vector
                    report "Error 'or': " & report_error(arg_a    => a,
                                                         arg_b    => b,
                                                         arg_c_in => c_in,
                                                         expected => result_vector,
                                                         got      => output
                                                        ) severity error;

                    assert flags(C) = '0' report "Error 'or': no carry for this operation, expected Carry flag C off" severity error;
                    assert flags(O) = '0' report "Error 'or': no carry for this operation, expected Overflow flag O off" severity error;

                    if result_vector = zero_vector then
                        assert flags(Z) = '1' report "Error 'or': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(Z) = '0' report "Error 'or': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result_vector(data_size - 1) = '1' then
                        assert flags(N) = '1' report "Error 'or': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(N) = '0' report "Error 'or': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 5 =>
                    result_vector := std_logic_vector(to_unsigned(value_a, data_size)) xor std_logic_vector(to_unsigned(value_b, data_size));

                    assert output = result_vector
                    report "Error 'xor': " & report_error(arg_a    => a,
                                                          arg_b    => b,
                                                          arg_c_in => c_in,
                                                          expected => result_vector,
                                                          got      => output
                                                         ) severity error;

                    assert flags(C) = '0' report "Error 'xor': no carry for this operation, expected Carry flag C off" severity error;
                    assert flags(O) = '0' report "Error 'xor': no carry for this operation, expected Overflow flag O off" severity error;

                    if result_vector = zero_vector then
                        assert flags(Z) = '1' report "Error 'xor': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(Z) = '0' report "Error 'xor': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result_vector(data_size - 1) = '1' then
                        assert flags(N) = '1' report "Error 'xor': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(N) = '0' report "Error 'xor': non-negative, expected Negative flag N off" severity error;
                    end if;

                when 6 =>
                    result_vector := not std_logic_vector(to_unsigned(value_a, data_size));

                    assert output = result_vector
                    report "Error 'not': " & report_error(arg_a    => a,
                                                          arg_b    => b,
                                                          arg_c_in => c_in,
                                                          expected => result_vector,
                                                          got      => output
                                                         ) severity error;

                    assert flags(C) = '0' report "Error 'not': no carry for this operation, expected Carry flag C off" severity error;
                    assert flags(O) = '0' report "Error 'not': no carry for this operation, expected Overflow flag O off" severity error;

                    if result_vector = zero_vector then
                        assert flags(Z) = '1' report "Error 'not': zero, expected Zero flag Z on" severity error;
                    else
                        assert flags(Z) = '0' report "Error 'not': non-zero, expected Zero flag Z off" severity error;
                    end if;

                    if result_vector(data_size - 1) = '1' then
                        assert flags(N) = '1' report "Error 'not': negative, expected Negative flag N on" severity error;
                    else
                        assert flags(N) = '0' report "Error 'not': non-negative, expected Negative flag N off" severity error;
                    end if;
                when 7 =>
                    result_vector := std_logic_vector(to_unsigned(value_a, data_size));

                    assert output = result_vector
                    report "Error 'cmp': " & report_error(arg_a    => a,
                                                          arg_b    => b,
                                                          arg_c_in => c_in, 
                                                          expected => result_vector,
                                                          got      => output
                                                         ) severity error;

                    if result_vector(data_size - 1) = '1' then
                        assert flags(N) = '1' report "Error 'cmp': expected Negative flag N on" severity error;
                        assert flags(C) = '0' report "Error 'cmp': expected Carry flag C off" severity error;
                        assert flags(Z) = '0' report "Error 'cmp': expected Zero flag Z off" severity error;
                        assert flags(O) = '0' report "Error 'cmp': expected Overflow flag O off" severity error;
                    else
                        assert flags(N) = '0' report "Error 'cmp': expected Negative flag N off" severity error;
                        assert flags(O) = '1' report "Error 'cmp': expected Overflow flag O on" severity error;

                        if result_vector = zero_vector then
                            assert flags(Z) = '1' report "Error 'cmp': expected Zero flag Z on" severity error;
                            assert flags(C) = '0' report "Error 'cmp': expected Carry flag C off" severity error;
                        else
                            assert flags(Z) = '0' report "Error 'cmp': expected Zero flag Z off" severity error;
                            assert flags(C) = '1' report "Error 'cmp': expected Carry flag C on" severity error;
                        end if;
                    end if;

                when others => null;
            end case;

            -- Increment variables
            if value_c_in = '1' then
                value_c_in     := '0';
                int_value_c_in := 0;

                -- If b is at 0xFF then we add 1 to a
                if value_b = 2 ** data_size - 1 then
                    value_b := 0;

                    -- if a is at 0xFF then we add 1 to sel
                    if value_a = 2 ** data_size - 1 then
                        value_a   := 0;
                        value_sel := value_sel + 1;
                        report "Next operation! (selector=" & integer'image(value_sel) & ")" severity note;

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

            -- Test if finished
            if value_sel = 8 then
                assert false report "End of tests!" severity note;
                wait;
            else
                a        <= std_logic_vector(to_unsigned(value_a, data_size));
                b        <= std_logic_vector(to_unsigned(value_b, data_size));
                selector <= std_logic_vector(to_unsigned(value_sel, selector'length));
                c_in     <= value_c_in;
            end if;
            wait for 5 ns;
        end if;
    end process alu_process;

end architecture testbench;
