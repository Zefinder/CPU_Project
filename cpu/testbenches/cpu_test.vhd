library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;
use utils.test_utils.all;

entity cpu_test is
end entity cpu_test;

architecture testbench of cpu_test is
    component cpu
        port(
            clk                : in  std_logic;
            instruction_vector : in  std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
            output             : out std_logic_vector(DATA_SIZE - 1 downto 0)
        );
    end component cpu;

    signal clk                : std_logic;
    signal instruction_vector : std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
    signal output             : std_logic_vector(DATA_SIZE - 1 downto 0);

    for all : cpu use entity work.cpu(RTL);

begin
    cpu_inst : component cpu
        port map(
            clk                => clk,
            instruction_vector => instruction_vector,
            output             => output
        );
    
    clk_process : process is
        variable counter : natural := 0;
    begin
        clk <= not clk;
        counter := counter + 5;
        wait for 5 ns;
        
        if counter = 5000 then
            wait;
        end if;
    end process clk_process;
    
    cpu_test_process : process is
    begin
        
    end process cpu_test_process;
    

end architecture testbench;
