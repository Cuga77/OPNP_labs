#include <stdlib.h>

#include "sampler.h"

int min_element (int *arr, size_t n)
{
    SAMPLE;
    if (n == 0) {
        SAMPLE;
        return 0;
    }
    SAMPLE;
    int x = arr[0];
    SAMPLE;
    for (size_t i = 1; i < n; ++i) {
        SAMPLE;
        if (arr[i] < x) {
            SAMPLE;
            x = arr[i];
            SAMPLE;
        }
        SAMPLE;
    }
    SAMPLE;
    return x;
}

int main ()
{
    size_t n = 100;
    int *arr = malloc(n * sizeof(*arr));

    srand(0xDEADBEEF);
    for (size_t i = 0; i < n; ++i) {
        arr[i] = rand() % 5000;
    }

    int ans = min_element(arr, n);
    (void)ans;

    free(arr);

    return 0;
}
