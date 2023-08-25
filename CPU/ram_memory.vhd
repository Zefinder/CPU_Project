library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

entity ram_memory is
    port(
        -- Clock used to update the data in memory cells
        clk       : in  std_logic;
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
    -- Array of std_logic used to store data
    type t_memory is array (natural range <>) of std_logic_vector(DATA_SIZE - 1 downto 0);
    
    -- Memory that goes from 0 to the max number an address can go
    signal memory : t_memory(0 to 2 ** address'length - 1);

begin

    write_memory : process(clk, address, memory) is
    begin
        if rising_edge(clk) and write = '1' then
            memory(to_integer(unsigned(address))) <= value_in;
        end if;
        
        value_out <= memory(to_integer(unsigned(address)));

    end process write_memory;

end architecture RTL;
