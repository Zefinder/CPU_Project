library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_cell is
    generic(data_size : natural := 8);
    port(
        clk       : in  std_logic;
        write     : in  std_logic;
        value_in  : in  std_logic_vector(data_size - 1 downto 0);
        value_out : out std_logic_vector(data_size - 1 downto 0)
    );
end entity memory_cell;

architecture RTL of memory_cell is
    signal value : std_logic_vector(data_size - 1 downto 0);

begin
    write_cell : process(clk) is
    begin
        if rising_edge(clk) then
            if write = '1' then
                value <= value_in;
            end if;
        end if;
    end process write_cell;

    value_out <= value;

end architecture RTL;
