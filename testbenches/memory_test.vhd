library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_test is
end entity memory_test;

architecture testbench of memory_test is

    constant address_size : natural := 16;
    constant data_size : natural := 8;

    component ram_memory
        port(
            clk       : in  std_logic;
            write     : in  std_logic;
            address   : in  std_logic_vector(address_size - 1 downto 0);
            value_in  : in  std_logic_vector(data_size - 1 downto 0);
            value_out : out std_logic_vector(data_size - 1 downto 0)
        );
    end component ram_memory;
    for all : ram_memory use entity work.ram_memory(RTL);

    signal clk       : std_logic                     := '0';
    signal write     : std_logic                     := '0';
    signal address   : std_logic_vector(address_size - 1 downto 0) := x"0000";
    signal value_in  : std_logic_vector(data_size - 1 downto 0)  := x"00";
    signal value_out : std_logic_vector(data_size - 1 downto 0); -- @suppress "signal value_out is never read"
begin

    memory_inst : component ram_memory
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

        if counter > 10 then
            assert false report "End of tests!" severity note;
            wait;
        end if;

        wait for 5 ns;
    end process clk_timing;

    write    <= '1' after 6 ns, '0' after 16 ns, '1' after 26 ns;
    value_in <= x"1A" after 7 ns, x"BB" after 12 ns;
    address  <= x"000A" after 11 ns, x"0000" after 17 ns;

end architecture testbench;
