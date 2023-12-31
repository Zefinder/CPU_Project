library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.test_utils.all;

entity ram_memory_test is
end entity ram_memory_test;

architecture testbench of ram_memory_test is

    constant ADDRESS_SIZE : natural := 8;
    constant DATA_SIZE    : natural := 8;

    component ram_memory
        port(
            clk        : in  std_logic;
            rst        : in  std_logic;
            write      : in  std_logic;
            use_offset : in  std_logic;
            address    : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            offset     : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            value_in   : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            value_out  : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component ram_memory;
    for all : ram_memory use entity work.ram_memory(RTL);

    signal clk        : std_logic                                   := '0';
    signal rst        : std_logic                                   := '0';
    signal write      : std_logic                                   := '1';
    signal use_offset : std_logic                                   := '0';
    signal address    : std_logic_vector(ADDRESS_SIZE - 1 downto 0) := x"00";
    signal offset     : std_logic_vector(DATA_SIZE - 1 downto 0)    := x"00";
    signal value_in   : std_logic_vector(DATA_SIZE - 1 downto 0)    := x"1A";
    signal value_out  : std_logic_vector(DATA_SIZE - 1 downto 0);
    signal end_clk    : std_logic                                   := '0';
begin

    memory_inst : component ram_memory
        port map(
            clk       => clk,
            rst       => rst,
            write     => write,
            use_offset => use_offset,
            address   => address,
            offset => offset,
            value_in  => value_in,
            value_out => value_out
        );

    clk_timing : process is
    begin
        clk <= not clk;
        wait for 5 ns;

        if end_clk = '1' then
            wait;
        end if;

    end process clk_timing;

    memory_test_process : process is
    begin
        rst <= '1';
        wait for 11 ns;

        rst <= '0';
        wait for 14 ns;

        assert value_out = x"1A"
        report print_error("wrong output value for RAM", x"1A", value_out) severity error;
        value_in <= x"BB";
        address  <= x"0A";
        wait for 10 ns;

        assert value_out = x"BB"
        report print_error("wrong output value for RAM", x"BB", value_out) severity error;
        write   <= '0';
        address <= x"00";
        wait for 10 ns;

        assert value_out = x"1A"
        report print_error("value should not have been modified", x"1A", value_out) severity error;
        offset <= x"10";
        value_in <= x"FF";
        address  <= x"2A";
        write   <= '1';
        wait for 10 ns;
        
        assert value_out = x"FF"
        report print_error("wrong output value for RAM", x"FF", value_out) severity error;
        use_offset <= '1';
        address  <= x"1A";
        write   <= '0';
        wait for 10 ns;
        
        assert value_out = x"FF"
        report print_error("value should not have been modified (1A + offset)", x"FF", value_out) severity error;
        
        
        end_clk <= '1';
        report "End of tests!" severity note;

        wait;
    end process memory_test_process;

end architecture testbench;
