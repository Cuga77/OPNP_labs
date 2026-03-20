// Программа: Сортировка пузырьком (Вариант 5)
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