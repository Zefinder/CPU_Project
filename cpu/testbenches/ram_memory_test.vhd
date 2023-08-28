library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_memory_test is
end entity ram_memory_test;

architecture testbench of ram_memory_test is

    constant ADDRESS_SIZE : natural := 8;
    constant DATA_SIZE    : natural := 8;

    component ram_memory
        generic(DATA_SIZE : natural := 8);
        port(
            clk       : in  std_logic;
            write     : in  std_logic;
            address   : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            value_in  : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            value_out : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component ram_memory;
    for all : ram_memory use entity work.ram_memory(RTL);

    signal clk       : std_logic                                   := '0';
    signal write     : std_logic                                   := '1';
    signal address   : std_logic_vector(ADDRESS_SIZE - 1 downto 0) := x"00";
    signal value_in  : std_logic_vector(DATA_SIZE - 1 downto 0)    := x"1A";
    signal value_out : std_logic_vector(DATA_SIZE - 1 downto 0); -- @suppress "signal value_out is never read"
begin

    memory_inst : component ram_memory
        generic map(
            DATA_SIZE => DATA_SIZE
        )
        port map(
            clk       => clk,
            write     => write,
            address   => address,
            value_in  => value_in,
            value_out => value_out
        );

    clk_timing : process is
        variable counter : natural := 0;

    begin
        clk     <= not clk;
        counter := counter + 1;
        wait for 5 ns;

        if counter = 6 then
            wait;
        end if;

    end process clk_timing;

    memory_test_process : process is
    begin
        wait for 6 ns;

        assert value_out = x"1A" report "Error: expected 0x1A but got " & to_hstring(value_out) severity error;
        value_in <= x"BB";
        address  <= x"0A";
        wait for 10 ns;

        assert value_out = x"BB" report "Error: expected 0xBB but got " & to_hstring(value_out) severity error;
        write   <= '0';
        address <= x"00";
        wait for 10 ns;

        assert value_out = x"1A"
        report "Error: value should not have been modified, expected 0x1A but got " & to_hstring(value_out) severity error;
        report "End of tests!" severity note;

        wait;
    end process memory_test_process;

end architecture testbench;
