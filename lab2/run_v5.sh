#!/bin/bash

set -e

OUT_DIR="${1:-variant_18}"

echo "Создаем папку для результатов: $OUT_DIR"
mkdir -p "$OUT_DIR"

echo "Компиляция исходных файлов..."
gcc -I./sampler/libsampler romb_mode1.c ./sampler/build/libsampler/libsampler.a -o romb_mode1 -lm
gcc -I./sampler/libsampler romb_mode2.c ./sampler/build/libsampler/libsampler.a -o romb_mode2 -lm
gcc -I./sampler/libsampler romb_mode2_opt.c ./sampler/build/libsampler/libsampler.a -o romb_mode2_opt -lm

echo "Профилирование Режима 1 (romb_mode1)..."
taskset -c 0 ./sampler/build/tools/repeat 1050 50 ./romb_mode1 > "$OUT_DIR/raw_mode1.txt"
python3 ./sampler/tools/process.py < "$OUT_DIR/raw_mode1.txt" > "$OUT_DIR/processed_mode1.txt"
./sampler/tools/fmttable < "$OUT_DIR/processed_mode1.txt" > "$OUT_DIR/table_mode1.txt"

echo "Профилирование Режима 2 (romb_mode2)..."
taskset -c 0 ./sampler/build/tools/repeat 1050 50 ./romb_mode2 > "$OUT_DIR/raw_mode2.txt"
python3 ./sampler/tools/process.py < "$OUT_DIR/raw_mode2.txt" > "$OUT_DIR/processed_mode2.txt"
./sampler/tools/fmttable < "$OUT_DIR/processed_mode2.txt" > "$OUT_DIR/table_mode2.txt"
./sampler/tools/fmtdot < "$OUT_DIR/processed_mode2.txt" > "$OUT_DIR/graph_mode2.dot"
dot -Tpng "$OUT_DIR/graph_mode2.dot" -o "$OUT_DIR/graph_mode2.png"

echo "Профилирование оптимизированной версии (romb_mode2_opt)..."
taskset -c 0 ./sampler/build/tools/repeat 1050 50 ./romb_mode2_opt > "$OUT_DIR/raw_opt.txt"
python3 ./sampler/tools/process.py < "$OUT_DIR/raw_opt.txt" > "$OUT_DIR/processed_opt.txt"
./sampler/tools/fmttable < "$OUT_DIR/processed_opt.txt" > "$OUT_DIR/table_opt.txt"
./sampler/tools/fmtdot < "$OUT_DIR/processed_opt.txt" > "$OUT_DIR/graph_opt.dot"
dot -Tpng "$OUT_DIR/graph_opt.dot" -o "$OUT_DIR/graph_opt.png"

echo "Готово! Все оригинальные результаты успешно сохранены в директорию $OUT_DIR."