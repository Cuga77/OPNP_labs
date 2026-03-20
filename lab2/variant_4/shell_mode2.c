/* 1 */ // Программа: Сортировка методом Шелла
/* 2 */ // Режим 2: Детальное измерение управляющих конструкций
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
/* 20 */     bool done;
/* 21 */     int jump, i, j;
/* 22 */     jump = n;
/* 23 */     SAMPLE; // КТ: вход в while
/* 24 */     while (jump > 1) {
/* 25 */         SAMPLE; // КТ: Внешний цикл
/* 26 */         jump = jump / 2;
/* 27 */         SAMPLE; // КТ: вход в do-while
/* 28 */         do {
/* 29 */             SAMPLE; // КТ: Цикл do-while
/* 30 */             done = true;
/* 31 */             SAMPLE; // КТ: вход в for
/* 32 */             for (j = 0; j < n - jump; j++) {
/* 33 */                 SAMPLE; // КТ: Внутренний цикл for
/* 34 */                 i = j + jump;
/* 35 */                 SAMPLE; // КТ: вход в if
/* 36 */                 if (a[j] > a[i]) {
/* 37 */                     SAMPLE; // КТ: Ветвление if (обмен элементов)
/* 38 */                     swap(&a[j], &a[i]);
/* 39 */                     SAMPLE; // КТ: время и число повторений swap
/* 40 */                     done = false;
/* 41 */                     SAMPLE; // КТ: выход прямой ветви
/* 42 */                 }
/* 43 */                 SAMPLE; // КТ: время и число повторений for
/* 44 */             }
/* 45 */             SAMPLE; // КТ: время и число повторений do-while
/* 46 */         } while (!done);
/* 47 */         SAMPLE; // КТ: время и число повторений while
/* 48 */     }
/* 49 */     SAMPLE; // КТ: Выход из функции
/* 50 */ }
/* 51 */ 
/* 52 */ int main(int argc, char **argv) {
/* 53 */     sampler_init(&argc, argv);
/* 54 */     ary x;
/* 55 */     int n = MAX;
/* 56 */     srand(42);
/* 57 */     for (int k = 0; k < n; k++) {
/* 58 */         x[k] = (double)(rand() % 10000);
/* 59 */     }
/* 60 */     sort(x, n);
/* 61 */     return 0;
/* 62 */ }