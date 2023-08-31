library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;
use utils.test_utils.all;
use std.textio.all;

entity cpu_test is
end entity cpu_test;

architecture testbench of cpu_test is
    component cpu
        port(
            clk                : in  std_logic;
            rst                : in  std_logic;
            instruction_vector : in  std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
            output             : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component cpu;

    type binary is file of character;

    type set_name_access is access string;
    type test_set is record
        file_name_ptr : set_name_access;
        test_count    : natural;
    end record;

    type test_files_array_t is array (natural range <>) of test_set;

    constant TEST_FILES_DIRECTORY : string := "C:\Users\adric\workspaceSigasi\CPU_Project\cpu\assembly_test_set\";

    -- TODO Complete set when there will be an instruction memory
    constant ALU_SET_NAME       : string := "alu_set";
    constant BRANCHING_SET_NAME : string := "branching_set";
    constant STORING_SET_NAME   : string := "storing_set";
    constant COMPLETE_SET_NAME  : string := "complete_set";

    constant ALU_SET_TEST_COUNT       : natural := 1;
    constant BRANCHING_SET_TEST_COUNT : natural := 0;
    constant STORING_SET_TEST_COUNT   : natural := 0;
    constant COMPLETE_SET_TEST_COUNT  : natural := 0;

    signal clk                : std_logic                                       := '0';
    signal rst                : std_logic                                       := '1';
    signal instruction_vector : std_logic_vector(INSTRUCTION_SIZE - 1 downto 0) := (others => '0');
    signal output             : std_logic_vector(DATA_SIZE - 1 downto 0);

    procedure update_test_set(test_set_number : in natural; test_files_array : inout test_files_array_t; set_name : out set_name_access; total_test_count : out natural) is
        variable test_file : test_set;
    begin
        test_file        := test_files_array(test_set_number);
        set_name         := test_file.file_name_ptr;
        total_test_count := test_file.test_count;
    end procedure update_test_set;

    function get_binary_file_path(set_name : in string; test_counter : in natural) return string is
    begin
        return TEST_FILES_DIRECTORY & set_name & "\" & set_name & "_" & integer'image(test_counter);
    end function get_binary_file_path;

    function get_results_file_path(set_name : in string; test_counter : in natural) return string is
    begin
        return get_binary_file_path(set_name => set_name, test_counter => test_counter) & ".txt";
    end function get_results_file_path;

    procedure read_instruction(file file_ptr : binary; instruction_vector_read : out std_logic_vector; eof : out boolean) is
        constant iteration   : natural := instruction_vector_read'length / 8;
        variable char_buffer : character;
    begin
        for index in iteration - 1 downto 0 loop
            read(file_ptr, char_buffer);
            instruction_vector_read(instruction_vector_read'length - 8 * (iteration - (index + 1)) - 1 downto instruction_vector_read'length - 8 * (iteration - index)) := std_logic_vector(to_unsigned(character'pos(char_buffer), 8));
        end loop;

        if endfile(file_ptr) then
            eof := true;
        end if;

    end read_instruction;

    procedure read_expected_result(file result_file_ptr : text; line : inout line; expected_result : inout std_logic_vector(DATA_SIZE - 1 downto 0); eof : out boolean) is
    begin
        readline(result_file_ptr, line);
        hread(line, expected_result);

        if endfile(result_file_ptr) then
            eof := true;
        end if;
    end procedure read_expected_result;

    procedure print_begin_test(set_name : in string; test_number : natural) is
    begin
        report "Begin of tests for " & set_name & "_" & integer'image(test_number) severity note;
    end procedure print_begin_test;

    procedure print_end_test(set_name : in string; test_number : natural) is
    begin
        report "End of tests for " & set_name & "_" & integer'image(test_number) severity note;
    end procedure print_end_test;

    for all : cpu use entity work.cpu(RTL);

begin
    cpu_inst : component cpu
        port map(
            clk                => clk,
            rst                => rst,
            instruction_vector => instruction_vector,
            output             => output
        );

    clk_process : process is
        variable counter : natural := 0;
    begin
        wait for CLK_PERIOD_TIME;
        clk     <= not clk;
        counter := counter + CLK_PERIOD;

        if counter = 2 * CLK_PERIOD * 10 then
            wait;
        end if;
    end process clk_process;

    cpu_test_process : process is
        variable init : natural := 0;

        -- Add here if more sets (DO NOT MODIFY IN BEGIN)
        variable alu_set       : test_set := (new string'(ALU_SET_NAME), ALU_SET_TEST_COUNT); -- @suppress "variable alu_set is never written" -- @suppress "variable alu_set is never read"
        variable branching_set : test_set := (new string'(BRANCHING_SET_NAME), BRANCHING_SET_TEST_COUNT); -- @suppress "variable branching_set is never read" -- @suppress "variable branching_set is never written"
        variable storing_set   : test_set := (new string'(STORING_SET_NAME), STORING_SET_TEST_COUNT); -- @suppress "variable storing_set is never read" -- @suppress "variable storing_set is never written"
        variable complete_set  : test_set := (new string'(COMPLETE_SET_NAME), COMPLETE_SET_TEST_COUNT); -- @suppress "variable complete_set is never read" -- @suppress "variable complete_set is never written"

        variable test_files_array : test_files_array_t(0 to 3) := (alu_set, branching_set, storing_set, complete_set);

        -- Selected files
        variable test_set_number  : natural;
        variable set_name         : set_name_access;
        variable total_test_count : natural;
        variable test_counter     : natural;

        -- Binary file variables
        file binary_file_ptr                 : binary;
        variable instruction_vector_variable : std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
        variable file_status                 : file_open_status;

        -- Results file variables
        file result_file_ptr     : text;
        variable line_number     : line;
        variable expected_result : std_logic_vector(DATA_SIZE - 1 downto 0);

        variable eof_test_file    : boolean := false;
        variable eof_results_file : boolean := false;
        
        -- TODO Reset cpu after changing test!
        -- TODO Make test check at the end to point tests that didn't (OK, FAILURE enum)
    begin
        if init = 0 then
            report "Initialisation... (ignore metadata values here because we reset)" severity note;
            test_set_number := test_files_array'low;
            test_counter    := 1;
            -- Init first test set (tests must be at least 1)
            update_test_set(test_set_number  => test_set_number,
                            test_files_array => test_files_array,
                            set_name         => set_name,
                            total_test_count => total_test_count);

            report "Opening first test set (" & set_name.all & ")..." severity note;
            -- Open binary file
            file_open(file_status,
                      binary_file_ptr,
                      get_binary_file_path(set_name => set_name.all, test_counter => test_counter),
                      READ_MODE);

            -- Open results file
            file_open(file_status,
                      result_file_ptr,
                      get_results_file_path(set_name => set_name.all, test_counter => test_counter),
                      READ_MODE);

            report "Opened!" severity note;
            wait for 2 * CLK_PERIOD_TIME;

            rst <= '0';
            wait for 2 * CLK_PERIOD_TIME;
            report "Initialised!" severity note;
            print_begin_test(set_name.all, test_counter);

            init := 1;
        else
            -- Read instruction, if compare read result, assign to CPU, wait for 5ns and then increment
            read_instruction(file_ptr                => binary_file_ptr,
                             instruction_vector_read => instruction_vector_variable,
                             eof                     => eof_test_file);

            instruction_vector <= instruction_vector_variable;
            wait for 2 * CLK_PERIOD_TIME;

            if instruction_vector_variable(INSTRUCTION_SIZE - 1 downto INSTRUCTION_SIZE - 8) = CMP_OPCODE then
                read_expected_result(result_file_ptr => result_file_ptr,
                                     line            => line_number,
                                     expected_result => expected_result,
                                     eof             => eof_results_file);

                assert output = expected_result
                report print_error("different expected output", expected_result, output) severity note;
            end if;

            -- If no more instructions, go next
            -- If nothing more to test then useless to continue
            if eof_test_file or eof_results_file then
                print_end_test(set_name.all, test_counter);
                eof_test_file := false;

                if test_counter >= total_test_count then
                    -- If we change and there are no tests, we continue changing
                    while test_counter >= total_test_count loop
                        test_counter    := 1;
                        test_set_number := test_set_number + 1;

                        if test_set_number = test_files_array'high + 1 then
                            print_end_test(set_name.all, test_counter);
                            report "End of tests!" severity note;
                            wait;
                        else
                            update_test_set(test_set_number  => test_set_number,
                                            test_files_array => test_files_array,
                                            set_name         => set_name,
                                            total_test_count => total_test_count);

                            report "Opened next test set (" & set_name.all &")..." severity note;
                        end if;
                    end loop;
                else
                    test_counter := test_counter + 1;
                end if;

                 -- Open binary file
                file_open(file_status,
                          binary_file_ptr,
                          get_binary_file_path(set_name => set_name.all, test_counter => test_counter),
                          READ_MODE);

                -- Open results file
                file_open(file_status,
                          result_file_ptr,
                          get_results_file_path(set_name => set_name.all, test_counter => test_counter),
                          READ_MODE);
                          
                print_begin_test(set_name.all, test_counter);
            end if;
        end if;
    end process cpu_test_process;

end architecture testbench;
