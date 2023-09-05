library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

entity register_bank is
    port(
        -- Clock used to update register content
        clk                     : in  std_logic;
        -- Reset used to put all registers at 0
        rst                     : in  std_logic;
        -- Address used to read a first register
        register_address_read_1 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Address used to read a second register
        register_address_read_2 : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Address used to write in a register
        register_address_write  : in  std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Data that must be written to a register (specified by __register_address_write__)
        register_load           : in  std_logic_vector(DATA_SIZE - 1 downto 0);
        -- Indicate if the register at address __register_address_write__ must be written
        write_register          : in  std_logic;
        -- First register output (specified by __register_address_read_1__)
        register_output_1       : out std_logic_vector(DATA_SIZE - 1 downto 0);
        -- Second register output (specified by __register_address_read_2__)
        register_output_2       : out std_logic_vector(DATA_SIZE - 1 downto 0)
    );
end entity register_bank;

architecture RTL of register_bank is
    -- Array of registers
    signal register_array : t_memory_array(2 ** REGISTER_SELECTOR_SIZE - 1 downto 0);
begin

    -- Writing __register_load__ to the register given by the address
    -- __register_address_write__ when write is up and clock
    write_register_process : process(clk, rst) is
    begin
        if rst = '1' then
            register_array <= (others => (others => '0'));
        elsif rising_edge(clk) and write_register = '1' then
            register_array(to_integer(unsigned(register_address_write))) <= register_load;
        end if;
    end process write_register_process;

    -- Writing to the register outputs
    register_output_1 <= register_array(to_integer(unsigned(register_address_read_1)));
    register_output_2 <= register_array(to_integer(unsigned(register_address_read_2)));

end architecture RTL;
