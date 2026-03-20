// Программа: Сортировка методом Шелла
// Режим 1: Измерение полного времени выполнения алгоритма
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "sampler.h"

#define MAX 100

typedef double ary[MAX];

void swap(double *p, double *q) {
    double hold = *p;
    *p = *q;
    *q = hold;
}

void sort(ary a, int n) {
    bool done;
    int jump, i, j;
    jump = n;
    while (jump > 1) {
        jump = jump / 2;
        do {
            done = true;
            for (j = 0; j < n - jump; j++) {
                i = j + jump;
                if (a[j] > a[i]) {
                    swap(&a[j], &a[i]);
                    done = false;
                }
            }
        } while (!done);
    }
}

int main(int argc, char **argv) {
    sampler_init(&argc, argv);
    ary x;
    int n = MAX;
    
    srand(42);
    
    for (int k = 0; k < n; k++) {
        x[k] = (double)(rand() % 10000);
    }
    
    SAMPLE;
    sort(x, n);
    SAMPLE;
    
    return 0;
}