/* 1 */ // Программа: Сортировка методом Шелла
/* 2 */ // Режим 2: Детальное измерение (Оптимизированная)
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
/* 14 */     bool done;
/* 15 */     int jump, i, j;
/* 16 */     jump = n;
/* 17 */     SAMPLE; // КТ: вход в while
/* 18 */     while (jump > 1) {
/* 19 */         SAMPLE; // КТ: Внешний цикл
/* 20 */         jump = jump / 2;
/* 21 */         SAMPLE; // КТ: вход в do-while
/* 22 */         do {
/* 23 */             SAMPLE; // КТ: Цикл do-while
/* 24 */             done = true;
/* 25 */             SAMPLE; // КТ: вход в for
/* 26 */             for (j = 0; j < n - jump; j++) {
/* 27 */                 SAMPLE; // КТ: Внутренний цикл for
/* 28 */                 i = j + jump;
/* 29 */                 SAMPLE; // КТ: вход в if
/* 30 */                 if (a[j] > a[i]) {
/* 31 */                     SAMPLE; // КТ: Ветвление if (встроенный обмен)
/* 32 */                     double hold = a[j];
/* 33 */                     a[j] = a[i];
/* 34 */                     a[i] = hold;
/* 35 */                     SAMPLE; // КТ: время и число повторений swap
/* 36 */                     done = false;
/* 37 */                     SAMPLE; // КТ: выход прямой ветви
/* 38 */                 }
/* 39 */                 SAMPLE; // КТ: время и число повторений for
/* 40 */             }
/* 41 */             SAMPLE; // КТ: время и число повторений do-while
/* 42 */         } while (!done);
/* 43 */         SAMPLE; // КТ: время и число повторений while
/* 44 */     }
/* 45 */     SAMPLE; // КТ: Выход из функции
/* 46 */ }
/* 47 */ 
/* 48 */ int main(int argc, char **argv) {
/* 49 */     sampler_init(&argc, argv);
/* 50 */     ary x;
/* 51 */     int n = MAX;
/* 52 */     srand(42);
/* 53 */     for (int k = 0; k < n; k++) {
/* 54 */         x[k] = (double)(rand() % 10000);
/* 55 */     }
/* 56 */     sort(x, n);
/* 57 */     return 0;
/* 58 */ }