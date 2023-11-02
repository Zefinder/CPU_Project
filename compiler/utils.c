#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdarg.h>
#include "utils.h"

void error_message(const char* format, ...) {
    va_list args;
    va_start(args, format);
    printf("\e[31m[ERROR]\e[0m: ");
    vprintf(format, args); 
    va_end(args);
}

void warning_message(const char* format, ...) {
    va_list args;
    va_start(args, format);
    printf("\e[33m[WARNING]\e[0m: ");
    vprintf(format, args); 
    va_end(args);
}

int btoi(char* binary_string){
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

    return binaryval;
}

int itoi(char* integer_string) {
    int result_size = strlen(integer_string) - 1;
    char* result = malloc(sizeof(char) * result_size);
    strncpy(result, integer_string + 1, result_size);

    return atoi(result);
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

int htoi(char* hex_string) {
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
    
    return hexval;
}

char* parse_label_name(char* label) {
    int label_size = strlen(label);
    char* parsed_label = malloc(sizeof(char) * label_size);
    strncpy(parsed_label, label, label_size);

    return parsed_label;
}

// Parsing mode
int mode;

void set_mode(int new_mode) {
    mode = new_mode;
}

int get_mode() {
    return mode;
}
