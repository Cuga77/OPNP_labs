#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "sampler.h"

#define MAX 100

void process_erf(double *x, double *res, int n) {
    double sqrtpi = 1.7724538;
    double t[11] = {0.666666667, 0.666666667, 0.07619048, 0.01693122,
                    3.078403e-3, 4.736005e-4, 6.314673e-5, 7.429027e-6,
                    7.820028e-7, 7.447646e-8, 6.476214e-9};
    for (int k = 0; k < n; k++) {
        double val = x[k];
        double x2 = val * val;
        double p = t[10];
        for (int i = 9; i >= 0; i--) {
            p = t[i] + x2 * p;
        }
        res[k] = 2.0 * exp(-x2) / sqrtpi * (val * (1.0 + x2 * p));
    }
}

void process_erfc(double *x, double *res, int n) {
    double sqrtpi = 1.7724538;
    for (int k = 0; k < n; k++) {
        double val = x[k];
        double x2 = val * val;
        double v = 1.0 / (2.0 * x2);
        double s = 12.0 * v;
        for (int j = 11; j >= 8; j--) {
            s = (j * v) / (1.0 + s);
        }
        s = v / (1.0 + s);
        s = 7.0 * s;
        for (int j = 6; j >= 3; j--) {
            s = (j * v) / (1.0 + s);
        }
        s = v / (1.0 + s);
        res[k] = 1.0 / (exp(x2) * val * sqrtpi * (1.0 + v / (1.0 + 2.0 * s)));
    }
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
