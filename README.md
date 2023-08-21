# CPU_Project
## Overall presentation of the project
This is a summer project where I have fun creating a CPU in VHDL using `Sigasi Studio` (that I can only recommend). This is to calm all this stress and frustration of the CPU project we had at school! So now I take pleasure to do it. If you want to participate, tell me!

## Organisation of the project
This project is, for now, only to make a 8-bits CPU without any pipeline levels. If I want to, I will implement pipelines, increase the data size, add a few more instructions, blablabla. This will only depend on how much I want to finish it. 

I will probably make a compiler, an interpreter and documentation of this CPU so it will be possible to use its assembly or to compile from C to this assembly for this CPU. Why not making an OS for this CPU hahaha

This CPU has a few components. The one that are ok are marked with (\/) currently developped are marked with (\*), the ones that are developped but where tests are lacking or are simply not implemented are marked with (+), the ones that still need to be developped are marked with (#) and finally the ones that will be improved are marked with ($).

- ALU				(\/)($) (Add a new bit of selector for flag set and reset)
- Register bank 	(\/)
- Flag bank			(\/)($) (To follow the new ALU)
- Branching unit	(\/)
- RAM memory		(\/)($)
- Control unit      (\*)(+)($)
- CPU as a whole    (\*)(+)(#)

The further developpement I can see is to find an FPGA where you can plug a mass memory to store programs on and configure the FPGA to start on a specific address of the memory to run a specific program. This configuration will load the program into the CPU instruction memory and then launch it. It will make the CPU easier to use (not modifying the constant array each time! Efficiency go brrr). Hence the few other components I see to add:

- Instruction memory 	(#)
- Instruction loader 	(#)
- Program chooser		(#)

Maybe that only a CPU is a little sad, like you have the process unit ok but you don't have anything to interract with it. You will get the same result again and again... It's perfect for tests I agree, but still if we could add a little more things... 

- Change the RAM memory and instruction memory to a bus (16 bits?)		(#)
- Bus mapper															(#)
- Increase the RAM														(#) 
- Make all registers not the same size (like the PC would be 16 bits)	(#)

Yes this is perfect, so now you can map things to a bus, and so interract with them! You would be able to event connect a screen and create a little game (Possible with a 16 byte of RAM, look how much RAM they used for Super Mario Bros ha ha)? I guess that everything would be possible with a bus, the used would need to make the mapping and not me! And I leave them the creation of a PPU or a GPU :)

Or maybe make all registers the same size, I mean 16 bits is a lot and not hard to do but it takes a lot of space...

## Configuration of the IDE
I chose Sigasi Studio for my IDE since it's waaaaaaay better than Vivado or other tools that I've already tried. However it does not include a compiler nor a simulator nor anything to synthetise (or implement). It is possible to link one to Sigasi and this is the whole point of this paragraph (I'm organised!).

### Compiler and simulator setup
Sigasi have already options for loads of compilers and I chose **GHDL**, open source compiler written in ADA, which is available for both Windows and Linux. To setup GHDL for the compilation, go to **Window > Preferences** and then **Sigasi > Toolchains > GHDL**. Select the bin path of the GHDL directory and you will just have to launch the simulation from the Hierarchy View! *(Do not forget to set the correct unit as top level...)*.

I also configured a simulation folder (named `simulation`) where all vcd files go. Here is the line I used to configure it like that:

```
--vcd='${sigasi_toplevel:project_path}/simulation/${sigasi_toplevel:short}.vcd'
```

Click on the **Toolchains** item in the tree and select **GHDL**. Please apply before closing...

### Run setup
It can also be a good idea to have something to read the vcd files (to see the trace of signals throughout the simulation) and this can be directly configured within Sigasi Studio. If you have Linux this is easy, just enter the command you want, if you have Windows... get prepared. Go to **Run > External Tools > External tools configuration** and create a new run configuration. 

- For Windows
You will have work to do to succeed but a way to do it is to use the Linux virtual machine for Windows (WSL) (If I find an easier way I'll put it also)

In Windows Explorer, go to the `workspaceSigasi` directory, create a **batch** script (that I will call `simu.bat`) and put this (of course you can modify it...): 

```batch
@echo off
rem ENTER YOUR PROJECT DIRECTORY NAME
set DIR_NAME=CPU_Project

rem ENTER YOUR BASH SCRIPT NAME (eg. simu.sh)
set SCRIPT_NAME=simu.sh

rem ENTER UNIX PATH TO WINDOWS
set UNIX_C=/mnt/c

rem TOUCH AND YOU ARE DEAD
set SCRIPT_PATH=%cd%
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set SCRIPT_PATH=%UNIX_C%%SCRIPT_PATH:~2%
bash -c "%SCRIPT_PATH%/%SCRIPT_NAME% \"%SCRIPT_PATH%/%DIR_NAME%/simulation/%1\""
```

Still in the same directory create a **bash** script (that I will call `simu.sh`). I will use gtk waves for it:

```bash
#!/usr/bin/bash
echo "Launching wave simulation for $1"
gtkwave "$1"
```

**WARNING** it can say that there is an error at line 1 with something like `#!/usr/bin/bash^M`. It's becase Unix does not use the same new lines, so in that case use Notepad++ to convert the file in Unix style: **Edit > EOL Conversion > Unix (LF)**.

Return in the external tool configuration and in the **location** field you can put the full path to your **batch** script, in the **workspace location** field put the path to your `workspaceSigasi` and as argument put `${selected_resource_name}`.

- Linux

You can directly launch gtk waves or create a script if you want to do something else before (like deleting the file). Just be careful, `${selected_resource_name}` only give the file name (eg. `ram_memory_test.vcd`), not the full path! Try things I don't know, I'm a Windows user!

### Troubleshooting
- There is an error with gtkwaves
I'm 100% sure you forgot to install gtkwaves, try to install it.

- There is an error where it can't find the simulation folder when launching simulation
Have you tried to create a `simulation` folder? 

- I have the following error:
```
Unable to resource a selected resource:
${selected_resource_name}
```

The `${selected_resource_name}` variable takes the name of the selected resource of the `Project Explorer` tree. Select a file and then you will be able to launch it! This deselection can happen when you delete a file or when you closed the `Project Explorer` tree view.

- I have an error when I launch a file, gtk says : `Why: No such file or directory` but the file exist!

Make sure you selected a file in the simulation directory and that this file is a `.vcd` file. Else it will search for your file in the `simulation` directory and not find it (normal!).

- My .vcd file is going bigger and bigger and bigger, what the hell????

VHDL is a great language and the simulation works well... maybe too well. I am not here to make a VHDL class, however you might not have:
- A `wait` statement in all your processes
- Stopped your simulation when you want to if it's made on purpose.

Here is an example of a test that **will never stop**:

```vhdl
memory_test_process : process is
begin
    a <= x"00";
    wait for 5 ns;
    a <= x"10";
    
    wait;
end process memory_test_process;

clk_timing : process is
    variable counter : natural := 0;

begin
    clk     <= not clk;
    wait for 5 ns;
end process clk_timing;
```

Here is an example of a test that **will stop**:

```vhdl
memory_test_process : process is
begin
    a <= x"00";
    wait for 5 ns;
    a <= x"10";
    
    wait;
end process memory_test_process;

clk_timing : process is
    variable counter : natural := 0;

begin
    clk     <= not clk;
    counter := counter + 1;
    wait for 5 ns;

    if counter = 10 then -- This will happen someday!
        wait;
    end if;

end process clk_timing;
```

This goes to 1GB really fast, be carefull to not forget to stop the simulation!

## CPU capabilities
Of course, I won't make a CPU without exposing what you can do with it. As I still continue to develop it, this paragraph can be updated and is, for now, only the global idea of the final looking of this CPU. If I have other ideas I will put them here.

### Components of an instruction
An instruction is divided in 4 parts : 
- Opcode (1 byte)
- A/First operand (register size bytes (for now 1))
- B/Second operand (register size bytes (for now 1))
- Address (RAM address size bytes)

There are a few things to know to fully understand how to write assembly for this CPU: 
- The opcode allows a lot of instruction and thus have a lot of options (cf. *Addressing mode* and *Instruction map*)
- A and B are basically the input of the ALU as well as the size of a register. Changing ones size implies also changing the other to have the whole structure working.
- The address is the size of the RAM address and *only for now* twice the size of the register selector. This will change but be sure to verify the following assumption: `size_address >= 2*size_register_selector`.
- Register address is always in the address part. For a 8-bits address and 4-bits selector, it will be 11112222 (1 being register 1 and 2 being register 2). If the address is bigger, the remaining bits are ignored. With the same example but with a 12-bits address, it will be 11112222XXXX (X being ignored). 
- The **LR** and **PC** registers are special, they will be (because not yet implemented) the size of an address. They are located at address `0xE` and `0xF`, if the normal register output is too small, they will be truncated.

### Instruction map
This map does not contain any information about addressing mode, for this refer to the (not yet written) explanatory pdf of the CPU.
|        |  0X   |  1X   |  2X   |  3X   |  4X   |  5X   |  6X   |  7X   |  8X   |  9X   |  AX   |  BX   |    CX     |     DX      |     EX      |    FX    |
| :----: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :-------: | :---------: | :---------: | :------: |
| **X0** |  NOP  | NOP\* | NOP\* | NOP\* |  MOV  | MOV\* |  MOV  | MOV\* |  STR  |  STR  | STR\* | STR\* | STRMV\*\* |  STREGMV\*  | STRMEMV\*\* | SWAP\*\* |
| **X1** | NOP\* | NOP\* | NOP\* | NOP\* | MOV\* | MOV\* | MOV\* | MOV\* | STR\* | STR\* | STR\* | STR\* | STRMV\*\* | STREGMV\*\* | STRMEMV\*\* | SWAP\*\* |
| **X2** |       |       |       |       |       |       |       |       |       |       |       |       |           |             |             |          |
| **X3** |       |       |       |       |       |       |       |       |       |       |       |       |           |             |             |          |
| **X4** | NOP\* | NOP\* | NOP\* | NOP\* | MOV\* | MOV\* | MOV\* | MOV\* | STR\* | STR\* | STR\* | STR\* | STRMV\*\* | STREGMV\*\* | STRMEMV\*\* | SWAP\*\* |
| **X5** | NOP\* | NOP\* | NOP\* | NOP\* | MOV\* | MOV\* | MOV\* | MOV\* | STR\* | STR\* | STR\* | STR\* | STRMV\*\* | STREGMV\*\* | STRMEMV\*\* | SWAP\*\* |
| **X6** |       |       |       |       |       |       |       |       |       |       |       |       |           |             |             |          |
| **X7** |       |       |       |       |       |       |       |       |       |       |       |       |           |             |             |          |
| **X8** |  ADD  |  ADD  |  ADD  |  ADD  | ADD\* | ADD\* | ADD\* | ADD\* | ADD\* | ADD\* | ADD\* | ADD\* |   ADD\*   |    ADD\*    |    ADD\*    |  ADD\*   |
| **X9** |  SUB  |  SUB  |  SUB  |  SUB  | SUB\* | SUB\* | SUB\* | SUB\* | SUB\* | SUB\* | SUB\* | SUB\* |   SUB\*   |    SUB\*    |    SUB\*    |  SUB\*   |
| **XA** |  MUL  |  MUL  |  MUL  |  MUL  | MUL\* | MUL\* | MUL\* | MUL\* | MUL\* | MUL\* | MUL\* | MUL\* |   MUL\*   |    MUL\*    |    MUL\*    |  MUL\*   |
| **XB** |  AND  |  AND  |  AND  |  AND  | AND\* | AND\* | AND\* | AND\* | AND\* | AND\* | AND\* | AND\* |   AND\*   |    AND\*    |    AND\*    |  AND\*   |
| **XC** |  OR   |  OR   |  OR   |  OR   | OR\*  | OR\*  | OR\*  | OR\*  | OR\*  | OR\*  | OR\*  | OR\*  |   OR\*    |    OR\*     |    OR\*     |   OR\*   |
| **XD** |  XOR  |  XOR  |  XOR  |  XOR  | XOR\* | XOR\* | XOR\* | XOR\* | XOR\* | XOR\* | XOR\* | XOR\* |   XOR\*   |    XOR\*    |    XOR\*    |  XOR\*   |
| **XE** |  NOT  |  NOT  | NOT\* | NOT\* | NOT\* | NOT\* | NOT\* | NOT\* | NOT\* | NOT\* | NOT\* | NOT\* |   NOT\*   |    NOT\*    |    NOT\*    |  NOT\*   |
| **XF** |  CMP  |  CMP  | CMP\* | CMP\* | CMP\* | CMP\* | CMP\* | CMP\* | CMP\* | CMP\* | CMP\* | CMP\* |   CMP\*   |    CMP\*    |    CMP\*    |  CMP\*   |

All opcodes marked with \* are opcodes that are not used with their defined opcode. All opcodes marked with \*\* are unofficial opcodes. They are opcodes that uses a combination of existing functionnality to do something that was not meant for because of clock cycles configuration. Most of them must be followed by a NOPs to be working normally. Empty cells are cells that are still in progress.

## Why a CPU?
Why not?

## Are you crazy to do VHDL???
I think so, but it's not a problem right?