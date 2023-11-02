#include <stdio.h>
#include <stdlib.h>
#include "compile.h"
#include "utils.h"

// File pointer to write
FILE* file;

void openfile(char* filename) {
    file = fopen(filename, "wb");
}

void closefile() {
    fclose(file);
}

void writeinstruction(char opcode, char a, char b, char address) {
    if (get_mode() == INSTRUCTION_MODE) {
        fprintf(file, "%c", opcode);
        fprintf(file, "%c", a);
        fprintf(file, "%c", b);
        fprintf(file, "%c", address);
    }
}