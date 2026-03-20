/* 1 */ #include <stdio.h>
/* 2 */ #include <math.h>
/* 3 */ #include <stdbool.h>
/* 4 */ #include "sampler.h"
/* 5 */ 
/* 6 */ void romb(double lower, double upper, double tol, double *ans) {
/* 7 */     SAMPLE; 
/* 8 */     int nx[16];
/* 9 */     double t[136];
/* 10 */     bool done = false;
/* 11 */     int pieces = 1;
/* 12 */     nx[1] = 1;
/* 13 */     double delta_x = (upper - lower) / pieces;
/* 14 */     double c = ((lower == 0.0 ? 0.0 : 1.0 / sqrt(lower)) + (upper == 0.0 ? 0.0 : 1.0 / sqrt(upper))) * 0.5;
/* 15 */     t[1] = delta_x * c;
/* 16 */     int n = 1, nn = 2;
/* 17 */     double sum = c;
/* 18 */     int l, ntra, k, m, j, ii, i;
/* 19 */     double fotom, x;
/* 20 */ 
/* 21 */     SAMPLE; 
/* 22 */     do {
/* 23 */         SAMPLE; 
/* 24 */         n = n + 1;
/* 25 */         fotom = 4.0;
/* 26 */         nx[n] = nn;
/* 27 */         pieces = pieces * 2;
/* 28 */         l = pieces - 1;
/* 29 */         delta_x = (upper - lower) / pieces;
/* 30 */ 
/* 31 */         SAMPLE; 
/* 32 */         for (ii = 1; ii <= (l + 1) / 2; ii++) {
/* 33 */             SAMPLE; 
/* 34 */             i = ii * 2 - 1;
/* 35 */             x = lower + i * delta_x;
/* 36 */             sum = sum + (x == 0.0 ? 0.0 : 1.0 / sqrt(x)); 
/* 37 */             SAMPLE; 
/* 38 */         }
/* 39 */ 
/* 40 */         SAMPLE; 
/* 41 */         t[nn] = delta_x * sum;
/* 42 */         ntra = nx[n - 1];
/* 43 */         k = n - 1;
/* 44 */ 
/* 45 */         SAMPLE; 
/* 46 */         for (m = 1; m <= k; m++) {
/* 47 */             SAMPLE; 
/* 48 */             j = nn + m;
/* 49 */             int nt = nx[n - 1] + m - 1;
/* 50 */             t[j] = (fotom * t[j - 1] - t[nt]) / (fotom - 1.0);
/* 51 */             fotom = fotom * 4.0;
/* 52 */             SAMPLE; 
/* 53 */         }
/* 54 */ 
/* 55 */         SAMPLE; 
/* 56 */         if (n > 4) {
/* 57 */             SAMPLE; 
/* 58 */             if (t[nn + 1] != 0.0) {
/* 59 */                 SAMPLE; 
/* 60 */                 if ((fabs(t[ntra + 1] - t[nn + 1]) <= fabs(t[nn + 1] * tol)) ||
/* 61 */                     (fabs(t[nn - 1] - t[j]) <= fabs(t[j] * tol))) {
/* 62 */                     SAMPLE; 
/* 63 */                     done = true;
/* 64 */                     SAMPLE; 
/* 65 */                 }
/* 66 */                 SAMPLE; 
/* 67 */             }
/* 68 */             SAMPLE; 
/* 69 */         }
/* 70 */         SAMPLE; 
/* 71 */         nn = j + 1;
/* 72 */     } while (!done);
/* 73 */     SAMPLE; 
/* 74 */     *ans = t[j];
/* 75 */ }
/* 76 */ 
/* 77 */ int main(int argc, char **argv) {
/* 78 */     sampler_init(&argc, argv);
/* 79 */     double tol = 1.0E-4;
/* 80 */     double lower = 1.0;
/* 81 */     double upper = 9.0;
/* 82 */     double sum = 0.0;
/* 83 */     romb(lower, upper, tol, &sum);
/* 84 */     return 0;
/* 85 */ }