#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#ifndef max
#  define max(a, b) (((a) > (b)) ? a : b)
#endif

#define BLANK '\0'
#define FINAL 255

static const char* state_names[] = {
    "matching",
    "undo",
    "wskip",
    "wtrim1",
    "wtrim2",
    "wtrim3",
    "wtrim4",
    "wtrim5",
    "cleanup1",
    "cleanup2",
    "cleanup3",
};

static char *full_w, *full_f, *full_r;

void print_char(char c) {
    if (c == BLANK) {
        putchar('_');
    } else {
        putchar(c);
    }
}

void print_tape(char* full_s, char* s) {
    for (char* p = full_s; p < s; ++p) {
        print_char(*p);
    }
    putchar('[');
    print_char(*s);
    putchar(']');
    puts(s+1);
}

void print_tapes(char* w, char* f, char* r) {
    printf("w: ");
    print_tape(full_w, w);
    printf("f: ");
    print_tape(full_f, f);
    printf("r: ");
    print_tape(full_r, r);
    putchar('\n');
}

int find_replace() {
    char *w = full_w, *f = full_f, *r = full_r;
    int st = 0;
    int nsteps = 0;
    while (st != FINAL) {
        nsteps++;
        printf("state: %s\n", state_names[st]);
        print_tapes(w, f, r);
        switch (st) {
            // Replacing r in f if w and f match and neither is blank
            // ======================================================
            case 0:
                if (*f == BLANK) { // All f matched!
                    if (*w == BLANK) { // We're at the end of w
                        st = FINAL; // TODO
                    } else { // We're in the middle of w
                        w--; // Check previous letter
                        st = 3; // Start trimming!
                    }
                } else { // f is not blank
                    if (*w == BLANK) { // end of w!
                        st = 10;
                    } else if (*w == *f) { // w and f match! (so w is not blank either)
                        *w = *r; // Replace r in w!
                        w++; f++; r++; // To the right!
                    } else { // w and f don't match!
                        w--; f--; r--; // To the left!
                        st = 1; // So, it's not a full match. UNDO!
                    }
                }
                break;

            // Replacing f in w if f is not blank
            // ==================================
            case 1:
                if (*f == BLANK) { // All match reverted!
                    w++; f++; r++; // To the right!
                    st = 2;
                } else {
                    *w = *f; // Replace f in w!
                    w--; f--; r--; // To the left!
                }
                break;

            // Skipping word letter
            // ====================
            case 2:
                w++; // Skip one letter
                st = 0;
                break;

            // Checking if w has holes
            // =======================
            case 3:
                if (*w == BLANK) {
                    st = 4;
                    *w = '$'; // Any letter
                } else {
                    st = FINAL; // No holes
                }
                break;
            
            // Fetching next w letter after hole
            // =================================
            case 4:
                if (*w == BLANK) {
                    w++; // Go to the right until a letter is found
                } else {
                    *w = BLANK; // Clean previously copied letter
                    w++; // Get next letter to copy
                    st = 5;
                }
                break;

            // Fetching next w letter to copy
            // ==============================
            case 5:
                if (*w == BLANK) {
                    *r = BLANK;
                    st = 8;
                } else {
                    *r = *w; // Save letter in r
                    w--; // Go to the first gap after the hole
                    st = 6;
                }
                break;

            // Fetching first letter before hole
            // =================================
            case 6:
                if (*w == BLANK) {
                    w--;
                } else {
                    w++;
                    st = 7;
                }
                break;

            // Writing letter in first gap
            // ===========================
            case 7:
                *w = *r;
                w++;
                st = 4;
                break;
            
            // Go to last letter of f and r
            // ============================
            case 8:
                if (*f == BLANK) {
                    f--;
                } else {
                    if (*r == BLANK) {
                        r--;
                    } else {
                        st = 9;
                    }
                }
                break;

            // Clearing f and r
            // ================
            case 9:
                if (*f == BLANK) {
                    if (*r == BLANK) {
                        st = FINAL;
                    } else {
                        *r = BLANK;
                        r--;
                    }
                } else {
                    *f = BLANK;
                    f--;
                }
                break;

            // Getting to the end of f and r
            // =============================
            case 10:
                if (*f == BLANK) {
                    if (*r == BLANK) {
                        st = 8;
                    } else {
                        r++;
                    }
                } else {
                    f++;
                }
                break;
        }
    }
    return nsteps;
}

char* copy(char* s, size_t len) {
    char* s2 = malloc(len+2);
    *s2 = BLANK;
    strncpy(s2+1, s, len+1);
    return s2+1;
}

int main(int argc, char** argv) {
    if (argc != 4) {
        fprintf(stderr, "Expected 3 arguments\n");
        return EXIT_FAILURE;
    }
    size_t wlen = strlen(argv[1]);
    size_t flen = strlen(argv[2]);
    size_t rlen = strlen(argv[3]);
    if (wlen == 0) {
        fprintf(stderr, "Word string cannot be empty\n");
        return EXIT_FAILURE;
    }
    if (flen == 0) {
        fprintf(stderr, "Find string cannot be empty\n");
        return EXIT_FAILURE;
    }
    if (rlen == 0) {
        fprintf(stderr, "Replace string cannot be empty\n");
        return EXIT_FAILURE;
    }
    full_w = copy(argv[1], max(wlen, rlen));
    full_f = copy(argv[2], flen + wlen + 1);
    full_r = copy(argv[3], max(wlen, rlen));
    int nsteps = find_replace();
    printf("result: %s\n", full_w);
    printf("steps: %d\n", nsteps);
    return EXIT_SUCCESS;
}
