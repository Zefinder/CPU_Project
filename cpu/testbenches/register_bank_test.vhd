library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;
use utils.test_utils.all;

entity register_bank_test is
end entity register_bank_test;

architecture testbench of register_bank_test is
    component register_bank
        port(
            clk                     : in  std_logic;
            rst                     : in  std_logic;
            register_address_read_1 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_read_2 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_read_3 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_address_write  : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
            register_load           : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            write_register          : in  std_logic;
            register_output_1       : out std_logic_vector(DATA_SIZE - 1 downto 0);
            register_output_2       : out std_logic_vector(DATA_SIZE - 1 downto 0);
            register_output_3       : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component register_bank;

    signal clk                     : std_logic                                             := '0';
    signal rst                     : std_logic                                             := '0';
    signal register_address_read_1 : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0) := (others => '0');
    signal register_address_read_2 : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0) := (others => '0');
    signal register_address_read_3 : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0) := (others => '0');
    signal register_address_write  : std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0) := (others => '0');
    signal register_load           : std_logic_vector(DATA_SIZE - 1 downto 0)              := (others => '0');
    signal write_register          : std_logic                                             := '0';
    signal register_output_1       : std_logic_vector(DATA_SIZE - 1 downto 0);
    signal register_output_2       : std_logic_vector(DATA_SIZE - 1 downto 0);
    signal register_output_3       : std_logic_vector(DATA_SIZE - 1 downto 0);
    signal end_clk                 : std_logic                                             := '0';

    for all : register_bank use entity work.register_bank(RTL);

begin

    register_bank_inst : component register_bank
        port map(
            clk                     => clk,
            rst                     => rst,
            register_address_read_1 => register_address_read_1,
            register_address_read_2 => register_address_read_2,
            register_address_read_3 => register_address_read_3,
            register_address_write  => register_address_write,
            register_load           => register_load,
            write_register          => write_register,
            register_output_1       => register_output_1,
            register_output_2       => register_output_2,
            register_output_3       => register_output_3
        );

    clock_process : process is
    begin
        wait for 5 ns;
        clk <= not clk;
        
        if end_clk = '1' then
            wait;
        end if;
    end process clock_process;

    register_test_process : process is
        constant zero_register : std_logic_vector(DATA_SIZE - 1 downto 0) := x"0000";
        
    begin
        rst <= '1';
        wait for 10 ns;

        rst           <= '0';
        register_load <= x"AAAA";
        register_address_read_3 <= REG_PC;
        wait for 10 ns;

        assert register_output_1 = zero_register
        report print_error("register output 1 should be empty", zero_register, register_output_1) severity error;
        assert register_output_2 = zero_register
        report print_error("register output 2 should be empty", zero_register, register_output_2) severity error;
        assert register_output_3 = zero_register
        report print_error("register output 3 should be empty", zero_register, register_output_3) severity error;

        register_address_write  <= x"1";
        register_address_read_1 <= x"0";
        register_address_read_2 <= x"1";
        wait for 10 ns;

        assert register_output_1 = zero_register
        report print_error("register output 1 should be empty", zero_register, register_output_1) severity error;
        assert register_output_2 = zero_register
        report print_error("register output 2 should be empty", zero_register, register_output_2) severity error;
        assert register_output_3 = zero_register
        report print_error("register output 3 should be empty", zero_register, register_output_3) severity error;

        write_register <= '1';
        wait for 10 ns;

        assert register_output_1 = zero_register
        report print_error("register output 1 should be empty", zero_register, register_output_1) severity error;
        assert register_output_2 = x"AAAA"
        report print_error("wrong register output 2 value", x"AAAA", register_output_2) severity error;
        assert register_output_3 = zero_register
        report print_error("register output 3 should be empty", zero_register, register_output_3) severity error;

        register_load          <= x"BBBB";
        register_address_write <= x"2";
        wait for 10 ns;

        assert register_output_1 = zero_register
        report print_error("register output 1 should be empty", zero_register, register_output_1) severity error;
        assert register_output_2 = x"AAAA"
        report print_error("wrong register output 2 value", x"AAAA", register_output_2) severity error;
        assert register_output_3 = zero_register
        report print_error("register output 3 should be empty", zero_register, register_output_3) severity error;

        register_address_read_1 <= x"2";
        wait for 10 ns;

        assert register_output_1 = x"BBBB"
        report print_error("wrong register output 1 value", x"BBBB", register_output_1) severity error;
        assert register_output_2 = x"AAAA"
        report print_error("wrong register output 2 value", x"AAAA", register_output_2) severity error;
        assert register_output_3 = zero_register
        report print_error("register output 3 should be empty", zero_register, register_output_3) severity error;
        
        register_address_read_1 <= x"0";
        wait for 10 ns;

        assert register_output_1 = zero_register
        report print_error("register output 1 should be empty", zero_register, register_output_1) severity error;
        assert register_output_2 = x"AAAA"
        report print_error("wrong register output 2 value", x"AAAA", register_output_2) severity error;
        assert register_output_3 = zero_register
        report print_error("register output 3 should be empty", zero_register, register_output_3) severity error;
        
        register_load          <= x"FFFF";
        register_address_write <= REG_PC;
        wait for 10 ns;
        
        assert register_output_1 = zero_register
        report print_error("register output 1 should be empty", zero_register, register_output_1) severity error;
        assert register_output_2 = x"AAAA"
        report print_error("wrong register output 2 value", x"AAAA", register_output_2) severity error;
        assert register_output_3 = x"FFFF"
        report print_error("wrong register output 3 value", x"FFFF", register_output_3) severity error;
        
        end_clk <= '1';
        report "End of tests!" severity note;
        wait;

    end process register_test_process;

end architecture testbench;
