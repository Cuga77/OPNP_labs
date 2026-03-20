/* 1 */ // Программа: Сортировка пузырьком (Вариант 5)
/* 2 */ // Режим 2: Детальное измерение
/* 3 */ #include <stdio.h>
/* 4 */ #include <stdlib.h>
/* 5 */ #include <stdbool.h>
/* 6 */ #include "sampler.h"
/* 7 */ 
/* 8 */ #define MAX 100
/* 9 */ 
/* 10 */ typedef double ary[MAX];
/* 11 */ 
/* 12 */ void swap(double *p, double *q) {
/* 13 */     double hold = *p;
/* 14 */     *p = *q;
/* 15 */     *q = hold;
/* 16 */ }
/* 17 */ 
/* 18 */ void sort(ary a, int n) {
/* 19 */     SAMPLE; // КТ: Вход в функцию
/* 20 */     bool no_change;
/* 21 */     int j;
/* 22 */     SAMPLE; // КТ: вход в do-while
/* 23 */     do {
/* 24 */         SAMPLE; // КТ: Цикл do-while
/* 25 */         no_change = true;
/* 26 */         SAMPLE; // КТ: вход в for
/* 27 */         for (j = 0; j < n - 1; j++) {
/* 28 */             SAMPLE; // КТ: Внутренний цикл for
/* 29 */             SAMPLE; // КТ: вход в if
/* 30 */             if (a[j] > a[j + 1]) {
/* 31 */                 SAMPLE; // КТ: Ветвление if
/* 32 */                 swap(&a[j], &a[j + 1]);
/* 33 */                 SAMPLE; // КТ: swap
/* 34 */                 no_change = false;
/* 35 */                 SAMPLE; // КТ: выход if
/* 36 */             }
/* 37 */             SAMPLE; // КТ: время for
/* 38 */         }
/* 39 */             SAMPLE; // КТ: время do-while
/* 40 */     } while (!no_change);
/* 41 */     SAMPLE; // КТ: Выход из функции
/* 42 */ }
/* 43 */ 
/* 44 */ int main(int argc, char **argv) {
/* 45 */     sampler_init(&argc, argv);
/* 46 */     ary x;
/* 47 */     int n = MAX;
/* 48 */     srand(42);
/* 49 */     for (int k = 0; k < n; k++) {
/* 50 */         x[k] = (double)(rand() % 10000);
/* 51 */     }
/* 52 */     sort(x, n);
/* 53 */     return 0;
/* 54 */ }