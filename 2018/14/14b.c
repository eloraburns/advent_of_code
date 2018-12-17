#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define SEARCH_SPACE 100000000

int main(int argc, char **argv) {
    char *state = malloc(SEARCH_SPACE);
    memset(state, 0, SEARCH_SPACE);
    state[0] = 3;
    state[1] = 7;
    int e1 = 0;
    int e2 = 1;
    for (int i = 2; i < SEARCH_SPACE - 2; ) {
        int score = state[e1] + state[e2];
        if (score > 9) {
            state[i++] = 1;
            score -= 10;
        }
        state[i++] = score;
        e1 = (e1 + state[e1] + 1) % i;
        e2 = (e2 + state[e2] + 1) % i;
    }
    char *found = (char *)memmem(state, SEARCH_SPACE, "\x03\x06\x00\x07\x08\x01", 6);
    //char *found = (char *)memmem(state, SEARCH_SPACE, "\x05\x09\x04\x01\x04\x01", 5);
    if (found == NULL) {
        printf("Not found. :(\n");
    } else {
        printf("There were %ld recipes before.\n", found - state);
    }

    return 0;
}
