/* 1 */ // Программа: Сортировка пузырьком (Вариант 5)
/* 2 */ // Режим 2: Оптимизированная версия
/* 3 */ #include <stdio.h>
/* 4 */ #include <stdlib.h>
/* 5 */ #include <stdbool.h>
/* 6 */ #include "sampler.h"
/* 7 */ 
/* 8 */ #define MAX 100
/* 9 */ 
/* 10 */ typedef double ary[MAX];
/* 11 */ 
/* 12 */ void sort(ary a, int n) {
/* 13 */     SAMPLE; // КТ: Вход в функцию
/* 14 */     bool no_change;
/* 15 */     int j;
/* 16 */     SAMPLE; // КТ: вход в do-while
/* 17 */     do {
/* 18 */         SAMPLE; // КТ: Цикл do-while
/* 19 */         no_change = true;
/* 20 */         SAMPLE; // КТ: вход в for
/* 21 */         for (j = 0; j < n - 1; j++) {
/* 22 */             SAMPLE; // КТ: Внутренний цикл for
/* 23 */             SAMPLE; // КТ: вход в if
/* 24 */             if (a[j] > a[j + 1]) {
/* 25 */                 SAMPLE; // КТ: Ветвление if
/* 26 */                 double hold = a[j];
/* 27 */                 a[j] = a[j + 1];
/* 28 */                 a[j + 1] = hold;
/* 29 */                 SAMPLE; // КТ: inline swap
/* 30 */                 no_change = false;
/* 31 */                 SAMPLE; // КТ: выход if
/* 32 */             }
/* 33 */             SAMPLE; // КТ: время for
/* 34 */         }
/* 35 */         SAMPLE; // КТ: время do-while
/* 36 */     } while (!no_change);
/* 37 */     SAMPLE; // КТ: Выход из функции
/* 38 */ }
/* 39 */ 
/* 40 */ int main(int argc, char **argv) {
/* 41 */     sampler_init(&argc, argv);
/* 42 */     ary x;
/* 43 */     int n = MAX;
/* 44 */     srand(42);
/* 45 */     for (int k = 0; k < n; k++) {
/* 46 */         x[k] = (double)(rand() % 10000);
/* 47 */     }
/* 48 */     sort(x, n);
/* 49 */     return 0;
/* 50 */ }