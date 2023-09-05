library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

entity ram_memory is
    port(
        -- Clock used to update the data in memory cells
        clk       : in  std_logic;
        -- Reset used to put all memory to 0
        rst       : in  std_logic;
        -- Indicate if the memory cell at address __address__ must be written
        write     : in  std_logic;
        -- Address used to read and write in the memory
        address   : in  std_logic_vector(DATA_SIZE - 1 downto 0);
        -- Data to store in the memory
        value_in  : in  std_logic_vector(DATA_SIZE - 1 downto 0);
        -- Value of the cell pointed by __address__
        value_out : out std_logic_vector(DATA_SIZE - 1 downto 0)
    );
end entity ram_memory;

architecture RTL of ram_memory is
    -- Memory that goes from 0 to the max number an address can go
    signal memory : t_memory_array(0 to 2 ** address'length - 1);

begin
    write_memory : process(clk, rst) is
    begin
        if rst = '1' then
            memory <= (others => (others => '0'));
        elsif rising_edge(clk) and write = '1' then
            memory(to_integer(unsigned(address))) <= value_in;
        end if;
    end process write_memory;

    value_out <= memory(to_integer(unsigned(address)));

end architecture RTL;
