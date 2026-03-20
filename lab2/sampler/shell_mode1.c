#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "sampler.h" // Подключаем библиотеку ПИМ

#define MAX 5000
typedef double ary[MAX];

void swap(double *p, double *q) {
    double hold = *p;
    *p = *q;
    *q = hold;
}

void sort(ary a, int n) {
    SAMPLE; // КТ 1: Начало измерения алгоритма сортировки
    
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
    
    SAMPLE; // КТ 2: Конец измерения алгоритма
}

int main(int argc, char **argv) {
    // Обязательная инициализация монитора
    sampler_init(&argc, argv); 
    
    ary x;
    int n = MAX;
    
    // Генерация случайных чисел
    for (int k = 0; k < n; k++) {
        x[k] = (double)(rand() % 10000);
    }
    
    sort(x, n);
    
    return 0;
}