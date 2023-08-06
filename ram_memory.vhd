library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_memory is
    generic (
        data_size : natural := 8
    );
    port(
        clk       : in  std_logic;
        write     : in  std_logic;
        address   : in  std_logic_vector(data_size - 1 downto 0);
        value_in  : in  std_logic_vector(data_size - 1 downto 0);
        value_out : out std_logic_vector(data_size - 1 downto 0)
    );
end entity ram_memory;

architecture RTL of ram_memory is
    type t_memory is array (natural range <>) of std_logic_vector(data_size - 1 downto 0);
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
