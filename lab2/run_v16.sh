#!/bin/bash
# Сборка и запуск профилирования SAMPLER: 500 запусков, 100 пропусков (repeat).

set -euo pipefail

SAMPLER_ROOT="./sampler"
LIBS="${SAMPLER_ROOT}/libsampler"
LIBA="${SAMPLER_ROOT}/build/libsampler/libsampler.a"
REPEAT="${SAMPLER_ROOT}/build/tools/repeat"

OUT_DIR="variant_16_results"
mkdir -p "$OUT_DIR"

echo "Компиляция (режим 1, 2, оптимизированный)..."
gcc -I"${LIBS}" main_mode1.c "${LIBA}" -o main_mode1 -lm
gcc -I"${LIBS}" main_mode2.c "${LIBA}" -o main_mode2 -lm
gcc -I"${LIBS}" main_mode2_opt.c "${LIBA}" -o main_mode2_opt -lm

run_repeat() {
    local name="$1"
    local prog="$2"
    echo "Профилирование ${name}: taskset -c 0 ${REPEAT} 500 100 ${prog}"
    taskset -c 0 "${REPEAT}" 500 100 "${prog}" > "${OUT_DIR}/raw_${name}.txt"
    python3 "${SAMPLER_ROOT}/tools/process.py" < "${OUT_DIR}/raw_${name}.txt" > "${OUT_DIR}/processed_${name}.txt"
    "${SAMPLER_ROOT}/tools/fmttable" < "${OUT_DIR}/processed_${name}.txt" > "${OUT_DIR}/table_${name}.txt"
    "${SAMPLER_ROOT}/tools/fmtdot" < "${OUT_DIR}/processed_${name}.txt" > "${OUT_DIR}/graph_${name}.dot"
    dot -Tpng "${OUT_DIR}/graph_${name}.dot" -o "${OUT_DIR}/graph_${name}.png"
}

echo "Режим 1 (полное время процедур)..."
run_repeat "mode1" "./main_mode1"

echo "Режим 2 (детальные ФУ)..."
run_repeat "mode2" "./main_mode2"

echo "Режим 2 оптимизированный..."
run_repeat "opt" "./main_mode2_opt"

echo "Готово. Результаты в каталоге ${OUT_DIR}"
