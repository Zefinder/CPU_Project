# CPU_Project
## Overall presentation of the project
This is a summer project where I have fun creating a CPU in VHDL using `Sigasi Studio` (that I can only recommend). This is to calm all this stress and frustration of the CPU project we had at school! So now I take pleasure to do it. If you want to participate, tell me!

## Organisation of the project
This project is, for now, only to make a 8-bits CPU without any pipeline levels. If I want to, I will implement pipelines, increase the data size, add a few more instructions, blablabla. This will only depend on how much I want to finish it. 

I will probably make a compiler, an interpreter and documentation of this CPU so it will be possible to use its assembly or to compile from C to this assembly for this CPU. Why not making an OS for this CPU hahaha

This CPU has a few components. The one that are ok are marked with (\/) currently developped are marked with (\*), the ones that are developped but where tests are lacking or are simply not implemented are marked with (+), the ones that still need to be developped are marked with (#) and finally the ones that will be improved are marked with ($).

- ALU				(\/)
- Register bank 	(+)
- Flag bank			(\/)
- Branching unit	(#) 
- RAM memory		(+)($)

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

## Why a CPU?
Why not?

## Are you crazy to do VHDL???
I think so, but it's not a problem right?