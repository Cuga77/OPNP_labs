/* 1 */ #include <stdio.h>
/* 2 */ #include <math.h>
/* 3 */ #include <stdbool.h>
/* 4 */ #include "sampler.h"
/* 5 */ 
/* 6 */ double fx(double x) {
/* 7 */     if (x == 0.0) return 0.0;
/* 8 */     return 1.0 / sqrt(x);
/* 9 */ }
/* 10 */ 
/* 11 */ void romb(double lower, double upper, double tol, double *ans) {
/* 12 */     SAMPLE; 
/* 13 */     int nx[16];
/* 14 */     double t[136];
/* 15 */     bool done = false;
/* 16 */     int pieces = 1;
/* 17 */     nx[1] = 1;
/* 18 */     double delta_x = (upper - lower) / pieces;
/* 19 */     double c = (fx(lower) + fx(upper)) * 0.5;
/* 20 */     t[1] = delta_x * c;
/* 21 */     int n = 1, nn = 2;
/* 22 */     double sum = c;
/* 23 */     int l, ntra, k, m, j, ii, i;
/* 24 */     double fotom, x;
/* 25 */ 
/* 26 */     SAMPLE; 
/* 27 */     do {
/* 28 */         SAMPLE; 
/* 29 */         n = n + 1;
/* 30 */         fotom = 4.0;
/* 31 */         nx[n] = nn;
/* 32 */         pieces = pieces * 2;
/* 33 */         l = pieces - 1;
/* 34 */         delta_x = (upper - lower) / pieces;
/* 35 */ 
/* 36 */         SAMPLE; 
/* 37 */         for (ii = 1; ii <= (l + 1) / 2; ii++) {
/* 38 */             SAMPLE; 
/* 39 */             i = ii * 2 - 1;
/* 40 */             x = lower + i * delta_x;
/* 41 */             sum = sum + fx(x);
/* 42 */             SAMPLE; 
/* 43 */         }
/* 44 */ 
/* 45 */         SAMPLE; 
/* 46 */         t[nn] = delta_x * sum;
/* 47 */         ntra = nx[n - 1];
/* 48 */         k = n - 1;
/* 49 */ 
/* 50 */         SAMPLE; 
/* 51 */         for (m = 1; m <= k; m++) {
/* 52 */             SAMPLE; 
/* 53 */             j = nn + m;
/* 54 */             int nt = nx[n - 1] + m - 1;
/* 55 */             t[j] = (fotom * t[j - 1] - t[nt]) / (fotom - 1.0);
/* 56 */             fotom = fotom * 4.0;
/* 57 */             SAMPLE; 
/* 58 */         }
/* 59 */ 
/* 60 */         SAMPLE; 
/* 61 */         if (n > 4) {
/* 62 */             SAMPLE; 
/* 63 */             if (t[nn + 1] != 0.0) {
/* 64 */                 SAMPLE; 
/* 65 */                 if ((fabs(t[ntra + 1] - t[nn + 1]) <= fabs(t[nn + 1] * tol)) ||
/* 66 */                     (fabs(t[nn - 1] - t[j]) <= fabs(t[j] * tol))) {
/* 67 */                     SAMPLE; 
/* 68 */                     done = true;
/* 69 */                     SAMPLE; 
/* 70 */                 }
/* 71 */                 SAMPLE; 
/* 72 */             }
/* 73 */             SAMPLE; 
/* 74 */         }
/* 75 */         SAMPLE; 
/* 76 */         nn = j + 1;
/* 77 */     } while (!done);
/* 78 */     SAMPLE; 
/* 79 */     *ans = t[j];
/* 80 */ }
/* 81 */ 
/* 82 */ int main(int argc, char **argv) {
/* 83 */     sampler_init(&argc, argv);
/* 84 */     double tol = 1.0E-4;
/* 85 */     double lower = 1.0;
/* 86 */     double upper = 9.0;
/* 87 */     double sum = 0.0;
/* 88 */     romb(lower, upper, tol, &sum);
/* 89 */     return 0;
/* 90 */ }