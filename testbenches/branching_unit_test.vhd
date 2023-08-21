library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

entity branching_unit_test is
end entity branching_unit_test;

architecture testbench of branching_unit_test is
    component branching_unit
        port(
            branching_address      : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            offset                 : in  std_logic_vector(DATA_SIZE - 1 downto 0);
            use_offset             : in  std_logic;
            flag                   : in  std_logic;
            is_inverted_test       : in  std_logic;
            out_program_counter    : out std_logic_vector(DATA_SIZE - 1 downto 0);
            update_program_counter : out std_logic
        );
    end component branching_unit;

    for all : branching_unit use entity work.branching_unit(RTL);

    signal branching_address      : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');
    signal offset                 : std_logic_vector(DATA_SIZE - 1 downto 0) := (others => '0');
    signal use_offset             : std_logic                                := '0';
    signal flag                   : std_logic                                := '0';
    signal is_inverted_test       : std_logic                                := '0';
    signal out_program_counter    : std_logic_vector(DATA_SIZE - 1 downto 0);
    signal update_program_counter : std_logic;
begin

    branching_unit_inst : component branching_unit
        port map(
            branching_address   => branching_address,
            offset              => offset,
            use_offset          => use_offset,
            flag                => flag,
            is_inverted_test    => is_inverted_test,
            out_program_counter => out_program_counter,
            update_program_counter => update_program_counter
        );

    branching_process_write_test : process is
    begin
        flag <= '0';
        is_inverted_test <= '0';
        
        wait for 5 ns;
        assert update_program_counter = '0' 
        report "Error: should not update pc (flag='0',inverted='0')" severity error;
        flag <= '1';
        is_inverted_test <= '0';
        
        wait for 5 ns;
        assert update_program_counter = '1' 
        report "Error: should update pc (flag='1',inverted='0')" severity error;
        flag <= '0';
        is_inverted_test <= '1';
    
        wait for 5 ns;
        assert update_program_counter = '1' 
        report "Error: should update pc (flag='0',inverted='1')" severity error;
        flag <= '1';
        is_inverted_test <= '1';
        
        wait for 5 ns;
        assert update_program_counter = '0' 
        report "Error: should not update pc (flag='1',inverted='1')" severity error;

        wait;
    end process branching_process_write_test;
    

    branching_process_test : process is
        variable branching_address_variable : natural   := 0;
        variable offset_variable            : natural   := 0;
        variable use_offset_variable        : std_logic := '0';

        variable branching_address_variable_vector : std_logic_vector(DATA_SIZE - 1 downto 0);
        variable offset_variable_vector            : std_logic_vector(DATA_SIZE - 1 downto 0);

        variable loop_number : natural := 0;
    begin
        wait for 5 ns;

        -- Assert values
        branching_address_variable_vector := std_logic_vector(to_unsigned(branching_address_variable, DATA_SIZE));
        assert branching_address = branching_address_variable_vector
        report "Error: branching vectors not of the same value" severity error;

        offset_variable_vector := std_logic_vector(to_unsigned(offset_variable, DATA_SIZE));
        assert offset = offset_variable_vector
        report "Error: offset vectors not of the same value" severity error;

        assert use_offset = use_offset_variable
        report "Error: use offset different" severity error;

        if use_offset = '1' then
            branching_address_variable_vector := std_logic_vector(unsigned(branching_address_variable_vector) + unsigned(offset_variable_vector));
        end if;

        assert out_program_counter = branching_address_variable_vector
        report "Wrong output, expected " & to_hstring(branching_address_variable_vector) & " but got " & to_hstring(out_program_counter)
        severity error;

        -- Variable update
        if offset_variable = 2 ** DATA_SIZE - 1 then
            offset_variable := 0;

            if branching_address_variable = 2 ** DATA_SIZE - 1 then
                branching_address_variable := 0;
                use_offset_variable        := not use_offset_variable;
                loop_number                := loop_number + 1;
            else
                branching_address_variable := branching_address_variable + 1;
            end if;
        else
            offset_variable := offset_variable + 1;
        end if;

        -- Signal assignment
        branching_address <= std_logic_vector(to_unsigned(branching_address_variable, DATA_SIZE));
        offset            <= std_logic_vector(to_unsigned(offset_variable, DATA_SIZE));
        use_offset        <= use_offset_variable;

        -- End detection
        if loop_number = 2 then
            report "End of tests!" severity note;
            wait;
        end if;
    end process branching_process_test;

end architecture testbench;
