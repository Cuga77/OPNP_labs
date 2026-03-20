// Программа 4. Сортировка методом Шелла (в.1)
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define MAX 80
typedef double ary[MAX];

void swap(double *p, double *q) {
    double hold = *p;
    *p = *q;
    *q = hold;
}

void sort(double a[], int n) {
    bool done;
    int jump, i, j;
    
    // 2 узел — инициализация переменных сортировки
    jump = n;

    // Вход во внешний цикл while (первое условие 10 > 1 всегда истинно)
    while (jump > 1) {
        // 3 узел — тело внешнего цикла
        jump = jump / 2;

        do {
            // 4 узел — начало do...while и инициализация for
            done = true;

            // Вход в цикл for (первая итерация j=0 < n-jump выполняется всегда)
            for (j = 0; j < n - jump; j++) {
                
                // 5 узел — начало тела for
                i = j + jump;

                // 6 узел — ПРЕДИКАТ: ветвление if
                if (a[j] > a[i]) {
                    // 7 узел — тело if (обмен)
                    swap(&a[j], &a[i]);
                    done = false;
                }
                // 8 узел — слияние ветвей if
                
                // 9 узел — конец тела for (инкремент j++)
            }
            // 10 узел — ПРЕДИКАТ: проверка условия цикла for при возврате
            
        // 11 узел — ПРЕДИКАТ: проверка условия цикла do...while
        } while (!done);
        
    // 12 узел — ПРЕДИКАТ: проверка условия внешнего while при возврате
    }
// 13 узел — выход из функции sort
}

int main() {
    // 1 узел — инициализация массива и вызов функции
    ary x;
    int n = 10; 
    
    for (int i = 0; i < n; i++) {
        x[i] = (double)(rand() % 100);
    }

    sort(x, n);

    // 14 узел — вывод результатов и завершение
    for (int i = 0; i < n; i++) {
        printf("%7.1f ", x[i]);
    }
    printf("\n");
    return 0;
}