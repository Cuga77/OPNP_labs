#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include "sampler.h"

double fx(double x) {
    if (x == 0.0) return 0.0;
    return 1.0 / sqrt(x);
}

void romb(double lower, double upper, double tol, double *ans) {
    int nx[16];
    double t[136];
    bool done = false;
    int pieces = 1;
    nx[1] = 1;
    double delta_x = (upper - lower) / pieces;
    double c = (fx(lower) + fx(upper)) * 0.5;
    t[1] = delta_x * c;
    int n = 1, nn = 2;
    double sum = c;
    int l, ntra, k, m, j, ii, i;
    double fotom, x;

    do {
        n = n + 1;
        fotom = 4.0;
        nx[n] = nn;
        pieces = pieces * 2;
        l = pieces - 1;
        delta_x = (upper - lower) / pieces;

        for (ii = 1; ii <= (l + 1) / 2; ii++) {
            i = ii * 2 - 1;
            x = lower + i * delta_x;
            sum = sum + fx(x);
        }

        t[nn] = delta_x * sum;
        ntra = nx[n - 1];
        k = n - 1;

        for (m = 1; m <= k; m++) {
            j = nn + m;
            int nt = nx[n - 1] + m - 1;
            t[j] = (fotom * t[j - 1] - t[nt]) / (fotom - 1.0);
            fotom = fotom * 4.0;
        }

        if (n > 4) {
            if (t[nn + 1] != 0.0) {
                if ((fabs(t[ntra + 1] - t[nn + 1]) <= fabs(t[nn + 1] * tol)) ||
                    (fabs(t[nn - 1] - t[j]) <= fabs(t[j] * tol))) {
                    done = true;
                }
            }
        }
        nn = j + 1;
    } while (!done);
    *ans = t[j];
}

int main(int argc, char **argv) {
    sampler_init(&argc, argv);
    double tol = 1.0E-4;
    double lower = 1.0;
    double upper = 9.0;
    double sum = 0.0;
    
    SAMPLE;
    romb(lower, upper, tol, &sum);
    SAMPLE;
    
    return 0;
}