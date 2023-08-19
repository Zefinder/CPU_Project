library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

entity flag_bank_test is
end entity flag_bank_test;

architecture testbench of flag_bank_test is
    component flag_bank
        port(
            clk           : in  std_logic;
            flag_selector : in  std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
            input_flags   : in  std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0);
            update_flags  : in  std_logic;
            output_flag   : out std_logic
        );
    end component flag_bank;

    constant FLAG_SELECTOR_SIZE : natural := 2;

    signal clk           : std_logic := '0';
    signal flag_selector : std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0) := (others => '0');
    signal input_flags   : std_logic_vector(2 ** FLAG_SELECTOR_SIZE - 1 downto 0) := (others => '0');
    signal update_flags  : std_logic := '1';
    signal output_flag   : std_logic;

    for all : flag_bank use entity work.flag_bank(RTL);
begin

    flag_bank_inst : component flag_bank
        port map(
            clk           => clk,
            flag_selector => flag_selector,
            input_flags   => input_flags,
            update_flags  => update_flags,
            output_flag   => output_flag
        );

    clk_process : process is
        variable counter : natural := 0;
    begin
        wait for 5 ns;
        clk <= not clk;
        counter := counter + 1;
        if counter = 130 then
            wait;
        end if;
    end process clk_process;

    update_flags_process : process is
        variable flag_selector_variable : natural   := 0;
        variable input_flags_variable   : natural   := 0;
        variable update_flag_variable   : std_logic := '0';

        variable init                        : natural := 0;
        variable input_flags_vector_variable : unsigned(2 ** FLAG_SELECTOR_SIZE - 1 downto 0) := (others => '0');
    begin
        
        if init = 0 then
            wait for 6 ns;
            update_flags <= '0';
            init         := 1;
            wait for 4 ns;
        else
            -- Testing values
            assert input_flags_vector_variable = unsigned(input_flags)
            report "Input flags different! Expected " & to_hstring(input_flags_vector_variable) & " but got " & to_hstring(input_flags) severity error;

            assert flag_selector_variable = to_integer(unsigned(flag_selector))
            report "Flag selector different!" severity error;

            assert update_flag_variable = update_flags
            report "Update bit different!" severity error;

            if update_flag_variable = '1' then
                assert input_flags_vector_variable(flag_selector_variable) = output_flag
                report "Output flag not the same" severity error;
            else
                assert output_flag = '0' report "Output flag must be 0 since no update!";
            end if;

            -- We iterate over all flags before changing
            if flag_selector_variable = 2 ** FLAG_SELECTOR_SIZE - 1 then
                flag_selector_variable := 0;

                -- If input flags is at its max then we reset it and change the update status
                if input_flags_variable = 2 ** (2 ** FLAG_SELECTOR_SIZE - 1) - 1 then
                    input_flags_variable := 0;
                    update_flag_variable := not update_flag_variable;
                    init                 := init + 1;
                else
                    input_flags_variable := input_flags_variable + 1;
                end if;
            else
                flag_selector_variable := flag_selector_variable + 1;
            end if;
            
            -- Assignment
            input_flags_vector_variable := to_unsigned(input_flags_variable, 2 ** FLAG_SELECTOR_SIZE);
            flag_selector <= std_logic_vector(to_unsigned(flag_selector_variable, FLAG_SELECTOR_SIZE));
            input_flags   <= std_logic_vector(input_flags_vector_variable);
            update_flags  <= update_flag_variable;
            wait for 10 ns;
        end if;

        if init = 3 then
            report "End of tests" severity note;
            wait;
        end if;

    end process update_flags_process;

end architecture testbench;
