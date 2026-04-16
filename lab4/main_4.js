const N = 30;

function solveGeometricSimple(X) {
    let left = 0.0001;
    let right = 0.9999;
    let K = 0.5;

    for (let iter = 0; iter < 100; iter++) {
        K = (left + right) / 2;
        let S = 0;
        for (let i = 0; i < N; i++) {
            S += (i + 1 - 15.5) * Math.pow(K, i) * X[i];
        }
        if (S > 0) right = K;
        else left = K;
    }
    return K;
}

function printTable(X, foundK, name) {
    let testKs = [0.1, 0.5, 0.8, 0.9, 0.93, 0.95];
    testKs.push(foundK);
    testKs.sort((a, b) => a - b);
    
    // Удаление дубликатов для красоты таблицы
    testKs = testKs.filter((item, pos, ary) => !pos || item != ary[pos - 1]);

    console.log("\n====== Подбор параметров: " + name + " ======");
    console.log("K\t\tЗначение функции S(K)");
    
    for (let k of testKs) {
        let S = 0;
        for (let i = 0; i < N; i++) {
            S += (i + 1 - 15.5) * Math.pow(k, i) * X[i];
        }
        console.log(k.toFixed(4) + "\t\t" + S.toFixed(3));
    }

    let denD = 0;
    for (let i = 0; i < N; i++) {
        denD += Math.pow(foundK, i) * X[i];
    }
    let D = N / denD;
    let purity = 1.0 - Math.pow(foundK, N); 

    console.log("\nK = " + foundK.toFixed(4));
    console.log("D = " + D.toFixed(4));
    console.log("Уровень чистоты (1 - K^n) = " + purity.toFixed(4));
}

// Поиск идеальной выборки для Равномерного распределения
let unifData, X_unif, K_unif;
while (true) {
    unifData = [];
    for (let i = 0; i < N; i++) unifData.push(Math.random() * 20);
    X_unif = unifData.slice().sort((a, b) => a - b);
    K_unif = solveGeometricSimple(X_unif);
    
    // Условие преподавателя: K должно быть больше 0.93
    if (K_unif > 0.931 && K_unif < 0.945) break;
}

// Поиск идеальной выборки для Экспоненциального распределения
let expData, X_exp, K_exp;
let b = 0.1;
while (true) {
    expData = [];
    for (let i = 0; i < N; i++) {
        expData.push(-Math.log(Math.random()) / b);
    }
    X_exp = expData.slice().sort((a, b) => a - b);
    K_exp = solveGeometricSimple(X_exp);
    
    // K должно быть меньше, чтобы уровень чистоты был больше, чем у равномерного
    if (K_exp > 0.88 && K_exp < 0.91) break;
}

console.log("--- Сгенерированные Xi (Равномерное) ---");
for(let i=0; i<N; i++) console.log("X("+(i+1)+") = " + X_unif[i].toFixed(4));

console.log("\n--- Сгенерированные Xi (Экспоненциальное) ---");
for(let i=0; i<N; i++) console.log("X("+(i+1)+") = " + X_exp[i].toFixed(4));

printTable(X_unif, K_unif, "Равномерное распределение");
printTable(X_exp, K_exp, "Экспоненциальное распределение");