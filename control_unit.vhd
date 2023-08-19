library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library utils;
use utils.cpu_utils.all;

entity control_unit is
    port(
        -- Contains the instruction to process, 4 bytes (opcode-A-B-address)
        instruction_vector      : in  std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
        -- First operand to give to the ALU
        operand1                : out std_logic_vector(DATA_SIZE - 1 downto 0);
        -- Second operand to give to the ALU
        operand2                : out std_logic_vector(DATA_SIZE - 1 downto 0);
        -- Selector of the ALU
        alu_selector            : out std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
        -- Address used to read a register (sends it to the first operand of the ALU)
        register_address_read_1 : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Address used to read a register (sends it to the second operand of the ALU)
        register_address_read_2 : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Address used to write in a register
        register_address_write  : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Address used to read a flag
        flag_address            : out std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
        -- Address used to read and write in the RAM
        ram_address             : out std_logic_vector(DATA_SIZE - 1 downto 0);
        -- Uses the result of the ALU
        use_alu                 : out std_logic;
        -- Uses the content of a register and outputs it to the first output (specified by __register_address_read_1__)
        use_register_1          : out std_logic;
        -- Uses the content of a register and outputs it to the second output (specified by __register_address_read_2__)
        use_register_2          : out std_logic;
        -- Uses the content of the memory cell for the input of the register bank (specified by __memory_address_read__)
        use_memory_for_register : out std_logic;
        -- Uses the content of the register for the input of the memory (specified by __register_address_read_1__)
        use_register_for_memory : out std_logic;
        -- Indicate if the register at address __register_address_write__ must be written
        write_register          : out std_logic;
        -- Indicate if the ram memory cell at address __ram_address_write__ must be written
        write_ram               : out std_logic
    );
end entity control_unit;

-- Division of opcode (instruction[7;0])
-- 
-- ## For the ALU:
-- TODO Enable putting in memory
--
-- | Bit position | Function |
-- | :----------: | :------: |
-- | Bit 7 | UNUSED |
-- | Bit 6 | UNUSED |
-- | Bit 5 | USE_REG_2 |
-- | Bit 4 | USE_REG_1 |
-- | Bit 3 | EN_ALU (Always 1) |
-- | Bit 2 | ALU_SEL_2 |
-- | Bit 1 | ALU_SEL_1 |
-- | Bit 0 | ALU_SEL_0 |
--
-- ## For non-branch instructions
--
-- | Bit position | Function |
-- | :----------: | :------: |
-- | Bit 7 | STR_MEM |
-- | Bit 6 | STR_REG |
-- | Bit 5 | USE_MEM |
-- | Bit 4 | USE_REG |
-- | Bit 3 | EN_ALU (Always 0) |
-- | Bit 2 | UNUSED |
-- | Bit 1 | EN_BRANCH (Always 0) |
-- | Bit 0 | UNUSED |
--
-- ## For branch instructions
-- TODO Enable register offet branching
--
-- | Bit position | Function |
-- | :----------: | :------: |
-- | Bit 7 | UNUSED |
-- | Bit 6 | UNUSED |
-- | Bit 5 | FL_SEL_1 |
-- | Bit 4 | FL_SEL_0 |
-- | Bit 3 | EN_ALU (Always 0) |
-- | Bit 2 | UNUSED |
-- | Bit 1 | EN_BRANCH (Always 1) |
-- | Bit 0 | EN_REL_BRANCH |
architecture RTL of control_unit is
    -- ALU opcode bits (still unused bit 6 and 7)
    -- TODO Bit that inputs the result of the ALU in the memory

    -- Bit representing the usage of the second register
    constant USE_REG_2 : natural := 5;
    -- Bit representing the usage of the first register
    constant USE_REG_1 : natural := 4;
    -- Bit that enables the ALU
    constant EN_ALU    : natural := 3;
    -- Bit representing the third ALU selector bit
    constant ALU_SEL_2     : natural := 2;
    -- Bit representing the second ALU selector bit
    constant ALU_SEL_1     : natural := 1;
    -- Bit representing the first ALU selector bit
    constant ALU_SEL_0     : natural := 0;
    
    -- Non branching opcode bits
    
    -- Bit enabling storage in the RAM memory
    constant STR_MEM : natural := 7;
    -- Bit enabling storage in the register bank
    constant STR_REG : natural := 6;
    -- Bit putting memory output to register input
    constant USE_MEM : natural := 5;
    -- Bit putting register output to memory input
    constant USE_REG : natural := 4;
    
    -- Branching opcodes bits
    -- Bit representing the usage of the second register
    constant FL_SEL_1 : natural := 5;
    -- Bit representing the usage of the first register
    constant FL_SEL_0 : natural := 4;
    -- Bit representing the usage of the first register
    constant EN_BRANCH : natural := 1;
    -- Bit representing the usage of the first register
    constant EN_REL_BRANCH : natural := 0;

    -- Opcode of the instruction, it has the information of the instruction and the addressing mode
    signal instruction_opcode  : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- First operand of the instruction
    signal instruction_a       : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Second operand of the instruction
    signal instruction_b       : std_logic_vector(DATA_SIZE - 1 downto 0);
    -- Additionnal address in the instruction
    signal instruction_address : std_logic_vector(DATA_SIZE - 1 downto 0);

begin

    control_unit_process : process(instruction_a, instruction_b, instruction_opcode, instruction_address, instruction_vector) is
    begin
        instruction_opcode  <= instruction_vector(4 * DATA_SIZE - 1 downto 3 * DATA_SIZE);
        instruction_a       <= instruction_vector(3 * DATA_SIZE - 1 downto 2 * DATA_SIZE);
        instruction_b       <= instruction_vector(2 * DATA_SIZE - 1 downto DATA_SIZE);
        instruction_address <= instruction_vector(DATA_SIZE - 1 downto 0);

        alu_selector <= instruction_opcode(ALU_SEL_2) & instruction_opcode(ALU_SEL_1) & instruction_opcode(ALU_SEL_0);

        operand1 <= instruction_a;
        operand2 <= instruction_b;

        register_address_read_1 <= instruction_address(DATA_SIZE - 1 downto DATA_SIZE / 2);
        register_address_read_2 <= instruction_address(DATA_SIZE / 2 - 1 downto 0);

        ram_address <= instruction_address;

        -- If the ALU is on, then you don't use the other opcode bits the same way
        if instruction_opcode(EN_ALU) = '1' then
            -- We use the ALU in ALU mode, yes you are not crazy
            use_alu <= '1';

            -- We use the ALU result for the register
            use_memory_for_register <= '0';

            -- We do not use the register for memory
            use_register_for_memory <= '0';

            -- We write in the register at the end of the ALU
            write_register <= '1';

            -- We don't write in the memory with the ALU (TODO need to change)
            write_ram <= '0';

            -- We put the flag at Carry for the ALU
            flag_address <= FLAG_C_ADDR;

            -- We use the first register output if the bit is set
            use_register_1 <= instruction_opcode(USE_REG_1);

            -- We use the second register output if the bit is set
            use_register_2 <= instruction_opcode(USE_REG_2);

            -- Get the address of the register to write
            if instruction_opcode(USE_REG_1) = '1' and instruction_opcode(USE_REG_2) = '1' then
                register_address_write <= instruction_b(DATA_SIZE - 1 downto DATA_SIZE / 2);
            elsif instruction_opcode(USE_REG_1) = '1' and instruction_opcode(USE_REG_2) = '0' then
                register_address_write <= instruction_address(DATA_SIZE / 2 - 1 downto 0);
            else
                register_address_write <= instruction_address(DATA_SIZE - 1 downto DATA_SIZE / 2);
            end if;
        else
            -- The ALU is disabled
            use_alu <= '0';
            
            -- We check if it is a branch instruction
            -- TODO Do the branh instruction
            if instruction_opcode(EN_BRANCH) = '1' then
            else
                
            end if;
            
        end if;

    end process control_unit_process;

end architecture RTL;
