library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;
use utils.test_utils.all;

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

    type set_name_access is access string;
    type test_set is record
        file_name_ptr : set_name_access;
        test_count    : natural;
    end record;

    type test_files_array_t is array (natural range <>) of test_set;

    constant TEST_FILES_DIRECTORY : string := "C:\Users\adric\workspaceSigasi\CPU_Project\cpu\assembly_test_set\";

    constant ALU_SET_NAME       : string := "alu_set";
    constant BRANCHING_SET_NAME : string := "branching_set";
    constant STORING_SET_NAME   : string := "storing_set";
    constant COMPLETE_SET_NAME  : string := "complete_set";

    constant ALU_SET_TEST_COUNT       : natural := 10;
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
        wait for 5 ns;
        clk     <= not clk;
        counter := counter + 5;

        if counter = 50 then
            wait;
        end if;
    end process clk_process;

    cpu_test_process : process is
        variable init : natural := 0;

        -- Add if more sets (DO NOT MODIFY IN BEGIN)
        variable alu_set       : test_set := (new string'(ALU_SET_NAME), ALU_SET_TEST_COUNT);
        variable branching_set : test_set := (new string'(BRANCHING_SET_NAME), BRANCHING_SET_TEST_COUNT);
        variable storing_set   : test_set := (new string'(STORING_SET_NAME), STORING_SET_TEST_COUNT);
        variable complete_set  : test_set := (new string'(COMPLETE_SET_NAME), COMPLETE_SET_TEST_COUNT);

        variable test_files_array : test_files_array_t(0 to 3) := (alu_set, branching_set, storing_set, complete_set);

        -- Selected files
        variable test_set_number  : natural;
        variable set_name         : set_name_access;
        variable total_test_count : natural;
        variable test_counter     : natural;

    begin
        if init = 0 then
            report "Initialisation... (ignore metadata values here because we reset)" severity note;
            test_set_number := test_files_array'low;
            test_counter    := 1;
            update_test_set(test_set_number  => test_set_number,
                            test_files_array => test_files_array,
                            set_name         => set_name,
                            total_test_count => total_test_count);
            wait for 5 ns;

            rst <= '0';
            wait for 5 ns;

            report "Initialised!" severity note;

            init := 1;
        else
            if test_counter >= total_test_count then
                -- If we change and there are no tests, we continue changing
                while test_counter >= total_test_count loop
                    test_counter    := 1;
                    test_set_number := test_set_number + 1;

                    if test_set_number = test_files_array'high + 1 then
                        report "End of tests!" severity note;
                        wait;
                    else
                        update_test_set(test_set_number  => test_set_number,
                                        test_files_array => test_files_array,
                                        set_name         => set_name,
                                        total_test_count => total_test_count);
                    end if;
                end loop;
            else
                test_counter := test_counter + 1;
            end if;
            wait for 5 ns;
        end if;

        report TEST_FILES_DIRECTORY & set_name.all & "\" & set_name.all & "_" & integer'image(test_counter) & ".asm" severity note;
    end process cpu_test_process;

end architecture testbench;
