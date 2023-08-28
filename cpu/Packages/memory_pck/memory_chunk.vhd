library ieee;
library memory_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use memory_lib.memory_cell;

entity memory_chunk is
    generic(
        address_size : natural := 8;
        data_size    : natural := 8
    );
    port(
        clk       : in  std_logic;
        write     : in  std_logic;
        address   : in  std_logic_vector(address_size - 1 downto 0);
        value_in  : in  std_logic_vector(data_size - 1 downto 0);
        value_out : out std_logic_vector(data_size - 1 downto 0)
    );
end entity memory_chunk;

architecture RTL of memory_chunk is
    type values_array is array(natural range <>) of std_logic_vector(data_size - 1 downto 0); 
    
    signal cells_write : std_logic_vector((2 ** address'length) - 1 downto 0) := (others => '0');
    signal values_out  : values_array((2 ** address'length) - 1 downto 0);
    signal old_address : std_logic_vector(address_size - 1 downto 0);
    
begin
    generate_cells : for i in 0 to (2 ** address'length - 1) generate
        memory_cell_inst : entity memory_lib.memory_cell
            generic map(
                data_size => data_size
            )
            port map(
                clk       => clk,
                write     => cells_write(i),
                value_in  => value_in,
                value_out => values_out(i)
            );
    end generate generate_cells;

    value_out <= values_out(to_integer(unsigned(address)));
    cells_write(to_integer(unsigned(address))) <= write;

    reset_write : process(address, old_address) is
    begin
        if old_address /= address then
            old_address                                    <= address;
            cells_write(to_integer(unsigned(old_address))) <= '0';
        end if;
    end process reset_write;

end architecture RTL;
