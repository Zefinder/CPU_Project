#ifndef UTILS
#define UTILS

#define SYMBOL_MODE 0
#define INSTRUCTION_MODE 1

// Print messages
void error_message(const char *format, ...);
void warning_message(const char *format, ...);

// String to integer
int btoi(char* binary_string);
int itoi(char* integer_string);
int htoi(char* hex_string);

// Label name
char* parse_label_name(char* label);

// Parsing mode
void set_mode(int new_mode);
int get_mode();

#endif