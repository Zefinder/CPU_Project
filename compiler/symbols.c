#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbols.h"
#include "utils.h"

struct symbol_node {
    char* symbol;
    int value;
    int used;
    struct symbol_node* next_node;
};

struct symbol_node* first_node = NULL;

void create_symbol(char* symbol, int value) {
    if (get_mode() == SYMBOL_MODE) {
        struct symbol_node* new_node = malloc(sizeof(struct symbol_node));
        new_node->symbol = symbol;
        new_node->value = value;
        new_node->used = 0;
        new_node->next_node = NULL;

        if (first_node == NULL) {
            first_node = new_node;
        } else {
            struct symbol_node* node = first_node;
            while (node->next_node != NULL) {
                node = node->next_node;
            }

            node->next_node = new_node;
        }
    }
}

int get_symbol(char* symbol) {
    struct symbol_node* node = first_node;
    while (node != NULL) {
        if (strcmp(node->symbol, symbol) == 0) {
            return node->value;
        }
        node = node->next_node;
    }

    return -1;
}

void warn_unused_symbols() {
    struct symbol_node* node = first_node;
    while (node != NULL) {
        if (node->symbol != NULL && !node->used) {
            int is_label = node->symbol[0] == '.';
            if (is_label) {
                warning_message("label '%s' is not used!\n", node->symbol);
            } else {
                warning_message("constant '%s' is not used!\n", node->symbol);
            }
        }
        node = node->next_node;
    }
}

void clear_symbols() {
    warn_unused_symbols();

    struct symbol_node* node = first_node;

    while (node != NULL) {
        struct symbol_node* next_node = node->next_node;
        
        free(node->symbol);
        free(node);

        node = next_node;
    }
}