library ieee;
library utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use utils.cpu_utils.all;

entity control_unit is
    port(
        -- Contains the instruction to process, 4 bytes (opcode-A-B-address)
        instruction_vector                 : in  std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
        -- First operand to give to the ALU
        operand1                           : out std_logic_vector(BYTE_SIZE - 1 downto 0);
        -- Second operand to give to the ALU
        operand2                           : out std_logic_vector(BYTE_SIZE - 1 downto 0);
        -- Third operand to give to the ALU
        operand3                           : out std_logic_vector(BYTE_SIZE - 1 downto 0);
        -- Selector of the ALU
        alu_selector                       : out std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);
        -- Address used to read a register (sends it to the first operand of the ALU)
        register_address_read_1            : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Address used to read a register (sends it to the second operand of the ALU)
        register_address_read_2            : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Address used to read a register (sends it to the memory address)
        register_address_read_3            : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Address used to write in a register
        register_address_write             : out std_logic_vector(REGISTER_SELECTOR_SIZE - 1 downto 0);
        -- Address used to read a flag
        flag_address                       : out std_logic_vector(FLAG_SELECTOR_SIZE - 1 downto 0);
        -- Uses the result of the ALU
        use_alu                            : out std_logic;
        -- Updates only one flag (specified by __flag_address__)
        update_one_flag                    : out std_logic;
        -- Uses the content of a register and outputs it to the first output (specified by __register_address_read_1__)
        use_register_1                     : out std_logic;
        -- Uses the register output as register input
        use_register_for_register          : out std_logic;
        -- Uses the content of the memory cell for the input of the register bank (specified by __memory_address_read__)
        use_memory_for_register            : out std_logic;
        -- Uses the output of the branching unit as load for the register
        use_branching_unit                 : out std_logic;
        -- Uses the branching offset
        use_branching_offset               : out std_logic;
        -- Uses the first register for branching address
        use_register_for_branching_address : out std_logic;
        -- Uses the second register for branching offset
        use_register_for_branching_offset  : out std_logic;
        -- Tests if the flag is not set
        branch_invert_flag                 : out std_logic;
        -- Indicate if the register at address __register_address_write__ must be written
        write_register                     : out std_logic;
        -- Indicate if the ram memory cell at address __ram_address_write__ must be written
        write_ram                          : out std_logic;
        -- Uses the offset for __ram_address_write__
        use_ram_offset                     : out std_logic
    );
end entity control_unit;

-- Division of opcode (instruction_vector[31;24])
-- 
-- ## For the ALU:
-- TODO Enable putting in memory
--
-- | Bit position | Function |
-- | :----------: | :------: |
-- | Bit 7 | UNUSED |
-- | Bit 6 | ALU_SEL_3 |
-- | Bit 5 | USELESS (ALU_SEL_4) |
-- | Bit 4 | USE_REG_1 |
-- | Bit 3 | EN_ALU (Always 1) |
-- | Bit 2 | ALU_SEL_2 |
-- | Bit 1 | ALU_SEL_1 |
-- | Bit 0 | ALU_SEL_0 |
--
-- ## For non-branch instructions
-- TODO Add register offset (use speacial opcode)
--
-- | Bit position | Function |
-- | :----------: | :------: |
-- |    Bit 7     | STR_MEM |
-- |    Bit 6     | STR_REG |
-- |    Bit 5     | USE_MEM |
-- |    Bit 4     | MEM_OFFSET |
-- |    Bit 3     | EN_ALU (Always 0) |
-- |    Bit 2     | UNUSED |
-- |    Bit 1     | EN_BRANCH (Always 0) |
-- |    Bit 0     | USE_REG |
--
-- ## For branch instructions
--
-- | Bit position | Function |
-- | :----------: | :------: |
-- | Bit 7 | FL_SEL_1 |
-- | Bit 6 | FL_SEL_0 |
-- | Bit 5 | USE_REG_OFFSET |
-- | Bit 4 | USE_REG_ADDR |
-- | Bit 3 | EN_ALU (Always 0) |
-- | Bit 2 | INV_FLAG |
-- | Bit 1 | EN_BRANCH (Always 1) |
-- | Bit 0 | EN_REL_BRANCH |
architecture RTL of control_unit is
    -- Opcode of the instruction, it has the information of the instruction and the addressing mode
    signal instruction_opcode  : std_logic_vector(BYTE_SIZE - 1 downto 0);
    -- First operand of the instruction
    signal instruction_a       : std_logic_vector(BYTE_SIZE - 1 downto 0);
    -- Second operand of the instruction
    signal instruction_b       : std_logic_vector(BYTE_SIZE - 1 downto 0);
    -- Additionnal address in the instruction
    signal instruction_address : std_logic_vector(BYTE_SIZE - 1 downto 0);
    -- Signal of ALU selector
    signal alu_selector_sig : std_logic_vector(ALU_SELECTOR_SIZE - 1 downto 0);

begin

    alu_selector_sig    <= instruction_opcode(ALU_SEL_3) & instruction_opcode(ALU_SEL_2) & instruction_opcode(ALU_SEL_1) & instruction_opcode(ALU_SEL_0);
    instruction_opcode  <= instruction_vector(4 * BYTE_SIZE - 1 downto 3 * BYTE_SIZE);
    instruction_a       <= instruction_vector(3 * BYTE_SIZE - 1 downto 2 * BYTE_SIZE);
    instruction_b       <= instruction_vector(2 * BYTE_SIZE - 1 downto BYTE_SIZE);
    instruction_address <= instruction_vector(BYTE_SIZE - 1 downto 0);

    control_unit_process : process(instruction_a, instruction_b, instruction_opcode, instruction_address, alu_selector_sig) is
    begin
        update_one_flag <= instruction_opcode(ALU_SEL_3);

        alu_selector <= alu_selector_sig;

        operand1 <= instruction_a;
        operand2 <= instruction_b;
        operand3 <= instruction_address;

        register_address_read_1 <= instruction_a(REGISTER_SELECTOR_SIZE - 1 downto 0);
        register_address_read_2 <= instruction_b(REGISTER_SELECTOR_SIZE - 1 downto 0);
        register_address_read_3 <= instruction_address(REGISTER_SELECTOR_SIZE - 1 downto 0);

        use_branching_offset               <= instruction_opcode(EN_REL_BRANCH);
        branch_invert_flag                 <= instruction_opcode(INV_FLAG);
        use_register_for_branching_address <= instruction_opcode(USE_REG_ADDR);
        use_register_for_branching_offset  <= instruction_opcode(USE_REG_OFFSET);
        
        use_register_for_register <= instruction_opcode(USE_REG);

        -- If the ALU is on, then you don't use the other opcode bits the same way
        if instruction_opcode(EN_ALU) = '1' then
            -- We use the ALU in ALU mode, yes you are not crazy
            use_alu <= '1';

            -- We don't use memory for register and register for memory
            use_memory_for_register <= '0';
            use_ram_offset          <= '0';

            -- We do not use the branching unit
            use_branching_unit <= '0';

            -- We write in the register at the end of the ALU
            if alu_selector_sig = "0111" or instruction_opcode(ALU_SEL_3) = '1' then
                write_register <= '0';
            else
                write_register <= '1';
            end if;

            -- We don't write in the memory with the ALU (TODO need to change)
            write_ram <= '0';

            -- We put the flag at Carry for the ALU
            flag_address <= FLAG_C_ADDR;

            -- We use the first register output if the bit is set
            use_register_1 <= instruction_opcode(USE_REG_1);

            -- Get the address of the register to write
            register_address_write <= instruction_address(BYTE_SIZE / 2 - 1 downto 0);
        else
            -- The ALU is disabled
            use_alu <= '0';

            -- Not use register for alu
            use_register_1 <= '0';

            -- We check if it is a branch instruction
            if instruction_opcode(EN_BRANCH) = '1' then
                -- We enable the branching unit
                use_branching_unit <= '1';

                -- We change the value of the program counter (even if there is no instruction memory for now)
                register_address_write <= REG_PC;

                -- We put the flag address to the selectors
                flag_address <= instruction_opcode(FL_SEL_1) & instruction_opcode(FL_SEL_0);

                -- We don't use memory for register and register for memory
                use_memory_for_register <= '0';
                use_ram_offset          <= '0';

                -- We write in PC so we write in the register
                write_register <= '1';

                -- We don't write in the memory
                write_ram <= '0';
            else
                -- We do not use the branching unit
                use_branching_unit <= '0';

                -- No usage of it so we put it to C flag
                flag_address <= FLAG_C_ADDR;

                -- Register write always the last part of b operator
                register_address_write <= instruction_address(BYTE_SIZE / 2 - 1 downto 0);

                -- We use the memory output for the register input if the bit is set
                use_memory_for_register <= instruction_opcode(USE_MEM);

                -- We use the register output for the memory input if the bit is set
                use_ram_offset <= instruction_opcode(MEM_OFFSET);

                -- We write in the memory if the bit is set
                write_ram <= instruction_opcode(STR_MEM);

                -- We write in the register if the bit is set
                write_register <= instruction_opcode(STR_REG);
            end if;

        end if;

    end process control_unit_process;

end architecture RTL;
