#include "sampler.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define MAX 100
typedef double ary[MAX];

void sort1(ary a, int n) {
    int i, j;
    double hold;
    for (i = 0; i < n - 1; i++) {
        for (j = i + 1; j < n; j++) {
            if (a[i] > a[j]) {
                hold = a[i];
                a[i] = a[j];
                a[j] = hold;
            }
        }
    }
}

void swap(double *p, double *q) {
    double hold = *p;
    *p = *q;
    *q = hold;
}

void sort2(ary a, int n) {
    bool no_change;
    int j;
    do {
        no_change = true;
        for (j = 0; j < n - 1; j++) {
            if (a[j] > a[j + 1]) {
                swap(&a[j], &a[j + 1]);
                no_change = false;
            }
        }
    } while (!no_change);
}

int main(int argc, char **argv) {
    sampler_init(&argc, argv);
    ary x1, x2;
    int n = MAX;
    srand(42);
    for (int k = 0; k < n; k++) {
        x1[k] = (double)(rand() % 10000);
        x2[k] = x1[k];
    }
    
    SAMPLE; 
    sort1(x1, n);
    SAMPLE; 
    sort2(x2, n);
    SAMPLE;
    return 0;
}