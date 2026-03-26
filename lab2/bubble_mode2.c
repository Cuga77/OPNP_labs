/* 1 */ #include <stdio.h>
/* 2 */ #include <stdlib.h>
/* 3 */ #include <stdbool.h>
/* 4 */ #include "sampler.h"
/* 5 */ 
/* 6 */ #define MAX 100
/* 7 */ typedef double ary[MAX];
/* 8 */ 
/* 9 */ void sort1(ary a, int n) {
/* 10 */     int i, j;
/* 11 */     double hold;
/* 12 */     SAMPLE; 
/* 13 */     for (i = 0; i < n - 1; i++) {
/* 14 */         SAMPLE; 
/* 15 */         for (j = i + 1; j < n; j++) {
/* 16 */             SAMPLE; 
/* 17 */             if (a[i] > a[j]) {
/* 18 */                 SAMPLE; 
/* 19 */                 hold = a[i];
/* 20 */                 a[i] = a[j];
/* 21 */                 a[j] = hold;
/* 22 */             }
/* 23 */             SAMPLE; 
/* 24 */         }
/* 25 */         SAMPLE; 
/* 26 */     }
/* 27 */     SAMPLE; 
/* 28 */ }
/* 29 */ 
/* 30 */ void swap(double *p, double *q) {
/* 31 */     double hold = *p;
/* 32 */     *p = *q;
/* 33 */     *q = hold;
/* 34 */ }
/* 35 */ 
/* 36 */ void sort2(ary a, int n) {
/* 37 */     bool no_change;
/* 38 */     int j;
/* 39 */     SAMPLE; 
/* 40 */     do {
/* 41 */         no_change = true;
/* 42 */         SAMPLE; 
/* 43 */         for (j = 0; j < n - 1; j++) {
/* 44 */             SAMPLE; 
/* 45 */             if (a[j] > a[j + 1]) {
/* 46 */                 SAMPLE; 
/* 47 */                 swap(&a[j], &a[j + 1]);
/* 48 */                 no_change = false;
/* 49 */             }
/* 50 */             SAMPLE; 
/* 51 */         }
/* 52 */         SAMPLE; 
/* 53 */     } while (!no_change);
/* 54 */ }
/* 55 */ 
/* 56 */ int main(int argc, char **argv) {
/* 57 */     sampler_init(&argc, argv);
/* 58 */     ary x1, x2;
/* 59 */     int n = MAX;
/* 60 */     srand(42);
/* 61 */     for (int k = 0; k < n; k++) {
/* 62 */         x1[k] = (double)(rand() % 10000);
/* 63 */         x2[k] = x1[k];
/* 64 */     }
/* 65 */     
/* 66 */     SAMPLE; 
/* 67 */     sort1(x1, n);
/* 68 */     SAMPLE; 
/* 69 */     sort2(x2, n);
/* 70 */     SAMPLE; 
/* 71 */     
/* 72 */     return 0;
/* 73 */ }