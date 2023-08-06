library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flag_bank is
    generic(
                -- Size of the flag selector
        flag_selector_size     : natural := 2
    );
    port(
        -- Clock used to update flags
        clk : in std_logic;
        -- Selector used to output a flag
        flag_selector : in std_logic_vector(flag_selector_size - 1 downto 0);
        -- The input flags to update if needed
        input_flags : in std_logic_vector(2 ** flag_selector_size - 1 downto 0);
        -- Updates flags if up
        update_flags : in std_logic;
        -- Flag selected by the __flag_selector__
        output_flag : out std_logic
    );
end entity flag_bank;

architecture RTL of flag_bank is
    -- Memory of flags
    signal flags : std_logic_vector(2 ** flag_selector_size downto 0);
begin
    
    flags_update_process : process(clk) is
    begin
        if rising_edge(clk) and update_flags = '1' then
            flags <= input_flags;
        end if;
    end process flags_update_process;
    
    output_flag <= flags(to_integer(unsigned(flag_selector)));
end architecture RTL;
