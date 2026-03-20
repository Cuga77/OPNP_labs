#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "sampler.h"

#define MAX 5000
typedef double ary[MAX];

/* 09 */ void swap(double *p, double *q) {
/* 10 */     double hold = *p;
/* 11 */     *p = *q;
/* 12 */     *q = hold;
/* 13 */ }

/* 15 */ void sort(ary a, int n) {
/* 16 */     SAMPLE; // КТ: Вход в функцию
/* 17 */     bool done;
/* 18 */     int jump, i, j;
/* 19 */     jump = n;
/* 20 */     while (jump > 1) {
/* 21 */         SAMPLE; // КТ: Внешний цикл (сдвиг шага)
/* 22 */         jump = jump / 2;
/* 23 */         do {
/* 24 */             SAMPLE; // КТ: Цикл do-while (проход с текущим шагом)
/* 25 */             done = true;
/* 26 */             for (j = 0; j < n - jump; j++) {
/* 27 */                 SAMPLE; // КТ: Внутренний цикл for
/* 28 */                 i = j + jump;
/* 29 */                 if (a[j] > a[i]) {
/* 30 */                     SAMPLE; // КТ: Ветвление if (обмен элементов)
/* 31 */                     swap(&a[j], &a[i]);
/* 32 */                     done = false;
/* 33 */                 }
/* 34 */             }
/* 35 */         } while (!done);
/* 36 */     }
/* 37 */     SAMPLE; // КТ: Выход из функции
/* 38 */ }

/* 40 */ int main(int argc, char **argv) {
/* 41 */     sampler_init(&argc, argv);
/* 42 */     ary x;
/* 43 */     int n = MAX;
/* 44 */     for (int k = 0; k < n; k++) {
/* 45 */         x[k] = (double)(rand() % 10000);
/* 46 */     }
/* 47 */     sort(x, n);
/* 48 */     return 0;
/* 49 */ }