/* 01 */ #include <stdio.h>
/* 02 */ #include <stdlib.h>
/* 03 */ #include <math.h>
/* 04 */ #include "sampler.h"
/* 05 */ 
/* 06 */ #define MAX 100
/* 07 */ 
/* 08 */ void process_erf(double *x, double *res, int n) {
/* 09 */     double sqrtpi = 1.7724538;
/* 10 */     double t[11] = {0.666666667, 0.666666667, 0.07619048, 0.01693122,
/* 11 */                     3.078403e-3, 4.736005e-4, 6.314673e-5, 7.429027e-6,
/* 12 */                     7.820028e-7, 7.447646e-8, 6.476214e-9};
/* 13 */     SAMPLE;
/* 14 */     for (int k = 0; k < n; k++) {
/* 15 */         SAMPLE;
/* 16 */         double val = x[k];
/* 17 */         double x2 = val * val;
/* 18 */         double p = t[10];
/* 19 */         SAMPLE;
/* 20 */         for (int i = 9; i >= 0; i--) {
/* 21 */             SAMPLE;
/* 22 */             p = t[i] + x2 * p;
/* 23 */             SAMPLE;
/* 24 */         }
/* 25 */         SAMPLE;
/* 26 */         if (val > 0.0) {
/* 27 */             SAMPLE;
/* 28 */             res[k] = 2.0 * exp(-x2) / sqrtpi * (val * (1.0 + x2 * p));
/* 29 */             SAMPLE;
/* 30 */         } else {
/* 31 */             SAMPLE;
/* 32 */             res[k] = 0.0;
/* 33 */             SAMPLE;
/* 34 */         }
/* 35 */         SAMPLE;
/* 36 */     }
/* 37 */     SAMPLE;
/* 38 */ }
/* 39 */ 
/* 40 */ void process_erfc(double *x, double *res, int n) {
/* 41 */     double sqrtpi = 1.7724538;
/* 42 */     SAMPLE;
/* 43 */     for (int k = 0; k < n; k++) {
/* 44 */         SAMPLE;
/* 45 */         double val = x[k];
/* 46 */         double x2 = val * val;
/* 47 */         double v = 1.0 / (2.0 * x2);
/* 48 */         double s = 12.0 * v;
/* 49 */         SAMPLE;
/* 50 */         for (int j = 11; j >= 8; j--) {
/* 51 */             SAMPLE;
/* 52 */             s = (j * v) / (1.0 + s);
/* 53 */             SAMPLE;
/* 54 */         }
/* 55 */         SAMPLE;
/* 56 */         s = v / (1.0 + s);
/* 57 */         s = 7.0 * s;
/* 58 */         SAMPLE;
/* 59 */         for (int j = 6; j >= 3; j--) {
/* 60 */             SAMPLE;
/* 61 */             s = (j * v) / (1.0 + s);
/* 62 */             SAMPLE;
/* 63 */         }
/* 64 */         SAMPLE;
/* 65 */         s = v / (1.0 + s);
/* 66 */         if (val > 0.0) {
/* 67 */             SAMPLE;
/* 68 */             res[k] = 1.0 / (exp(x2) * val * sqrtpi * (1.0 + v / (1.0 + 2.0 * s)));
/* 69 */             SAMPLE;
/* 70 */         } else {
/* 71 */             SAMPLE;
/* 72 */             res[k] = 0.0;
/* 73 */             SAMPLE;
/* 74 */         }
/* 75 */         SAMPLE;
/* 76 */     }
/* 77 */     SAMPLE;
/* 78 */ }
/* 79 */ 
/* 80 */ int main(int argc, char **argv) {
/* 81 */     sampler_init(&argc, argv);
/* 82 */     double x[MAX], res1[MAX], res2[MAX];
/* 83 */     int n = MAX;
/* 84 */ 
/* 85 */     for (int k = 0; k < n; k++) {
/* 86 */         x[k] = 1.0 + (double)k / MAX;
/* 87 */     }
/* 88 */ 
/* 89 */     SAMPLE;
/* 90 */     process_erf(x, res1, n);
/* 91 */     SAMPLE;
/* 92 */     process_erfc(x, res2, n);
/* 93 */     SAMPLE;
/* 94 */ 
/* 95 */     return 0;
/* 96 */ }