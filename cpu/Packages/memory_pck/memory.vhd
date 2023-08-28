library ieee;
library memory_lib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    generic(
        chunk_address_size : natural := 8;
        cell_address_size  : natural := 8;
        data_size          : natural := 8
    );
    port(
        clk       : in  std_logic;
        write     : in  std_logic;
        address   : in  std_logic_vector(chunk_address_size + cell_address_size - 1 downto 0);
        value_in  : in  std_logic_vector(data_size - 1 downto 0);
        value_out : out std_logic_vector(data_size - 1 downto 0)
    );
end entity memory;

architecture RTL of memory is
    type values_array is array (natural range <>) of std_logic_vector(data_size - 1 downto 0);

    constant memory_address_size : natural := chunk_address_size + cell_address_size;

    signal chunk_write : std_logic_vector((2 ** chunk_address_size) - 1 downto 0) := (others => '0');
    signal values_out  : values_array((2 ** chunk_address_size) - 1 downto 0);
    signal old_address : std_logic_vector(chunk_address_size - 1 downto 0);

begin
    generate_cells : for i in 0 to (2 ** chunk_address_size - 1) generate
        memory_chunk_inst : entity memory_lib.memory_chunk
            generic map(
                address_size => cell_address_size,
                data_size    => data_size
            )
            port map(
                clk       => clk,
                write     => chunk_write(i),
                address   => address(cell_address_size - 1 downto 0),
                value_in  => value_in,
                value_out => values_out(i)
            );
    end generate generate_cells;

    value_out                                                                            <= values_out(to_integer(unsigned(address(memory_address_size - 1 downto cell_address_size))));
    chunk_write(to_integer(unsigned(address(memory_address_size - 1 downto chunk_address_size)))) <= write;

    reset_write : process(address, old_address) is
    begin
        if old_address /= address((memory_address_size - 1) downto cell_address_size) then
            old_address                                    <= address(memory_address_size - 1 downto cell_address_size);
            chunk_write(to_integer(unsigned(old_address))) <= '0';
        end if;
    end process reset_write;
end architecture RTL;
