#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "sampler.h"

#define MAX 100

/* Встраиваемый шаг цепной дроби: меньше накладных расходов на вызов при -O2. */
static inline double erfc_cf_step(int j, double v, double s) {
    return (j * v) / (1.0 + s);
}

void process_erf(double *x, double *res, int n) {
    double sqrtpi = 1.7724538;
    double t[11] = {0.666666667, 0.666666667, 0.07619048, 0.01693122,
                    3.078403e-3, 4.736005e-4, 6.314673e-5, 7.429027e-6,
                    7.820028e-7, 7.447646e-8, 6.476214e-9};
    SAMPLE;
    for (int k = 0; k < n; k++) {
        SAMPLE;
        double val = x[k];
        double x2 = val * val;
        double p = t[10];
        SAMPLE;
        /* Loop unrolling: убираем счётчик и условие внутреннего цикла Горнера. */
        SAMPLE;
        p = t[9] + x2 * p;
        SAMPLE;
        SAMPLE;
        p = t[8] + x2 * p;
        SAMPLE;
        SAMPLE;
        p = t[7] + x2 * p;
        SAMPLE;
        SAMPLE;
        p = t[6] + x2 * p;
        SAMPLE;
        SAMPLE;
        p = t[5] + x2 * p;
        SAMPLE;
        SAMPLE;
        p = t[4] + x2 * p;
        SAMPLE;
        SAMPLE;
        p = t[3] + x2 * p;
        SAMPLE;
        SAMPLE;
        p = t[2] + x2 * p;
        SAMPLE;
        SAMPLE;
        p = t[1] + x2 * p;
        SAMPLE;
        SAMPLE;
        p = t[0] + x2 * p;
        SAMPLE;
        SAMPLE;
        if (val > 0.0) {
            SAMPLE;
            res[k] = 2.0 * exp(-x2) / sqrtpi * (val * (1.0 + x2 * p));
            SAMPLE;
        } else {
            SAMPLE;
            res[k] = 0.0;
            SAMPLE;
        }
        SAMPLE;
    }
    SAMPLE;
}

void process_erfc(double *x, double *res, int n) {
    double sqrtpi = 1.7724538;
    SAMPLE;
    for (int k = 0; k < n; k++) {
        SAMPLE;
        double val = x[k];
        double x2 = val * val;
        double v = 1.0 / (2.0 * x2);
        double s = 12.0 * v;
        SAMPLE;
        SAMPLE;
        s = erfc_cf_step(11, v, s);
        SAMPLE;
        SAMPLE;
        s = erfc_cf_step(10, v, s);
        SAMPLE;
        SAMPLE;
        s = erfc_cf_step(9, v, s);
        SAMPLE;
        SAMPLE;
        s = erfc_cf_step(8, v, s);
        SAMPLE;
        SAMPLE;
        s = v / (1.0 + s);
        s = 7.0 * s;
        SAMPLE;
        SAMPLE;
        s = erfc_cf_step(6, v, s);
        SAMPLE;
        SAMPLE;
        s = erfc_cf_step(5, v, s);
        SAMPLE;
        SAMPLE;
        s = erfc_cf_step(4, v, s);
        SAMPLE;
        SAMPLE;
        s = erfc_cf_step(3, v, s);
        SAMPLE;
        SAMPLE;
        s = v / (1.0 + s);
        if (val > 0.0) {
            SAMPLE;
            res[k] = 1.0 / (exp(x2) * val * sqrtpi * (1.0 + v / (1.0 + 2.0 * s)));
            SAMPLE;
        } else {
            SAMPLE;
            res[k] = 0.0;
            SAMPLE;
        }
        SAMPLE;
    }
    SAMPLE;
}

int main(int argc, char **argv) {
    sampler_init(&argc, argv);
    double x[MAX], res1[MAX], res2[MAX];
    int n = MAX;

    for (int k = 0; k < n; k++) {
        x[k] = 1.0 + (double)k / MAX;
    }

    SAMPLE;
    process_erf(x, res1, n);
    SAMPLE;
    process_erfc(x, res2, n);
    SAMPLE;

    return 0;
}
