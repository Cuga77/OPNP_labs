const N = 30;
let seed = 12345;

function rand() {
    seed = (seed * 1664525 + 1013904223) & 0xFFFFFFFF;
    return (seed >>> 0) / 0xFFFFFFFF;
}

// Генерация равномерного распределения U[0, 20]
let unifData = [];
for (let i = 0; i < N; i++) {
    unifData.push(rand() * 20);
}

// Генерация экспоненциального распределения, b = 0.1
seed = 67890;
let expData = [];
let b = 0.1;
for (let i = 0; i < N; i++) {
    let z = rand();
    expData.push(-Math.log(z) / b);
}

// Среднее и СКО
function mean(arr) {
    let s = 0;
    for (let i = 0; i < arr.length; i++) s += arr[i];
    return s / arr.length;
}

function sko(arr) {
    let m = mean(arr);
    let s = 0;
    for (let i = 0; i < arr.length; i++) {
        s += (arr[i] - m) * (arr[i] - m);
    }
    return Math.sqrt(s / arr.length);
}

console.log("=== Равномерное распределение ===");
console.log("Среднее:", mean(unifData).toFixed(4), "(теор: 10)");
console.log("СКО:", sko(unifData).toFixed(4), "(теор: 5.8)");

console.log("\n=== Экспоненциальное распределение ===");
console.log("Среднее:", mean(expData).toFixed(4), "(теор: 10)");
console.log("СКО:", sko(expData).toFixed(4), "(теор: 10)");

// Сортировка по возрастанию (для геометрической модели)
let X_unif = unifData.slice().sort((a, b) => a - b);
let X_exp = expData.slice().sort((a, b) => a - b);

console.log("\n--- Равномерное: сгенерированные ---");
for (let i = 0; i < N; i++) console.log("t[" + (i+1) + "] = " + unifData[i].toFixed(4));

console.log("\n--- Равномерное: отсортированные (Xi) ---");
for (let i = 0; i < N; i++) console.log("X(" + (i+1) + ") = " + X_unif[i].toFixed(4));

console.log("\n--- Экспоненциальное: сгенерированные ---");
for (let i = 0; i < N; i++) console.log("t[" + (i+1) + "] = " + expData[i].toFixed(4));

console.log("\n--- Экспоненциальное: отсортированные (Xi) ---");
for (let i = 0; i < N; i++) console.log("X(" + (i+1) + ") = " + X_exp[i].toFixed(4));

// Функция расчета геометрической модели с подробным выводом
function solveGeometric(X, label) {
    console.log("\n\n====== Расчет параметров: " + label + " ======");
    let left = 0.0001;
    let right = 0.9999;
    let K = 0.5;
    let target = (N - 1) / 2.0;

    for (let iter = 0; iter < 100; iter++) {
        K = (left + right) / 2;
        let num = 0;
        let den = 0;
        for (let i = 0; i < N; i++) {
            let term = Math.pow(K, i) * X[i];
            num += i * term;
            den += term;
        }
        if ((num / den) > target) {
            right = K;
        } else {
            left = K;
        }
    }

    console.log("i\tXi\t\tK^(i-1)\t\tK^(i-1)*Xi\t(i-1)*K^(i-1)*Xi");
    let sumDen = 0;
    let sumNum = 0;
    let sumX = 0;
    
    for (let i = 0; i < N; i++) {
        let p = Math.pow(K, i);
        let term = p * X[i];
        let numTerm = i * term;
        
        sumX += X[i];
        sumDen += term;
        sumNum += numTerm;
        
        console.log((i+1) + "\t" + X[i].toFixed(4) + "\t\t" + p.toFixed(4) + "\t\t" + term.toFixed(4) + "\t\t" + numTerm.toFixed(4));
    }
    
    console.log("Σ\t" + sumX.toFixed(2) + "\t\t---\t\t" + sumDen.toFixed(4) + "\t\t" + sumNum.toFixed(4));
    
    let D = N / sumDen;
    let purity = Math.pow(K, N);

    console.log("\nПроверка уравнения: " + sumNum.toFixed(4) + " / " + sumDen.toFixed(4) + " = " + (sumNum / sumDen).toFixed(4) + " (Цель: " + target + ")");
    console.log("K = " + K.toFixed(4));
    console.log("D = " + D.toFixed(4));
    console.log("Уровень чистоты ρ = " + purity.toFixed(4));

    return { K, D, purity };
}

let res1 = solveGeometric(X_unif, "Равномерное");
let res2 = solveGeometric(X_exp, "Экспоненциальное");

console.log("\n====== СРАВНЕНИЕ ======");
console.log("Параметр\tРавном.\t\tЭксп.");
console.log("K\t\t" + res1.K.toFixed(4) + "\t\t" + res2.K.toFixed(4));
console.log("D\t\t" + res1.D.toFixed(4) + "\t\t" + res2.D.toFixed(4));
console.log("Уровень чистоты\t" + res1.purity.toFixed(4) + "\t\t" + res2.purity.toFixed(4));