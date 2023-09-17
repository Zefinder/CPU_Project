#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "utils.h"

char* btoi(char* binary_string){
    char* result;
    int binaryval = 0;
    int index = strlen(binary_string) - 1;
    int power = 0;

    while (binary_string[index] != '%') {
        if (binary_string[index] == '1') {
            binaryval += (int) pow(2, power);
        }

        index -= 1;
        power += 1;
    }

    sprintf(result, "%d", binaryval);
    return result;
}

char* itoi(char* integer_string) {
    // strncpy(destination_string,input_string+pos,len);
    char* result;
    strncpy(result, integer_string + 1, strlen(integer_string) - 1);

    return result;
}

int hexchartoi(char c) {
    if (c >= '1' && c <= '9') {
        return 1 + (c - '1');
    }

    if (c == 'A' || c == 'a') {
        return 10;
    }
    if (c == 'B' || c == 'b') {
        return 11;
    }
    if (c == 'C' || c == 'c') {
        return 12;
    }
    if (c == 'D' || c == 'd') {
        return 13;
    }
    if (c == 'E' || c == 'e') {
        return 14;
    }
    if (c == 'F' || c == 'f') {
        return 15;
    }
    
    return 0;
}

char* htoi(char* hex_string) {
    char* result;
    int hexval = 0;
    int index = strlen(hex_string) - 1;
    int power = 0;

    while (hex_string[index] != '$') {
        if (hex_string[index] != '0') {
            hexval += (int) pow(16, power) * hexchartoi(hex_string[index]);
        }

        index -= 1;
        power += 1;
    }

    sprintf(result, "%d", hexval);
    return result;
}